#!/usr/bin/env python3
"""
voice_audit.py — mechanical audit for Pig & Swine RPG voice-reference JSONLs.

Catches what regex can catch:
  - Curly punctuation (curly quotes, curly apostrophes, ellipsis), line endings,
    NFC normalization, trailing whitespace, single trailing newline.
  - JSON validity per record.
  - Schema: required fields present (record_type, id, character_id, speaker,
    text).
  - Rule A: canonical names in `speaker` and `text` (no "Dr. Cula" without A.,
    no legacy names Kula/Muraś/Rak/Wymysl).
  - Rule B: address forms match speaker's circle. Inner-circle speakers
    (Dr. A. Cula, Crab, Whimsy) say "Murrow"; everyone else says "Mr. Murrow".
    Crab and Whimsy may say "Cula" (bare); everyone else says "Dr. A. Cula".
    Cula in Chapter 1 first-meeting context is flagged POSSIBLE_FIRST_MEETING.
  - Out-of-scope content: references to Scooter Racing or Ski Slalom; the
    Final Printer tagged as minigame instead of casebook_battle.
  - Duplicate file detection (by content hash).

Does NOT catch (needs LLM judgment):
  - Taste Standard pass/fail per line.
  - Canon-fit on character voice profiles (e.g., is Mr. Pig's maritime tic
    used at the right rate?).
  - Whether a flagged POSSIBLE_FIRST_MEETING line is actually the
    first-meeting beat or just a Cula-Murrow scene later in the chapter.

Usage:
    python tools/voice_audit.py uploads/*.jsonl
    python tools/voice_audit.py --normalize-in-place uploads/*.jsonl
    python tools/voice_audit.py --output godot/VOICE_AUDIT.md uploads/*.jsonl

Exit codes:
    0   clean
    1   violations found
    2   JSON errors or other hard failures

Re-run after each batch of new files. Cheap, deterministic, idempotent.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

# ---------------------------------------------------------------------------
# Canon
# ---------------------------------------------------------------------------

CANONICAL_SPEAKERS: set[str] = {
    # --- Main cast ---
    "Dr. A. Cula",
    "Mr. Pig",
    "Mr. Swine",
    "Murrow",
    "Crab",
    "Whimsy",
    "Asia",
    # --- Tier 2 / chapter-specific named NPCs ---
    "Archivist",
    "Sysadmin Bajtek",
    "Advocate Szpon",
    "Attorney Grzyb",
    "Ms. Tanaka",
    "Mr. Yamada",
    "Resort Counsel",
    "Resort Counsel Yamada",
    "Administrator Beton",
    "Waldek",
    "Kowalski",
    "Zielińska",
    # --- Judges and court staff ---
    "Judge",
    "District Court Judge",
    "Housing Court Judge",
    "Housing Judge",
    "Supreme Court Judge",
    "Court Clerk",
    "Arbitrator",
    # --- City / civic NPCs ---
    "City Official",
    # --- Background and chapter colour ---
    "Barista",
    "Tram Oracle",
    "Old Woman",
    "Penthouse Doorman",
    "Airport Clerk",
    # --- Non-speaking objects with printed messages (treated as NPCs for line tracking) ---
    "Office Printer",
    "Printer",
    "Industrial Printer",
    # --- Generic / collective speakers (multiple bodies behind one role) ---
    "Affected Person",
    "Street NPC",
    "Generic Blocker",
    "Bystander",
    "Tenant",
    "Protest Marshal",
    "Junior Lawyer",
    "Mail Carrier",
    "Bailiff",
    "Pedestrian",
    "Child",
    "Resident",
}

# File character_ids whose speakers are intentionally variable (pooled NPC
# files, multi-voice files). Any speaker appearing in such a file is accepted
# without flagging — the audit instead reports the unique set as informational.
POOLED_CHARACTER_IDS: set[str] = {
    "protest_square_affected_persons",
    "generic_blocker_street_npcs",
}

# Speakers who say "Murrow" (and "Cula" for Crab/Whimsy post-recruitment).
INNER_CIRCLE_TO_MURROW: set[str] = {"Dr. A. Cula", "Crab", "Whimsy"}
INNER_CIRCLE_TO_CULA: set[str] = {"Crab", "Whimsy"}

LEGACY_NAMES: list[str] = ["Kula", "Muraś", "Rak", "Wymysl"]

DROPPED_MINIGAMES: list[str] = ["Scooter Racing", "Ski Slalom"]

# Required schema fields per dialogue_sample record.
REQUIRED_FIELDS: list[str] = ["record_type", "id", "character_id", "speaker", "text"]

# ---------------------------------------------------------------------------
# Normalization
# ---------------------------------------------------------------------------

CURLY_REPL: dict[str, str] = {
    "‘": "'",
    "’": "'",
    "“": '"',
    "”": '"',
    "…": "...",
}


def normalize_text(text: str) -> str:
    """Idempotent text normalization. Returns the canonical form."""
    for k, v in CURLY_REPL.items():
        text = text.replace(k, v)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = "\n".join(line.rstrip() for line in text.split("\n"))
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = text.rstrip("\n") + "\n"
    text = unicodedata.normalize("NFC", text)
    return text


# ---------------------------------------------------------------------------
# Per-record checks
# ---------------------------------------------------------------------------

# "Cula" not preceded by "A. " — matches the bare/incorrect form.
RE_BARE_CULA = re.compile(r"(?<!A\. )\bCula\b")
# "Murrow" not preceded by "Mr. " — matches the bare form.
RE_BARE_MURROW = re.compile(r"(?<!Mr\. )\bMurrow\b")
# "Mr. Murrow" — explicit honorific form.
RE_MR_MURROW = re.compile(r"\bMr\. Murrow\b")
# "Dr. Cula" without "A." — Rule A violation.
RE_DR_CULA = re.compile(r"\bDr\. Cula\b")


def check_schema(record: dict) -> list[str]:
    missing = [f for f in REQUIRED_FIELDS if f not in record]
    if missing:
        return [f"Missing required fields: {missing}"]
    return []


def check_rule_a(record: dict, file_character_id: str = "") -> tuple[list[str], list[str]]:
    """Canonical names in speaker field and narration.
    Returns (violations, info_notes). Unknown speakers are info, not violations.
    """
    issues: list[str] = []
    info: list[str] = []
    speaker = record.get("speaker", "")
    text = record.get("text", "")

    if speaker and speaker not in CANONICAL_SPEAKERS and file_character_id not in POOLED_CHARACTER_IDS:
        info.append(speaker)

    for legacy in LEGACY_NAMES:
        if re.search(rf"\b{legacy}\b", text):
            issues.append(f"Rule A: legacy name '{legacy}' in text")

    if RE_DR_CULA.search(text):
        issues.append("Rule A: 'Dr. Cula' (no A.) — should be 'Dr. A. Cula'")

    return issues, info


def check_rule_b(record: dict) -> list[str]:
    """Address forms must match speaker's circle."""
    issues: list[str] = []
    speaker = record.get("speaker", "")
    text = record.get("text", "")
    chapter = record.get("chapter", "")
    scene = record.get("scene", "")
    context = record.get("context", "") or ""

    # --- Cula address form ---
    if RE_BARE_CULA.search(text):
        if speaker not in INNER_CIRCLE_TO_CULA:
            issues.append(
                f"Rule B: '{speaker}' uses bare 'Cula' — only Crab and Whimsy "
                f"may, and only post-recruitment. Should be 'Dr. A. Cula'."
            )

    # --- Murrow address form ---
    has_bare_murrow = bool(RE_BARE_MURROW.search(text))
    has_mr_murrow = bool(RE_MR_MURROW.search(text))

    if has_bare_murrow and speaker not in INNER_CIRCLE_TO_MURROW:
        issues.append(
            f"Rule B: '{speaker}' uses bare 'Murrow' — should be 'Mr. Murrow'."
        )

    if has_mr_murrow and speaker in INNER_CIRCLE_TO_MURROW:
        # Inner circle uses "Mr. Murrow" — only valid for Cula at first meeting.
        if speaker == "Dr. A. Cula" and chapter in ("ch01", "chapter1", "1"):
            # First-meeting beat heuristic: scene/context mentions murrow first
            # encounter or Beat 3 area.
            first_meeting_hints = [
                "first", "meeting", "introduction", "intro", "case_summary",
                "murrow_intro", "beat_3", "beat3",
            ]
            blob = (scene + " " + context).lower()
            if any(h in blob for h in first_meeting_hints):
                issues.append(
                    f"POSSIBLE_FIRST_MEETING: Cula uses 'Mr. Murrow' in {scene} "
                    f"({context}) — verify this is the canonical first-meeting "
                    f"beat (story.txt §Beat 3) before Murrow invites informality."
                )
            else:
                issues.append(
                    f"Rule B: Cula uses 'Mr. Murrow' in {chapter}/{scene} but "
                    f"context doesn't read as first-meeting. Should be 'Murrow' "
                    f"unless this is Beat 3 of Chapter 1."
                )
        else:
            issues.append(
                f"Rule B: '{speaker}' (inner circle) uses 'Mr. Murrow' — "
                f"should be 'Murrow'."
            )

    return issues


