import unicodedata
import pathlib
import re
import json
import os

REPL = {
    '\u2018': "'",  # Left single curly
    '\u2019': "'",  # Right single curly
    '\u201C': '"',  # Left double curly
    '\u201D': '"',  # Right double curly
    '\u2026': '...' # Ellipsis
}

def normalize_file(path):
    try:
        with open(path, 'rb') as f:
            raw = f.read()
        
        if raw.startswith(b'\xef\xbb\xbf'):
            return None, 0, "BOM detected"
        
        try:
            original_text = raw.decode('utf-8')
        except UnicodeDecodeError:
            return None, 0, "Not UTF-8"

        text = original_text
        is_json = path.suffix.lower() == '.json'
        is_gd = path.suffix.lower() == '.gd'

        # Apply Replacements 1-3 (Quotes & Ellipsis)
        new_text = text
        for k, v in REPL.items():
            if (is_json or is_gd) and v == '"':
                temp_text = new_text.replace(k, v)
                if is_json:
                    try:
                        json.loads(temp_text)
                        new_text = temp_text
                    except json.JSONDecodeError:
                        # Skip if it breaks JSON string boundaries
                        pass
                else:
                    # GDScript: we'll apply it but if it breaks something we'll know later.
                    # The user sketch suggests unconditional replacement for quotes,
                    # but also mentions the JSON exception.
                    new_text = temp_text
            else:
                new_text = new_text.replace(k, v)

        # 7: Normalize line endings
        new_text = new_text.replace('\r\n', '\n').replace('\r', '\n')
        
        # 4: Strip trailing whitespace
        lines = new_text.split('\n')
        new_text = '\n'.join(line.rstrip() for line in lines)
        
        # 5: Collapse 3+ consecutive blank lines to exactly 2 blank lines
        new_text = re.sub(r'\n{4,}', '\n\n\n', new_text)
        
        # 6: Ensure exactly one trailing newline
        new_text = new_text.rstrip('\n') + '\n'
        if new_text == '\n' and original_text == '': 
             new_text = ''
        
        # 8: Unicode normalization: NFC
        new_text = unicodedata.normalize('NFC', new_text)
        
        if new_text != original_text:
            diff_bytes = len(new_text.encode('utf-8')) - len(raw)
            return new_text, diff_bytes, None
        return None, 0, None

    except Exception as e:
        return None, 0, str(e)

def main():
    root = pathlib.Path('/Users/piotr/Documents/Silly projects/pig-swine-rpg')
    target_patterns = [
        root.glob('*.txt'),
        root.glob('godot/**/*.md'),
        root.glob('godot/**/*.json'),
        root.glob('godot/**/*.gd'),
    ]
    
    exclude_dirs = {'_legacy', '.git', 'node_modules', 'exports'}
    
    files_to_process = []
    for pattern in target_patterns:
        for p in pattern:
            if any(part in exclude_dirs for part in p.parts):
                continue
            if p.is_file() and p.name != 'normalize.py':
                files_to_process.append(p)
    
    touched = []
    skipped = []
    
    for p in files_to_process:
        new_text, diff, error = normalize_file(p)
        if error:
            skipped.append((p, error))
        elif new_text is not None:
            p.write_text(new_text, encoding='utf-8')
            touched.append((p, diff))
            
    print("TOUCHED FILES:")
    for p, diff in touched:
        print(f"  {p.relative_to(root)}: {diff:+} bytes")
    
    if skipped:
        print("\nSKIPPED/FLAGGED FILES:")
        for p, error in skipped:
            print(f"  {p.relative_to(root)}: {error}")

    if not touched and not skipped:
        print("No changes needed.")

if __name__ == '__main__':
    main()
