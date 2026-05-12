import os
import glob
import re

base_dir = "godot/art/sprites"
chars_to_skip = ["cula", "asia"]
all_dirs = ["front", "back", "left", "right", "front_left", "front_right", "back_left", "back_right"]

dir_map = {
    "north": "back",
    "north-west": "back_left",
    "north-east": "back_right",
    "south": "front",
    "south-west": "front_left",
    "south-east": "front_right",
    "west": "left",
    "east": "right",
    "front": "front",
    "back": "back",
    "left": "left",
    "right": "right",
    "front_left": "front_left",
    "front_right": "front_right",
    "back_left": "back_left",
    "back_right": "back_right"
}

def scan_char(char):
    char_dir = os.path.join(base_dir, char)
    
    # animations map: anim_name -> list of relative paths from res://
    animations = {
        "default": []
    }
    for d in all_dirs:
        animations[f"idle_{d}"] = []
        animations[f"walk_{d}"] = []
        animations[f"run_{d}"] = []
        
    png_files = []
    for root, _, files in os.walk(char_dir):
        for f in files:
            if f.endswith(".png"):
                png_files.append(os.path.join(root, f))
                
    png_files.sort()
    
    for f in png_files:
        rel_path = os.path.relpath(f, "godot/")
        res_path = f"res://{rel_path}"
        
        # e.g. godot/art/sprites/halina/halina_idle_back.png
        filename = os.path.basename(f)
        
        # Idle check
        idle_match = re.search(r'idle_([a-z_]+)\.png$', filename)
        if idle_match:
            d = idle_match.group(1)
            if d in dir_map:
                animations[f"idle_{dir_map[d]}"].append(res_path)
            continue
            
        # Walk/Run check
        # We can look at the directory name.
        # e.g. godot/art/sprites/murrow/walk/front/murrow_walk_front_00.png
        # or godot/art/sprites/asia/walk/north/frame_000.png
        parts = rel_path.split(os.sep)
        
        action = None
        d = None
        
        if "walk" in parts:
            action = "walk"
            idx = parts.index("walk")
            if idx + 1 < len(parts):
                d_raw = parts[idx + 1]
                if d_raw in dir_map:
                    d = dir_map[d_raw]
        elif "run" in parts:
            action = "run"
            idx = parts.index("run")
            if idx + 1 < len(parts):
                d_raw = parts[idx + 1]
                if d_raw in dir_map:
                    d = dir_map[d_raw]
                    
        if action and d:
            animations[f"{action}_{d}"].append(res_path)

    # Make sure we don't include _alt folders if they messed up the scan
    # For now, let's just sort the frames correctly.
    for k in animations:
        animations[k].sort()
        
    return animations

def generate_tres(char, animations):
    out_path = os.path.join(base_dir, char, f"{char}_sprite_frames.tres")
    
    # Collect all unique textures
    all_textures = []
    for k in animations:
        for p in animations[k]:
            if p not in all_textures:
                all_textures.append(p)
                
    with open(out_path, "w") as f:
        f.write('[gd_resource type="SpriteFrames" format=3]\n\n')
        
        # Write ext_resource
        for i, tex in enumerate(all_textures):
            f.write(f'[ext_resource type="Texture2D" path="{tex}" id="{i+1}_tex"]\n')
            
        f.write('\n[resource]\n')
        f.write('animations = [{\n')
        
        anim_keys = list(animations.keys())
        # default first
        anim_keys.remove("default")
        anim_keys = ["default"] + sorted(anim_keys)
        
        for idx, k in enumerate(anim_keys):
            f.write('"frames": [')
            frames = animations[k]
            if not frames:
                f.write(']')
            else:
                f.write('{\n')
                for fi, frame_path in enumerate(frames):
                    tex_idx = all_textures.index(frame_path) + 1
                    f.write(f'"duration": 1.0,\n"texture": ExtResource("{tex_idx}_tex")\n')
                    if fi < len(frames) - 1:
                        f.write('}, {\n')
                f.write('}]')
            
            f.write(',\n')
            f.write(f'"loop": true,\n')
            f.write(f'"name": &"{k}",\n')
            
            speed = 5.0
            if k.startswith("walk"): speed = 8.0
            if k.startswith("run"): speed = 12.0
            
            f.write(f'"speed": {speed}\n')
            if idx < len(anim_keys) - 1:
                f.write('}, {\n')
            else:
                f.write('}]\n')

for char in os.listdir(base_dir):
    if char in chars_to_skip:
        continue
    char_path = os.path.join(base_dir, char)
    if os.path.isdir(char_path):
        animations = scan_char(char)
        generate_tres(char, animations)
        print(f"Generated {char}_sprite_frames.tres")