def check_out_of_scope(record: dict) -> list[str]:
    """Dropped mini-games and miscategorized Final Printer."""
    issues: list[str] = []
    text = record.get("text", "")
    scene = record.get("scene", "") or ""
    tags = record.get("tags", []) or []
    line_type = record.get("line_type", "") or ""

    haystack = (text + " " + scene + " " + line_type).lower()

    for dropped in DROPPED_MINIGAMES:
        # Allow scene-name references that look like deferred-narrative beats
        # (e.g., scene="deadline_filing_dash" is fine; scene="scooter_racing" is not).
        flagged = (
            dropped.lower() in text.lower()
            or dropped.lower().replace(" ", "_") in scene.lower()
        )
        if flagged:
            issues.append(
                f"Out-of-scope: references dropped mini-game '{dropped}' "
                f"(see PLAN.md §Out of scope permanently). Re-tag as a "
                f"narrative beat or remove."
            )

    # Final Printer tagged as minigame — should be casebook_battle.
    if "final_printer" in haystack or "industrial_printer" in haystack:
        if any(t in ("minigame", "mini_game", "mini-game") for t in tags):
            issues.append(
                "Out-of-scope: Final Printer tagged as 'minigame' — should be "
                "'casebook_battle' (see AGENTS.md §Forbidden patterns)."
            )

    return issues


