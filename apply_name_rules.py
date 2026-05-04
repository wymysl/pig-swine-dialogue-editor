import re
import os
import json

TYPE1_FILES = [
    "godot/PLAN.md",
    "godot/MANAGING_AGENTS.md",
    "godot/CURATION_BOARD.md",
    "godot/PROPOSALS.md",
    "godot/.antigravity/skills/design.md",
    "godot/.antigravity/skills/code.md",
    "godot/.antigravity/skills/art.md",
    "godot/.antigravity/skills/qa.md",
    "world.txt",
    "minigames.txt",
    "battle_mechanics.txt"
]

TYPE2_FILES = [
    "story.txt",
    "dialogue_samples.txt",
    "style_canon.txt"
]

TYPE3_FILES = [
    "godot/data/asia_hints.json"
]

REPORT = {
    "files": {},
    "flagged": []
}

def apply_rule_a(text):
    original = text
    text = re.sub(r'\bMr\. Murrow\b', 'Murrow', text)
    text = re.sub(r'\bDoctor Cula\b', 'Dr. A. Cula', text)
    text = re.sub(r'\bDr\. Cula\b', 'Dr. A. Cula', text)
    text = re.sub(r'\b[Tt]he doctor\b', 'Dr. A. Cula', text)
    text = re.sub(r'(?<!Dr\. A\. )(?<!Dr\. )\bCula\b', 'Dr. A. Cula', text)
    
    # Edge case cleanup where "Dr. A. Dr. A. Cula" might have been accidentally created?
    # Not possible with the lookbehinds.
    
    return text, original != text

def apply_rule_b(text, speaker, is_after_chapter1=True):
    original = text
    speaker = speaker.lower() if speaker else ""
    
    is_inner = False
    inner_recruited = is_after_chapter1
    
    if "crab" in speaker or "rak" in speaker or "whimsy" in speaker or "wymysl" in speaker:
        is_inner = True
        
    is_cula = "cula" in speaker

    # 1. Murrow
    if is_inner or is_cula or "system" in speaker:
        text = re.sub(r'\bMr\. Murrow\b', 'Murrow', text)
    else:
        text = re.sub(r'(?<!Mr\. )\bMurrow\b', 'Mr. Murrow', text)
        
    # 2. Cula
    if is_inner and inner_recruited:
        text = re.sub(r'\bDr\. A\. Cula\b', 'Cula', text)
        text = re.sub(r'\bDr\. Cula\b', 'Cula', text)
        text = re.sub(r'\bDoctor Cula\b', 'Cula', text)
        text = re.sub(r'\b[Tt]he doctor\b', 'Cula', text)
    else:
        text = re.sub(r'\bDoctor Cula\b', 'Dr. A. Cula', text)
        text = re.sub(r'\bDr\. Cula\b', 'Dr. A. Cula', text)
        text = re.sub(r'\b[Tt]he doctor\b', 'Dr. A. Cula', text)
        text = re.sub(r'(?<!Dr\. A\. )(?<!Dr\. )\bCula\b', 'Dr. A. Cula', text)

    return text, original != text

