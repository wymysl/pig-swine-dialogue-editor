#!/usr/bin/env python3
"""
Import a Pixellab character export zip into the project's sprite tree.

Pixellab exports 8-direction character zips with this structure:

    <prompt-derived-folder-name>/
      rotations/
        south.png        north.png
        south-east.png   north-east.png
        south-west.png   north-west.png
        east.png         west.png
    metadata.json

This script extracts the 8 rotation PNGs, renames them from Pixellab's
cardinal naming to the project's camera-relative naming, downscales them
to the canonical 64×64 size, and writes them to godot/art/sprites/<char>/
following the naming pattern <char>_idle_<direction>.png.

Cardinal → camera-relative mapping (per godot/CONVENTIONS.md
§Walk-folder naming convention):

    south       → front
    south-east  → front_right
    south-west  → front_left
    east        → right
    west        → left
    north       → back
    north-east  → back_right
    north-west  → back_left

Usage:

    python3 tools/import_pixellab_zip.py <zip_path> <char_slug>

    python3 tools/import_pixellab_zip.py ~/Downloads/cula.zip cula
    python3 tools/import_pixellab_zip.py ~/Downloads/asia.zip asia --animation walk
    python3 tools/import_pixellab_zip.py ~/Downloads/pig.zip mr_pig --size 64 --dry-run

Defaults: --animation idle, --size 64.

The script refuses to overwrite an existing destination file unless
--force is passed. It also saves the Pixellab metadata.json next to
the PNGs as _pixellab_metadata.json for the matching session.
"""
from __future__ import annotations

import argparse
import json
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

from PIL import Image

CARDINAL_TO_CAMERA = {
    "south": "front",
    "south-east": "front_right",
    "south-west": "front_left",
    "east": "right",
    "west": "left",
    "north": "back",
    "north-east": "back_right",
    "north-west": "back_left",
}

REPO_ROOT = Path(__file__).resolve().parent.parent
SPRITES_DIR = REPO_ROOT / "godot" / "art" / "sprites"


def find_rotations_dir(extract_root: Path) -> Path:
    """Locate the rotations/ folder anywhere inside an extracted zip."""
    matches = list(extract_root.rglob("rotations"))
    matches = [m for m in matches if m.is_dir()]
    if not matches:
        sys.exit(
            f"FAIL: no 'rotations/' folder inside {extract_root}. "
            "Is this a Pixellab character export zip?"
        )
    if len(matches) > 1:
        sys.exit(
            f"FAIL: multiple 'rotations/' folders found in {extract_root}: "
            f"{matches}. Cannot disambiguate."
        )
    return matches[0]


def find_metadata_json(extract_root: Path) -> Path | None:
    matches = list(extract_root.rglob("metadata.json"))
    return matches[0] if matches else None


def import_zip(
    zip_path: Path,
    char_slug: str,
    animation: str,
    target_size: int,
    force: bool,
    dry_run: bool,
) -> None:
    if not zip_path.exists():
        sys.exit(f"FAIL: {zip_path} does not exist.")

    target_dir = SPRITES_DIR / char_slug
    if not target_dir.exists():
        sys.exit(
            f"FAIL: target sprite dir {target_dir} does not exist. "
            "Create it first, or check the char slug."
        )

    with tempfile.TemporaryDirectory() as tmp:
        tmp_root = Path(tmp)
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(tmp_root)

        rotations_dir = find_rotations_dir(tmp_root)
        metadata_src = find_metadata_json(tmp_root)

        # Collect the 8 expected PNGs
        plan: list[tuple[Path, Path]] = []
        missing: list[str] = []
        for cardinal, camera in CARDINAL_TO_CAMERA.items():
            src = rotations_dir / f"{cardinal}.png"
            if not src.exists():
                missing.append(cardinal)
                continue
            dest_name = (
                f"{char_slug}_{animation}_{camera}.png"
                if animation == "idle"
                else f"{char_slug}_{animation}_{camera}_00.png"
                # (walk/run framesets need a separate flow; idle is a single
                # frame per direction, walk/run are N frames per direction)
            )
            dest = target_dir / dest_name
            plan.append((src, dest))

        if missing:
            sys.exit(
                f"FAIL: zip is missing these cardinal rotations: {missing}"
            )

        # Conflict check
        conflicts = [d for _, d in plan if d.exists() and not force]
        if conflicts:
            sys.exit(
                "FAIL: refusing to overwrite existing files (pass --force to override):\n"
                + "\n".join(f"  {c}" for c in conflicts)
            )

        print(f"Plan ({len(plan)} files, target_size={target_size}):")
        for src, dest in plan:
            print(f"  {src.relative_to(tmp_root)}  →  {dest.relative_to(REPO_ROOT)}")
        if metadata_src is not None:
            md_dest = target_dir / "_pixellab_metadata.json"
            print(f"  metadata.json  →  {md_dest.relative_to(REPO_ROOT)}")

        if dry_run:
            print("\nDRY RUN — no files written.")
            return

        # Write
        for src, dest in plan:
            im = Image.open(src).convert("RGBA")
            if im.size != (target_size, target_size):
                im = im.resize((target_size, target_size), Image.NEAREST)
            im.save(dest, format="PNG")

        if metadata_src is not None:
            md_dest = target_dir / "_pixellab_metadata.json"
            md_dest.write_text(metadata_src.read_text())

    print(f"\nOK — imported {len(plan)} frames into {target_dir.relative_to(REPO_ROOT)}")
    if animation == "idle":
        print(
            "\nNote: Godot will re-import these PNGs on next editor open. "
            "If a .tres SpriteFrames resource references these files at fixed "
            "paths, no edit needed — the textures are replaced in place."
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Import a Pixellab character zip into godot/art/sprites/<char>/."
    )
    parser.add_argument("zip_path", type=Path, help="Path to the Pixellab character .zip")
    parser.add_argument(
        "char_slug",
        help="Character folder slug (e.g. cula, mr_pig, asia, halina). "
        "Must match an existing folder under godot/art/sprites/.",
    )
    parser.add_argument(
        "--animation",
        default="idle",
        choices=["idle", "walk", "run"],
        help="Animation type (default: idle). walk/run need separate per-frame handling; "
        "currently this script handles idle (one frame per direction) cleanly.",
    )
    parser.add_argument(
        "--size",
        type=int,
        default=64,
        help="Target PNG size in pixels (default: 64, the project canon).",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing files")
    parser.add_argument("--dry-run", action="store_true", help="Print the plan, do not write")
    args = parser.parse_args()

    import_zip(
        zip_path=args.zip_path.expanduser().resolve(),
        char_slug=args.char_slug,
        animation=args.animation,
        target_size=args.size,
        force=args.force,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