# ---------------------------------------------------------------------------
# Auto-fix (speaker-aware mechanical corrections)
# ---------------------------------------------------------------------------

FIRST_MEETING_HINTS: list[str] = [
    "first", "meeting", "introduction", "intro", "case_summary",
    "murrow_intro", "beat_3", "beat3",
]

# Dropped mini-game → narrative-beat re-tagging. Per PLAN.md §Out of scope
# permanently, Scooter Racing and Ski Slalom are dropped mini-games; their
# lines remain useful as narrative-beat dialogue under new scene names.
SCENE_TOKEN_RENAMES: dict[str, str] = {
    "ski_slalom": "swine_memory",
    "scooter_racing": "deadline_dash",
}

CONTEXT_PHRASE_RENAMES: list[tuple[str, str]] = [
    # Order matters: longer / more specific first.
    # NOTE: only specific dropped-mini-game phrases. Generic "mini-game" /
    # "minigame" are intentionally absent — those words appear legitimately
    # in Coffee Brewing and Document Chase contexts (which are KEPT
    # mini-games) and rewriting them is metadata damage.
    ("Ski Slalom memory mini-game", "Swine memory interview"),
    ("Ski Slalom mini-game", "Swine memory interview"),
    ("Scooter Racing mini-game", "Deadline filing dash"),
    ("Ski Slalom", "Swine memory interview"),
    ("Scooter Racing", "Deadline filing dash"),
]

