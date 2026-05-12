import os
import re
import uuid

scenes = [
    "godot/scenes/interiors/archive_room.tscn",
    "godot/scenes/interiors/cafe_paragraf.tscn",
    "godot/scenes/interiors/pig_swine_office.tscn"
]

npcs = {
    "Crab": "crab",
    "Whimsy": "whimsy",
    "Asia": "asia",
    "MrPig": "mr_pig",
    "Murrow": "murrow"
}

def generate_uid():
    return "uid://" + "".join(re.findall(r"[a-z0-9]", str(uuid.uuid4())))[:13]

for scene in scenes:
    if not os.path.exists(scene): continue
    
    with open(scene, "r") as f:
        content = f.read()
        
    if "npc_walking_canon.tscn" not in content:
        ext_res_canon = f'[ext_resource type="PackedScene" uid="{generate_uid()}" path="res://scenes/components/npc_walking_canon.tscn" id="1_canon"]\n'
        matches = list(re.finditer(r'\[ext_resource .*?\]\n', content))
        if matches:
            last_idx = matches[-1].end()
            content = content[:last_idx] + ext_res_canon + content[last_idx:]
    
    canon_id_match = re.search(r'\[ext_resource .*? path="res://scenes/components/npc_walking_canon\.tscn" id="([^"]+)"\]', content)
    canon_id = canon_id_match.group(1) if canon_id_match else "1_canon"
    
    for npc_name, npc_key in npcs.items():
        if f'parent="{npc_name}"' in content or f'node name="{npc_name}"' in content:
            frames_path = f'res://art/sprites/{npc_key}/{npc_key}_sprite_frames.tres'
            frames_match = re.search(r'\[ext_resource .*? path="' + re.escape(frames_path) + r'" id="([^"]+)"\]', content)
            
            if frames_match:
                frames_id = frames_match.group(1)
            else:
                frames_id = f"frames_{npc_key}"
                ext_res = f'[ext_resource type="SpriteFrames" uid="{generate_uid()}" path="{frames_path}" id="{frames_id}"]\n'
                matches = list(re.finditer(r'\[ext_resource .*?\]\n', content))
                if matches:
                    last_idx = matches[-1].end()
                    content = content[:last_idx] + ext_res + content[last_idx:]
                    
            original_match = re.search(r'\[node name="Visual" (type="[^"]+" )?parent="' + npc_name + r'"( unique_id=\d+)?\]\n(?:[^\[]*\n)*', content)
            
            if original_match:
                orig_str = original_match.group(0)
                pos_match = re.search(r'^position = (.*?)$', orig_str, re.MULTILINE)
                unique_match = original_match.group(2) or ""
                
                new_node = f'[node name="Visual" parent="{npc_name}" instance=ExtResource("{canon_id}"){unique_match}]\n'
                if pos_match:
                    new_node += f'position = {pos_match.group(1)}\n'
                new_node += f'sprite_frames = ExtResource("{frames_id}")\n\n'
                
                content = content[:original_match.start()] + new_node + content[original_match.end():]
                
    with open(scene, "w") as f:
        f.write(content)
        
print("Updated scenes")