def process_type1():
    for fpath in TYPE1_FILES:
        if not os.path.exists(fpath):
            continue
        with open(fpath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # We process line by line to keep track of counts properly
        lines = content.split('\n')
        new_lines = []
        changes = 0
        for line in lines:
            new_line, changed = apply_rule_a(line)
            if changed:
                changes += 1
            new_lines.append(new_line)
            
        REPORT["files"][fpath] = {
            "before": len(lines),
            "after": len(new_lines),
            "replacements": changes
        }
        
        with open(fpath, "w", encoding="utf-8") as f:
            f.write('\n'.join(new_lines))

def process_type3():
    for fpath in TYPE3_FILES:
        if not os.path.exists(fpath):
            continue
        with open(fpath, "r", encoding="utf-8") as f:
            data = json.load(f)
            
        # This is asia_hints.json
        # Format is {"states": [ {"npc_id": "asia", "text": "...", ...} ]}
        
        changes = 0
        original_lines = len(open(fpath).read().split('\n'))
        
        if "states" in data:
            for state in data["states"]:
                if "text" in state:
                    new_text, changed = apply_rule_b(state["text"], state.get("npc_id", "asia"))
                    if changed:
                        state["text"] = new_text
                        changes += 1
                        
        with open(fpath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)
            
        new_lines = len(open(fpath).read().split('\n'))
        REPORT["files"][fpath] = {
            "before": original_lines,
            "after": new_lines,
            "replacements": changes
        }

def get_speaker_from_context(prev_lines, current_line):
    # Try to find a speaker in the current line
    m = re.match(r'^(?:> )?\s*([A-Za-z \.A]+)\s*:', current_line)
    if m:
        speaker = m.group(1).lower()
        if "murrow" in speaker: return "murrow"
        if "cula" in speaker: return "dr. a. cula"
        if "crab" in speaker or "rak" in speaker: return "crab"
        if "whimsy" in speaker or "wymysl" in speaker: return "whimsy"
        if "pig" in speaker: return "mr. pig"
        if "swine" in speaker: return "mr. swine"
        if "asia" in speaker: return "asia"
        if "judge" in speaker or "arbitrator" in speaker: return "judge"
        if "opponent" in speaker or "counsel" in speaker or "szpon" in speaker: return "opponent"
        if "sign" in speaker or "notice" in speaker or "blocker" in speaker or "objective" in speaker or "docket" in speaker or "text" in speaker: return "system"
        if "npc" in speaker or "guard" in speaker or "tenant" in speaker or "woman" in speaker or "clerk" in speaker or "courier" in speaker: return "npc"
    
    # Look back up to 5 lines
    for line in reversed(prev_lines[-5:]):
        line_lower = line.lower()
        if line.startswith("### "):
            header = line[4:].lower()
            if "sign" in header or "notice" in header: return "system"
            if "court line" in header: return "unclear_court" # could be anyone
            if "dr. cula" in header or "dr. a. cula" in header: return "dr. a. cula"
            if "pig" in header: return "mr. pig"
            if "swine" in header: return "mr. swine"
            if "murrow" in header: return "murrow"
            if "crab" in header: return "crab"
            if "whimsy" in header: return "whimsy"
            if "asia" in header: return "asia"
            return header.strip()
            
        if "sample asia line" in line_lower: return "asia"
        if "mr. pig line" in line_lower: return "mr. pig"
        if "murrow line" in line_lower or "murrow:" in line_lower: return "murrow"
        if "crab line" in line_lower or "crab:" in line_lower: return "crab"
        if "whimsy line" in line_lower or "whimsy:" in line_lower: return "whimsy"
        if "sign text" in line_lower or "notice board" in line_lower or "blocker:" in line_lower or "docket board" in line_lower or "objective:" in line_lower or "text:" in line_lower: return "system"
        if "dr. a. cula:" in line_lower or "cula:" in line_lower: return "dr. a. cula"
        if "judge:" in line_lower or "asks:" in line_lower: return "judge"
        if "tenant:" in line_lower or "courier:" in line_lower or "woman:" in line_lower: return "npc"

    return None

def process_type2():
    for fpath in TYPE2_FILES:
        if not os.path.exists(fpath):
            continue
        with open(fpath, "r", encoding="utf-8") as f:
            lines = f.read().split('\n')
            
        new_lines = []
        changes = 0
        
        # Heuristic for recruitment timing: If it's chapter 1, we assume post-recruitment unless it explicitly says "Before"
        # The prompt says: "If a sample line is from a character whose recruitment-scene timing is unclear... apply the post-recruitment form... and note the assumption"
        
        for i, line in enumerate(lines):
            # Check if line has quotes or blockquote that implies dialogue
            is_dialogue = False
            if line.strip().startswith(">") and ("“" in line or '"' in line or "!" in line or "." in line):
                is_dialogue = True
            elif line.strip().startswith("“") or line.strip().startswith('"'):
                is_dialogue = True
                
            # Or if it's a quote inline? (Assuming mostly block-level quotes based on previous parsing)
            # Find quoted substrings
            
            # If not a dialogue line, apply Rule A
            if not is_dialogue:
                # Actually, some dialogue might be inline like `Murrow: "Good."`
                # Let's apply Rule A to the non-quoted parts, and Rule B to the quoted parts.
                # To be safe, if we find quotes on a line, we extract the quote, apply Rule B, and apply Rule A to the rest.
                pass
                
            # Let's do a more robust string replacement:
            # Find all text inside double quotes (straight or smart)
            quotes = re.finditer(r'(["“].*?["”])', line)
            
            new_line = line
            line_changed = False
            
            # Find all quotes
            quote_matches = list(quotes)
            
            if quote_matches or is_dialogue:
                # Need to determine speaker
                speaker = get_speaker_from_context(lines[:i], line)
                is_after_chap1 = True
                
                # Check surrounding context for "Before recruitment" or similar
                context = " ".join(lines[max(0, i-5):min(len(lines), i+2)]).lower()
                if "before recruitment" in context or "initial crab line" in context or "before speaking" in context or "before crab is recruited" in context:
                    is_after_chap1 = False
                
                if speaker is None:
                    # Halt and report
                    if "Cula" in line or "Murrow" in line:
                        REPORT["flagged"].append(f"Unclear speaker in {fpath}:{i+1} -> {line}")
                    # Apply rule A to the whole line as fallback for now
                    new_line, chg = apply_rule_a(line)
                    if chg: line_changed = True
                elif speaker == "unclear_court":
                    REPORT["flagged"].append(f"Unclear court speaker in {fpath}:{i+1} -> {line}")
                    new_line, chg = apply_rule_a(line)
                    if chg: line_changed = True
                else:
                    if is_dialogue and not quote_matches:
                        # Whole line is dialogue (e.g. > The notice says...)
                        new_line, chg = apply_rule_b(line, speaker, is_after_chap1)
                        if chg: line_changed = True
                    else:
                        # Only apply Rule B to the quoted substrings, Rule A to the rest
                        offset = 0
                        for m in quote_matches:
                            start, end = m.span()
                            start += offset
                            end += offset
                            
                            prefix = new_line[:start]
                            quote_text = new_line[start:end]
                            suffix = new_line[end:]
                            
                            new_prefix, _ = apply_rule_a(prefix)
                            new_quote, _ = apply_rule_b(quote_text, speaker, is_after_chap1)
                            
                            new_line = new_prefix + new_quote + suffix
                            offset += (len(new_prefix) - len(prefix)) + (len(new_quote) - len(quote_text))
                            
                        # Apply Rule A to the very last suffix
                        if quote_matches:
                            last_end = quote_matches[-1].end() + offset # approx
                            # actually easier to just apply Rule A to the whole line excluding the quotes?
                            # the above iterative replacement already did prefix. Let's just do the final suffix.
                            # The loop leaves the final suffix unprocessed.
                            
                        # A simpler way:
                        # Split by quotes, process odd indices with Rule B, even with Rule A
            else:
                new_line, chg = apply_rule_a(line)
                if chg: line_changed = True
                
            # Simpler exact quote splitting to be perfectly safe:
            if quote_matches:
                parts = re.split(r'(["“].*?["”])', line)
                reconstructed = ""
                for idx, p in enumerate(parts):
                    if idx % 2 == 1: # Quoted string
                        speaker = get_speaker_from_context(lines[:i], line)
                        is_after_chap1 = True
                        context = " ".join(lines[max(0, i-5):min(len(lines), i+2)]).lower()
                        if "before recruitment" in context or "initial crab line" in context or "before speaking" in context or "before crab is recruited" in context:
                            is_after_chap1 = False
                            
                        if speaker is None:
                            if "Cula" in p or "Murrow" in p:
                                REPORT["flagged"].append(f"Unclear speaker in {fpath}:{i+1} -> {p}")
                            new_p, _ = apply_rule_a(p)
                        elif speaker == "unclear_court":
                            if "Cula" in p or "Murrow" in p:
                                REPORT["flagged"].append(f"Unclear court speaker in {fpath}:{i+1} -> {p}")
                            new_p, _ = apply_rule_a(p)
                        else:
                            new_p, _ = apply_rule_b(p, speaker, is_after_chap1)
                        reconstructed += new_p
                    else:
                        new_p, _ = apply_rule_a(p)
                        reconstructed += new_p
                new_line = reconstructed
                line_changed = (new_line != line)
            elif is_dialogue and not quote_matches:
                speaker = get_speaker_from_context(lines[:i], line)
                is_after_chap1 = True
                context = " ".join(lines[max(0, i-5):min(len(lines), i+2)]).lower()
                if "before recruitment" in context or "initial crab line" in context or "before speaking" in context or "before crab is recruited" in context:
                    is_after_chap1 = False
                
                if speaker is None:
                    if "Cula" in line or "Murrow" in line:
                        REPORT["flagged"].append(f"Unclear speaker in {fpath}:{i+1} -> {line}")
                    new_line, _ = apply_rule_a(line)
                elif speaker == "unclear_court":
                    if "Cula" in line or "Murrow" in line:
                        REPORT["flagged"].append(f"Unclear court speaker in {fpath}:{i+1} -> {line}")
                    new_line, _ = apply_rule_a(line)
                else:
                    new_line, _ = apply_rule_b(line, speaker, is_after_chap1)
                line_changed = (new_line != line)
                
            if line_changed:
                changes += 1
            new_lines.append(new_line)
            
        REPORT["files"][fpath] = {
            "before": len(lines),
            "after": len(new_lines),
            "replacements": changes
        }
        
        with open(fpath, "w", encoding="utf-8") as f:
            f.write('\n'.join(new_lines))

if __name__ == "__main__":
    process_type1()
    process_type3()
    process_type2()
    
    with open("report.json", "w") as f:
        json.dump(REPORT, f, indent=4)
    print("Done")