DROPPED_MINIGAME_TAGS: set[str] = {"minigame", "mini-game", "mini_game"}


def auto_fix_record(record: dict, file_character_id: str = "") -> tuple[dict, list[str]]:
    """Apply mechanical Rule A/B fixes that don't need human judgment.
    Returns (record, fixes_applied). Mutates record in place.
    """
    fixes: list[str] = []
    text = record.get("text", "") or ""
    speaker = record.get("speaker", "") or ""
    chapter = record.get("chapter", "") or ""
    scene = record.get("scene", "") or ""
    context = record.get("context", "") or ""

    new_text = text

    # Rule A: "Dr. Cula" -> "Dr. A. Cula" (always safe).
    if RE_DR_CULA.search(new_text):
        new_text = RE_DR_CULA.sub("Dr. A. Cula", new_text)
        fixes.append("Rule A: Dr. Cula -> Dr. A. Cula")

    # Rule B: speaker is outer-circle, uses bare "Cula" -> "Dr. A. Cula".
    if speaker not in INNER_CIRCLE_TO_CULA and RE_BARE_CULA.search(new_text):
        new_text = RE_BARE_CULA.sub("Dr. A. Cula", new_text)
        fixes.append(f"Rule B ({speaker}): bare Cula -> Dr. A. Cula")

    # Rule B: speaker is outer-circle, uses bare "Murrow" -> "Mr. Murrow".
    if speaker not in INNER_CIRCLE_TO_MURROW and RE_BARE_MURROW.search(new_text):
        new_text = RE_BARE_MURROW.sub("Mr. Murrow", new_text)
        fixes.append(f"Rule B ({speaker}): bare Murrow -> Mr. Murrow")

    # Rule B: Crab/Whimsy use "Mr. Murrow" -> "Murrow" (always wrong for them).
    if speaker in ("Crab", "Whimsy") and RE_MR_MURROW.search(new_text):
        new_text = RE_MR_MURROW.sub("Murrow", new_text)
        fixes.append(f"Rule B ({speaker}): Mr. Murrow -> Murrow")

    # Rule B: Cula uses "Mr. Murrow". Only valid at the canonical Beat 3 first
    # meeting in ch01. If chapter or scene/context don't read as first-meeting,
    # rewrite. Otherwise leave alone (the line IS the first-meeting beat).
    if speaker == "Dr. A. Cula" and RE_MR_MURROW.search(new_text):
        is_ch01 = chapter in ("ch01", "1", "chapter1")
        blob = (scene + " " + context).lower()
        looks_first_meeting = any(h in blob for h in FIRST_MEETING_HINTS)
        if not (is_ch01 and looks_first_meeting):
            new_text = RE_MR_MURROW.sub("Murrow", new_text)
            fixes.append("Rule B (Dr. A. Cula): Mr. Murrow -> Murrow (not first-meeting)")

    if new_text != text:
        record["text"] = new_text

    # Speaker-field fix: in the Murrow file, ChatGPT used "Mr. Murrow" as the
    # speaker label. Canonical handle is "Murrow". Accept both character_id
    # variants ChatGPT used.
    if file_character_id in ("mr_murrow", "murrow") and speaker == "Mr. Murrow":
        record["speaker"] = "Murrow"
        fixes.append("Speaker field: 'Mr. Murrow' -> 'Murrow' (canonical handle)")

    # --- Legacy-name auto-fix: bare legacy names in TEXT only (not in
    # context/notes — those are voice-reference scaffolding and may legitimately
    # cite the legacy name when discussing canon).
    legacy_renames = {
        "Rak": "Crab",
        "Muraś": "Murrow",
        "Wymysl": "Whimsy",
        "Kula": "Cula",  # rare; only fires if "Kula" appears as a bare word
    }
    text_after_legacy = record.get("text", "") or ""
    for old, new in legacy_renames.items():
        pattern = re.compile(rf"\b{re.escape(old)}\b")
        if pattern.search(text_after_legacy):
            text_after_legacy = pattern.sub(new, text_after_legacy)
            fixes.append(f"Rule A: legacy '{old}' -> '{new}' in text")
    if text_after_legacy != (record.get("text", "") or ""):
        record["text"] = text_after_legacy

    # --- Final Printer tag fix: scene mentions Final Printer / industrial
    # printer AND tags contain 'minigame' → drop 'minigame', add 'casebook_battle'.
    scene_for_printer_check = (record.get("scene", "") or "").lower()
    text_for_printer_check = (record.get("text", "") or "").lower()
    is_final_printer = (
        "final_printer" in scene_for_printer_check
        or "industrial_printer" in scene_for_printer_check
        or "final printer" in text_for_printer_check
    )
    if is_final_printer:
        tags_for_fp = record.get("tags", []) or []
        if any(
            isinstance(t, str) and t.lower() in DROPPED_MINIGAME_TAGS
            for t in tags_for_fp
        ):
            new_tags_fp = [
                t for t in tags_for_fp
                if not (isinstance(t, str) and t.lower() in DROPPED_MINIGAME_TAGS)
            ]
            if "casebook_battle" not in new_tags_fp:
                new_tags_fp.append("casebook_battle")
            record["tags"] = new_tags_fp
            fixes.append("Final Printer: minigame tag -> casebook_battle")

    # --- Dropped-mini-game re-tag pass ---
    # Rename scene/id/tags/context for records under dropped mini-game labels.
    # Lines themselves are preserved as narrative-beat dialogue.
    fixes.extend(_retag_dropped_minigames(record))

    return record, fixes


