#!/usr/bin/env python3
"""
fanout_cula.py — read-only F4 unblock tool.

`godot/data/dialogues/cula.json` is dispatched ONLY by the family-photo
interactable (Signals.dialogue_requested('cula', ...)). Every other state in
the file — Cula's Beat 1–14 reactions, dwells, stance carriers, internal
echoes — is unreachable at runtime until its content has been inlined into
the NPC file whose interactable trigger fires the scene (pig.json,
murrow.json, crab.json, whimsy.json, asia.json, halina.json,
judge_district_ch1.json, postcard_swine_ch1.json).

This script does NOT write into any game-data JSON. It reads cula.json,
classifies each state by its likely target NPC file, checks whether the
target file already carries a Cula-line state for the same beat/trigger
context, and emits two artefacts:

  1. outputs/fanout_cula_report.json     — machine-readable patch candidates
  2. outputs/fanout_cula_report.md       — human-readable Markdown summary

A "patch candidate" is a structured suggestion of where a cula.json state
should be inlined. Each entry carries:

  - source_state_id      cula.json state id
  - target_file          relative path inside godot/data/dialogues/
  - target_beat          inferred beat tag (beat1..beat14)
  - trigger              cula.json trigger string, copied verbatim
  - speaker              "cula" or "cula_internal"
  - payload_summary      lines / options preview, first 80 chars per slot
  - already_present      heuristic: did target file already mention this id
                          in a comment, or carry a state whose trigger
                          predicates overlap the source predicate?
  - notes                free-text caveats (LOAD_BEARING tags, dwell chains,
                          missing target file, etc.)

Family-photo states (`family_photo_ch1`, `family_photo_ch1_repeat`) are
explicitly preserved in cula.json and emitted as `target_file: <stay>` so the
diff is honest. internal/standalone states with no NPC anchor (e.g. office
return monologue, archive setup) are emitted as `target_file: <ambient>`
with a recommended placement context.

Usage:
    python3 tools/fanout_cula.py
    python3 tools/fanout_cula.py --strict-exit    # exit 1 if any UNRESOLVED

The script is idempotent. It never edits cula.json or any dialogue file.
The eventual real fan-out step is human-authored or a separate writer
script that consumes this report.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent
CULA_PATH = REPO_ROOT / "godot" / "data" / "dialogues" / "cula.json"
DIALOGUES_DIR = REPO_ROOT / "godot" / "data" / "dialogues"
OUTPUTS_DIR = REPO_ROOT / "tools" / "fanout_reports"

# Tag-driven NPC routing. Order matters only for ambiguity: id-pattern wins
# over tag-set.
TAG_TO_NPC = {
    "asia": "asia.json",
    "pig": "pig.json",
    "murrow": "murrow.json",
    "crab": "crab.json",
    "whimsy": "whimsy.json",
    "halina": "halina.json",
}

# id-pattern routing: cula_b{N}_{npc}_...  picks up the NPC token directly.
ID_NPC_PATTERN = re.compile(r"^cula_b\d+_([a-z]+)_")

# Beats that fan out into the courtroom file rather than a single-NPC file.
COURT_BEATS = {"beat12"}
COURT_TARGET = "judge_district_ch1.json"

# Beats that land in the postcard interactable scene.
POSTCARD_BEATS = {"beat14"}
POSTCARD_TARGET = "postcard_swine_ch1.json"

# Tags that pin a state to cula.json itself.
STAY_IN_CULA_IDS = {"family_photo_ch1", "family_photo_ch1_repeat"}

# Ambient / archive-room states with no single-NPC anchor.
AMBIENT_BEATS_NO_NPC = {"beat9", "beat13"}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------


def route_state(state: dict) -> tuple[str, str]:
    """Return (target_file, route_reason).

    target_file is one of:
        <stay>           — keep in cula.json
        <ambient>        — internal/standalone, no NPC anchor
        <unresolved>     — needs human review
        a basename       — pig.json, murrow.json, ...
    """
    sid = state.get("id", "")
    tags = set(state.get("tags", []))

    if sid in STAY_IN_CULA_IDS:
        return "<stay>", "preserved family-photo dispatch"

    # id-pattern wins
    m = ID_NPC_PATTERN.match(sid)
    if m:
        token = m.group(1)
        if token in TAG_TO_NPC:
            return TAG_TO_NPC[token], f"id-token '{token}'"

    # courtroom rounds
    if tags & COURT_BEATS or "court" in tags:
        return COURT_TARGET, "court beat tag"

    # postcard stinger
    if tags & POSTCARD_BEATS or "postcard" in tags:
        return POSTCARD_TARGET, "postcard tag"

    # tag-based NPC
    for t in tags:
        if t in TAG_TO_NPC:
            return TAG_TO_NPC[t], f"tag '{t}'"

    # ambient internal-only
    beat_tags = {t for t in tags if t.startswith("beat")}
    is_internal = "internal" in tags or state.get("speaker", "") == "cula_internal"
    if is_internal and (beat_tags & AMBIENT_BEATS_NO_NPC or not (tags & set(TAG_TO_NPC))):
        return "<ambient>", "internal monologue without NPC anchor"

    return "<unresolved>", "no id-token, no NPC tag, no beat heuristic match"


# ---------------------------------------------------------------------------
# Payload summary
# ---------------------------------------------------------------------------


def summarize_payload(state: dict) -> dict:
    summary = {}
    if "lines" in state:
        summary["lines"] = [ln[:80] for ln in state["lines"]]
    if "options" in state:
        opts = state["options"]
        summary["options"] = {
            "write_path": opts.get("write_path"),
            "chain": opts.get("chain", False),
            "choices": [
                {"text": c.get("text", "")[:60], "value": c.get("value", "")}
                for c in opts.get("choices", [])
            ],
        }
    if state.get("silent"):
        summary["silent"] = True
    if state.get("once"):
        summary["once"] = True
    return summary


# ---------------------------------------------------------------------------
# Target-file overlap heuristic
# ---------------------------------------------------------------------------


def load_target(target: str) -> dict | None:
    if target.startswith("<"):
        return None
    path = DIALOGUES_DIR / target
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return None


def already_present(source_state: dict, target_data: dict | None) -> tuple[bool, str]:
    """Loose heuristic: does the target file already carry this content?

    Checked signals:
      - exact id match in target.states[]
      - target state whose `trigger` string is a substring of (or equal to)
        the source trigger
      - mention of source id in any target `_comment` or `_authoring_note`
    """
    if target_data is None:
        return False, "target file unreadable or absent"

    sid = source_state.get("id", "")
    strig = (source_state.get("trigger") or "").strip()
    target_states = target_data.get("states", [])

    for ts in target_states:
        if ts.get("id") == sid:
            return True, f"target state id '{sid}' exists"
        ttrig = (ts.get("trigger") or "").strip()
        if strig and ttrig and (strig == ttrig or strig in ttrig):
            return True, f"trigger overlap with target state '{ts.get('id')}'"

    blob = json.dumps(target_data, ensure_ascii=False)
    if sid and sid in blob:
        return True, f"source id '{sid}' referenced in target _comment"

    return False, "no match"


# ---------------------------------------------------------------------------
# Beat extraction
# ---------------------------------------------------------------------------

BEAT_PATTERN = re.compile(r"\bbeat(\d+)\b")


def infer_beat(state: dict) -> str | None:
    tags = state.get("tags", [])
    for t in tags:
        m = BEAT_PATTERN.match(t)
        if m:
            return f"beat{m.group(1)}"
    sid = state.get("id", "")
    m = re.match(r"cula_b(\d+)_", sid)
    if m:
        return f"beat{m.group(1)}"
    return None


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def build_candidates(cula: dict) -> list[dict]:
    target_cache: dict[str, dict | None] = {}
    candidates: list[dict] = []

    for state in cula.get("states", []):
        target, reason = route_state(state)
        if target not in target_cache:
            target_cache[target] = load_target(target)
        present, present_reason = already_present(state, target_cache[target])

        notes = []
        if "LOAD_BEARING" in state.get("tags", []):
            notes.append("LOAD_BEARING — verify ownership before moving")
        if any("LOAD_BEARING" in t for t in state.get("tags", [])):
            notes.append("carries LOAD_BEARING tag variant")
        if state.get("speaker") == "cula_internal":
            notes.append("cula_internal speaker — render as internal echo, not dialogue line")
        if "_comment" in state and "fan-out" in state.get("_comment", "").lower():
            notes.append("source _comment already flags fan-out need")

        candidates.append(
            {
                "source_state_id": state.get("id"),
                "target_file": target,
                "route_reason": reason,
                "target_beat": infer_beat(state),
                "trigger": state.get("trigger", ""),
                "speaker": state.get("speaker", "cula"),
                "tags": state.get("tags", []),
                "payload_summary": summarize_payload(state),
                "already_present": present,
                "already_present_reason": present_reason,
                "notes": notes,
            }
        )

    return candidates


def render_markdown(candidates: list[dict]) -> str:
    lines: list[str] = []
    lines.append("# fanout_cula — patch candidates")
    lines.append("")
    lines.append(f"Source: `godot/data/dialogues/cula.json` ({len(candidates)} states inspected)")
    lines.append("")
    by_target: dict[str, list[dict]] = {}
    for c in candidates:
        by_target.setdefault(c["target_file"], []).append(c)
    lines.append("## Summary")
    lines.append("")
    lines.append("| target | count | already_present |")
    lines.append("|---|---|---|")
    for t in sorted(by_target):
        bucket = by_target[t]
        present_count = sum(1 for c in bucket if c["already_present"])
        lines.append(f"| `{t}` | {len(bucket)} | {present_count} |")
    lines.append("")
    for t in sorted(by_target):
        lines.append(f"## {t}")
        lines.append("")
        for c in by_target[t]:
            tick = "[x]" if c["already_present"] else "[ ]"
            lines.append(f"### {tick} `{c['source_state_id']}` ({c['target_beat']})")
            lines.append("")
            lines.append(f"- route: {c['route_reason']}")
            lines.append(f"- trigger: `{c['trigger']}`")
            lines.append(f"- speaker: `{c['speaker']}`")
            if c["payload_summary"]:
                payload_json = json.dumps(c["payload_summary"], ensure_ascii=False, indent=2)
                lines.append("- payload:")
                lines.append("```json")
                lines.append(payload_json)
                lines.append("```")
            if c["already_present"]:
                lines.append(f"- already_present: {c['already_present_reason']}")
            for n in c["notes"]:
                lines.append(f"- note: {n}")
            lines.append("")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument(
        "--strict-exit",
        action="store_true",
        help="exit code 1 if any state routes to <unresolved>",
    )
    parser.add_argument(
        "--output-dir",
        default=str(OUTPUTS_DIR),
        help="where to write the report (default: tools/fanout_reports/)",
    )
    args = parser.parse_args(argv)

    if not CULA_PATH.exists():
        print(f"FATAL: cula.json not found at {CULA_PATH}", file=sys.stderr)
        return 2

    cula = json.loads(CULA_PATH.read_text())
    candidates = build_candidates(cula)

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    (out_dir / "fanout_cula_report.json").write_text(
        json.dumps(
            {
                "source": "godot/data/dialogues/cula.json",
                "total_states": len(candidates),
                "candidates": candidates,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n"
    )
    (out_dir / "fanout_cula_report.md").write_text(render_markdown(candidates) + "\n")

    unresolved = [c for c in candidates if c["target_file"] == "<unresolved>"]
    by_target: dict[str, int] = {}
    for c in candidates:
        by_target[c["target_file"]] = by_target.get(c["target_file"], 0) + 1
    print(f"fanout_cula: {len(candidates)} states inspected")
    for t in sorted(by_target):
        print(f"  {by_target[t]:3d}  {t}")
    print(f"reports written to {out_dir}/")

    if args.strict_exit and unresolved:
        print(f"STRICT: {len(unresolved)} unresolved", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
