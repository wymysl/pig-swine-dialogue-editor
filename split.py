import re
import os

def run():
    story_path = "story.txt"
    with open(story_path, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()

    story_out = []
    
    sections = {
        "Dr. Cula": [],
        "Mr. Pig": [],
        "Mr. Swine": [],
        "Murrow": [],
        "Crab": [],
        "Whimsy": [],
        "Asia": [],
        "Sign and notice text samples": [],
        "Court line samples": [],
        "Other named NPCs": []
    }
    
    def add_sample(section_name, text):
        if not section_name:
            section_name = "Uncategorized"
            
        clean_name = section_name.replace("§", "").strip()
        if clean_name not in sections:
            sections[clean_name] = []
        sections[clean_name].append(text)

    current_section = None
    i = 0
    
    def canonicalize(text):
        text = text.replace("Kula", "Cula")
        text = text.replace("Mr. Murrow", "Murrow")
        text = text.replace("Rak", "Crab")
        text = text.replace("Wymysl", "Whimsy")
        return text

    in_gdscript = False

    while i < len(lines):
        line = lines[i]
        line = canonicalize(line)
        stripped = line.strip()

        if stripped.startswith("```gdscript"):
            in_gdscript = True
            
        if in_gdscript and stripped == "```":
            in_gdscript = False

        if in_gdscript:
            # Check for return "..."
            if "return \"" in stripped or "return “" in stripped:
                # Extract the string
                m_str = re.search(r'return (["“].*?["”])', line)
                if m_str:
                    sample_text = m_str.group(1)
                    target = current_section if current_section else "Uncategorized"
                    # Default to Asia if we are in get_asia_hint
                    if "asia" in target.lower() or not current_section:
                        target = "Asia"
                    add_sample(target, "> " + sample_text)
                    # Replace with pointer
                    line = line.replace(sample_text, f'"<see dialogue_samples.txt §{target}>"')
            story_out.append(line)
            i += 1
            continue

        m = re.search(r'\(see dialogue_samples\.txt (?:§)?([^)]+)\)', line)
        if m:
            story_out.append(line)
            current_section = m.group(1).strip()
            i += 1
            
            while i < len(lines) and lines[i].strip() == "":
                story_out.append(lines[i])
                i += 1
                
            while i < len(lines):
                next_line = canonicalize(lines[i])
                stripped_next = next_line.strip()
                
                if stripped_next == "":
                    add_sample(current_section, "")
                    i += 1
                    continue
                    
                if stripped_next.startswith("###") or stripped_next.startswith("---") or "(see dialogue_samples.txt" in stripped_next:
                    break
                    
                if stripped_next.startswith("```gdscript") or stripped_next.startswith("```text"):
                    is_code_spec = False
                    peek_idx = i + 1
                    while peek_idx < len(lines) and not lines[peek_idx].strip().startswith("```"):
                        if "chapter" in lines[peek_idx] or "=" in lines[peek_idx] or "unlock" in lines[peek_idx]:
                            is_code_spec = True
                        peek_idx += 1
                    if is_code_spec:
                        break
                
                if stripped_next.startswith("“") or stripped_next.startswith('"') or stripped_next.startswith(">"):
                    add_sample(current_section, next_line)
                    i += 1
                    continue
                    
                if stripped_next.endswith(":") and len(stripped_next.split()) < 6:
                    add_sample(current_section, next_line)
                    i += 1
                    continue
                    
                break
                
            continue
            
        if stripped.startswith("“") or stripped.startswith('"'):
            target = current_section if current_section else "Uncategorized"
            add_sample(target, line)
            i += 1
            continue
            
        if stripped == "Item:":
            story_out.append(line)
            i += 1
            continue

        story_out.append(line)
        i += 1

    dialogue_path = "dialogue_samples_new.txt"
    dialogue_content = []
    
    dialogue_content.append("# Dialogue Samples — Pig & Swine RPG\n")
    dialogue_content.append("> Voice-reference library. These lines are NOT committed game text.")
    dialogue_content.append("> Design agents quote and rewrite from this file when authoring")
    dialogue_content.append("> godot/data/dialogues/dialogues.json. Every committed game line")
    dialogue_content.append("> must pass the Taste Standard 5/5 (see godot/AGENTS.md and")
    dialogue_content.append("> style_canon.txt) — that pass happens at JSON authoring time, not")
    dialogue_content.append("> here. Lines below may be drafts.\n")
    
    dialogue_content.append("## Cast voice samples\n")
    
    cast_members = ["Dr. Cula", "Mr. Pig", "Mr. Swine", "Murrow", "Crab", "Whimsy", "Asia"]
    
    for cast in cast_members:
        samples = sections.get(cast, [])
        if samples:
            dialogue_content.append(f"### {cast}")
            for s in samples:
                dialogue_content.append(s)
            dialogue_content.append("")
            
    other_npcs = []
    for section_name in sections.keys():
        if section_name not in cast_members and section_name not in ["Sign and notice text samples", "Court line samples", "Uncategorized"]:
            other_npcs.append(section_name)
            
    if other_npcs:
        for npc in other_npcs:
            samples = sections[npc]
            if samples:
                dialogue_content.append(f"### {npc}")
                for s in samples:
                    dialogue_content.append(s)
                dialogue_content.append("")
                
    if "Sign and notice text samples" in sections and sections["Sign and notice text samples"]:
        dialogue_content.append("## Sign and notice text samples")
        for s in sections["Sign and notice text samples"]:
            dialogue_content.append(s)
        dialogue_content.append("")
        
    if "Court line samples" in sections and sections["Court line samples"]:
        dialogue_content.append("## Court line samples")
        for s in sections["Court line samples"]:
            dialogue_content.append(s)
        dialogue_content.append("")
        
    if "Uncategorized" in sections and sections["Uncategorized"]:
        dialogue_content.append("## Uncategorized samples")
        for s in sections["Uncategorized"]:
            dialogue_content.append(s)
        dialogue_content.append("")

    with open("story_new.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(story_out))
        
    with open("dialogue_samples_new.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(dialogue_content))

    print(f"story_out: {len(story_out)}")
    print(f"dialogue_out: {len(dialogue_content)}")
    
if __name__ == '__main__':
    run()