def _retag_dropped_minigames(record: dict) -> list[str]:
    """Rename scene/id/tags/context where a record references a dropped
    mini-game (Scooter Racing, Ski Slalom). Mutates record in place.
    Returns list of fixes applied. Idempotent.

    Critical: a record is only treated as a dropped-mini-game record if
    its scene, id, or tags contain a dropped-mini-game token. The generic
    word "mini-game" in context is NOT sufficient — Coffee Brewing and
    Document Chase legitimately use that word.
    """
    fixes: list[str] = []

    # --- Detection pass: is this record actually about a dropped mini-game? ---
    scene = record.get("scene", "") or ""
    rec_id = record.get("id", "") or ""
    tags = record.get("tags", []) or []
    tag_strs = [t for t in tags if isinstance(t, str)]

    record_was_minigame = (
        any(tok in scene for tok in SCENE_TOKEN_RENAMES)
        or any(tok in rec_id for tok in SCENE_TOKEN_RENAMES)
        or any(
            tok in tag.lower()
            for tag in tag_strs
            for tok in SCENE_TOKEN_RENAMES
        )
    )

    if not record_was_minigame:
        return fixes  # leave Coffee Brewing / Document Chase records alone

    # --- Rewrite pass: only runs if detection said yes. ---

    # scene field
    for old, new in SCENE_TOKEN_RENAMES.items():
        if old in scene:
            record["scene"] = scene.replace(old, new)
            fixes.append(f"scene: {old} -> {new}")
            break

    # id field
    for old, new in SCENE_TOKEN_RENAMES.items():
        if old in rec_id:
            record["id"] = rec_id.replace(old, new)
            fixes.append(f"id: {old} token renamed")
            break

    # context field (prose) — apply phrase renames.
    context = record.get("context", "") or ""
    new_context = context
    for old_phrase, new_phrase in CONTEXT_PHRASE_RENAMES:
        pattern = re.compile(re.escape(old_phrase), re.IGNORECASE)
        if pattern.search(new_context):
            new_context = pattern.sub(new_phrase, new_context)
    if new_context != context:
        record["context"] = new_context
        fixes.append("context: dropped-minigame phrasing rewritten")

    # tags array
    new_tags: list = []
    tags_changed = False
    for tag in tags:
        if not isinstance(tag, str):
            new_tags.append(tag)
            continue
        if tag.lower() in DROPPED_MINIGAME_TAGS:
            tags_changed = True
            continue
        replaced = tag
        for old, new in SCENE_TOKEN_RENAMES.items():
            if old in tag.lower():
                replaced = tag.lower().replace(old, new)
                tags_changed = True
                break
        new_tags.append(replaced)
    if tags_changed:
        record["tags"] = new_tags
        fixes.append("tags: dropped-minigame tags rewritten/dropped")

    # line_type: minigame_dialogue -> dialogue
    if record.get("line_type") == "minigame_dialogue":
        record["line_type"] = "dialogue"
        fixes.append("line_type: minigame_dialogue -> dialogue")

    return fixes


def auto_fix_file(path: Path) -> dict:
    """Apply auto-fixes to one JSONL file. Returns a fix-summary dict."""
    raw = path.read_text(encoding="utf-8")
    lines = raw.splitlines()

    # Pre-pass: find file's character_id from metadata.
    file_character_id = ""
    for line in lines:
        if not line.strip():
            continue
        try:
            rec = json.loads(line)
            if rec.get("record_type") in ("meta", "metadata"):
                file_character_id = rec.get("character_id", "") or ""
            break
        except json.JSONDecodeError:
            break

    new_lines: list[str] = []
    total_fixes: list[str] = []
    records_fixed = 0

    for line in lines:
        if not line.strip():
            new_lines.append(line)
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            new_lines.append(line)
            continue

        if record.get("record_type") in ("meta", "metadata"):
            new_lines.append(line)
            continue

        record, fixes = auto_fix_record(record, file_character_id)
        if fixes:
            records_fixed += 1
            total_fixes.extend(fixes)
            # Re-serialize without unnecessary whitespace, preserving non-ASCII.
            new_lines.append(json.dumps(record, ensure_ascii=False))
        else:
            new_lines.append(line)

    new_text = "\n".join(new_lines)
    if not new_text.endswith("\n"):
        new_text += "\n"

    if new_text != raw:
        path.write_text(new_text, encoding="utf-8")

    return {
        "file": str(path),
        "records_fixed": records_fixed,
        "total_fixes_applied": len(total_fixes),
        "fix_breakdown": _summarize_fixes(total_fixes),
    }


def _summarize_fixes(fixes: list[str]) -> dict[str, int]:
    summary: dict[str, int] = {}
    for fix in fixes:
        summary[fix] = summary.get(fix, 0) + 1
    return summary


# ---------------------------------------------------------------------------
# File-level audit
# ---------------------------------------------------------------------------


def audit_file(path: Path) -> dict:
    raw = path.read_text(encoding="utf-8")
    normalized = normalize_text(raw)

    findings: dict = {
        "file": str(path),
        "size_bytes": len(raw.encode("utf-8")),
        "needs_normalization": normalized != raw,
        "record_count": 0,
        "meta_count": 0,
        "violations": [],
        "json_errors": [],
        "unknown_speakers": {},  # speaker -> count
        "content_hash": hashlib.sha1(normalized.encode("utf-8")).hexdigest(),
    }

    # Find file-level character_id from metadata if present.
    file_character_id = ""
    for line in raw.splitlines():
        if line.strip():
            try:
                rec = json.loads(line)
                if rec.get("record_type") in ("meta", "metadata"):
                    file_character_id = rec.get("character_id", "") or ""
                break
            except json.JSONDecodeError:
                break

    for lineno, line in enumerate(raw.splitlines(), start=1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as exc:
            findings["json_errors"].append({"line": lineno, "error": str(exc)})
            continue

        if record.get("record_type") in ("meta", "metadata"):
            findings["meta_count"] += 1
            continue

        findings["record_count"] += 1

        rule_a_issues, rule_a_info = check_rule_a(record, file_character_id)
        for unknown_speaker in rule_a_info:
            findings["unknown_speakers"][unknown_speaker] = (
                findings["unknown_speakers"].get(unknown_speaker, 0) + 1
            )

        all_issues = (
            check_schema(record)
            + rule_a_issues
            + check_rule_b(record)
            + check_out_of_scope(record)
        )

        if all_issues:
            findings["violations"].append({
                "line": lineno,
                "record_id": record.get("id", "?"),
                "speaker": record.get("speaker", "?"),
                "chapter": record.get("chapter", ""),
                "scene": record.get("scene", ""),
                "text": (record.get("text", "") or "")[:120],
                "issues": all_issues,
            })

    return findings


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def render_markdown(all_findings: list[dict]) -> str:
    out: list[str] = ["# Voice-Reference Audit Report", ""]

    total_records = sum(f["record_count"] for f in all_findings)
    total_violations = sum(len(f["violations"]) for f in all_findings)
    total_json_errors = sum(len(f["json_errors"]) for f in all_findings)
    files_needing_norm = sum(1 for f in all_findings if f["needs_normalization"])

    # Duplicate detection.
    seen_hashes: dict[str, list[str]] = {}
    for f in all_findings:
        seen_hashes.setdefault(f["content_hash"], []).append(Path(f["file"]).name)
    duplicates = {h: names for h, names in seen_hashes.items() if len(names) > 1}

    out.append(f"- **Files audited:** {len(all_findings)}")
    out.append(f"- **Records scanned:** {total_records}")
    out.append(f"- **Violations:** {total_violations}")
    out.append(f"- **JSON errors:** {total_json_errors}")
    out.append(f"- **Files needing normalization:** {files_needing_norm}")
    out.append(f"- **Duplicate files:** {len(duplicates)}")
    out.append("")

    if duplicates:
        out.append("## Duplicates")
        out.append("")
        for h, names in duplicates.items():
            out.append(f"- {', '.join(names)} share content hash `{h[:12]}`")
        out.append("")

    if files_needing_norm:
        out.append("## Files needing normalization")
        out.append("")
        out.append("Re-run with `--normalize-in-place` to fix:")
        out.append("")
        for f in all_findings:
            if f["needs_normalization"]:
                out.append(f"- `{Path(f['file']).name}`")
        out.append("")

    # Unknown speakers across all files (info, not violation).
    all_unknown: dict[str, list[str]] = {}
    for f in all_findings:
        for speaker, count in f.get("unknown_speakers", {}).items():
            all_unknown.setdefault(speaker, []).append(
                f"{Path(f['file']).name} ({count})"
            )

    if all_unknown:
        out.append("## Unknown speakers (info — not counted as violations)")
        out.append("")
        out.append(
            "These speaker names appeared in the data but aren't in "
            "`CANONICAL_SPEAKERS` in `voice_audit.py`. Either they're "
            "legitimate new NPCs (extend the list) or typos (fix the source)."
        )
        out.append("")
        for speaker in sorted(all_unknown):
            files_str = ", ".join(all_unknown[speaker])
            out.append(f"- `{speaker}` — in {files_str}")
        out.append("")

    out.append("## Violations by file")
    out.append("")

    clean_files: list[str] = []
    for f in sorted(all_findings, key=lambda x: -len(x["violations"])):
        name = Path(f["file"]).name
        if not f["violations"] and not f["json_errors"]:
            clean_files.append(name)
            continue

        out.append(f"### {name}")
        out.append(f"_{f['record_count']} records, {len(f['violations'])} violations_")
        out.append("")

        for err in f["json_errors"]:
            out.append(f"- **JSON ERROR L{err['line']}:** {err['error']}")

        for v in f["violations"][:50]:
            speaker = v["speaker"]
            scene = v["scene"] or "?"
            chapter = v["chapter"] or "?"
            out.append(
                f"- **L{v['line']}** `{v['record_id']}` "
                f"({speaker}, {chapter}/{scene})"
            )
            out.append(f"  > {v['text']}")
            for issue in v["issues"]:
                out.append(f"  - {issue}")
        if len(f["violations"]) > 50:
            out.append(f"- _(... {len(f['violations']) - 50} more violations omitted)_")
        out.append("")

    if clean_files:
        out.append("## Clean files")
        out.append("")
        out.append(", ".join(f"`{n}`" for n in clean_files))
        out.append("")

    if total_violations == 0 and total_json_errors == 0:
        out.append("**No violations found.** Files are clean and ready to commit.")
        out.append("")

    return "\n".join(out)


def render_json(all_findings: list[dict]) -> str:
    return json.dumps(all_findings, indent=2, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("files", nargs="+", help="JSONL files to audit")
    ap.add_argument(
        "--normalize-in-place",
        action="store_true",
        help="Apply text normalization to each file (writes back).",
    )
    ap.add_argument(
        "--auto-fix",
        action="store_true",
        help="Apply mechanical Rule A/B fixes to each file (writes back). "
             "Speaker-aware: rewrites bare Cula/Murrow per the speaker's circle. "
             "Run after normalization, then re-audit to see what's left.",
    )
    ap.add_argument(
        "--report-format",
        choices=["markdown", "json"],
        default="markdown",
    )
    ap.add_argument(
        "--output",
        help="Write report to file instead of stdout.",
    )
    args = ap.parse_args()

    paths: list[Path] = []
    for s in args.files:
        p = Path(s)
        if p.is_dir():
            paths.extend(sorted(p.glob("*.jsonl")))
        elif p.exists():
            paths.append(p)
        else:
            print(f"warning: not found: {s}", file=sys.stderr)

    if not paths:
        print("error: no input files matched", file=sys.stderr)
        return 2

    all_findings: list[dict] = []
    auto_fix_summary: list[dict] = []
    for path in paths:
        if args.normalize_in_place:
            raw = path.read_text(encoding="utf-8")
            normalized = normalize_text(raw)
            if normalized != raw:
                path.write_text(normalized, encoding="utf-8")
                print(f"normalized: {path.name}", file=sys.stderr)
        if args.auto_fix:
            summary = auto_fix_file(path)
            if summary["records_fixed"]:
                auto_fix_summary.append(summary)
                print(
                    f"auto-fixed: {path.name} "
                    f"({summary['records_fixed']} records, "
                    f"{summary['total_fixes_applied']} fixes)",
                    file=sys.stderr,
                )
        all_findings.append(audit_file(path))

    if auto_fix_summary:
        total_records = sum(s["records_fixed"] for s in auto_fix_summary)
        total_fixes = sum(s["total_fixes_applied"] for s in auto_fix_summary)
        print(
            f"\nauto-fix totals: {total_records} records changed, "
            f"{total_fixes} fixes applied across {len(auto_fix_summary)} files.",
            file=sys.stderr,
        )

    if args.report_format == "markdown":
        report = render_markdown(all_findings)
    else:
        report = render_json(all_findings)

    if args.output:
        Path(args.output).write_text(report, encoding="utf-8")
        print(f"report written: {args.output}", file=sys.stderr)
    else:
        print(report)

    total_violations = sum(len(f["violations"]) for f in all_findings)
    total_json_errors = sum(len(f["json_errors"]) for f in all_findings)
    if total_json_errors:
        return 2
    if total_violations:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
