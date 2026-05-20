# Shaders

## unify_post.gdshader

Screen-space post-process that forces the rendered frame through a fixed
palette with Bayer dithering. Purpose: visually unify pixel-art assets
(sprites, tilesets, office props) and painterly/illustrated assets
(building facades, street props, the wooden logo) so they read as one game
without re-art.

Files in this feature:

- `godot/shaders/unify_post.gdshader` — the shader.
- `godot/scenes/components/UnifyPost.tscn` — CanvasLayer + ColorRect wired up.
- `godot/scripts/systems/unify_post.gd` — toggle / strength logic.

## Integrating

Two options. Pick one.

**Option A — Add to Main.tscn (recommended for A/B).**

1. Open `godot/scenes/Main.tscn` in the editor.
2. Drag `scenes/components/UnifyPost.tscn` in as a child of the root.
3. In the inspector, verify `UnifyPost.layer = 5`. The world renders below
   it (layer 0) and gets the effect. Dialogue box, client stance menu, blue
   binder, case folder, and pause layers all sit at layer 10+ and render
   above the effect, so UI text stays crisp.
4. Run the project. The effect is on by default. Press **F9** to toggle.
   Hold **Shift+F9** to cycle through strength 0.0 → 0.5 → 1.0 → 0.0 for
   quick A/B at half strength.

**Option B — Add per-room.**

Useful if you want the effect in the city scenes (where the painterly
buildings live) but not in the pixel-art office (where everything already
matches). Drop `UnifyPost.tscn` into the relevant room scenes only.

## Tuning

In the running project, select the `UnifyPost` node in the SceneTree dock and
edit:

- `strength` (0.0–1.0). 0 = pass-through, 1 = full quantize. Try 0.7 first if
  full quantize feels too aggressive.
- `dither_strength` (0.0–0.15). 0 = banded posterize, 0.04 = a faint dither
  that hides bands in painterly gradients. Higher numbers visibly stipple.

## Swapping palette

Open `unify_post.gdshader`. The `PAL` array near the top holds 18 RGB triples
in 0–1 floats. Replace values to swap palette. If you add or remove rows you
must also update:

- The const declaration size: `const vec3 PAL[18]`.
- The for-loop bound: `for (int i = 0; i < 18; i++)`.

Starter palette derives from `art/palettes/marszalkowska_palette.png`. Other
swatch files in `art/palettes/` (court_interior, smog_warsaw, praga,
milk_bar, kiosk_ruch, nightlife, termomodernizacja, casebook_dark, lazienki,
praga_nowa, warsaw_mordor) are alternative starting points if a scene wants
a different mood. Per-scene palettes are a v2 — easiest implementation is a
ShaderMaterial duplicate per room with its own PAL.

## Known limitations

1. **Text inside painterly assets stays smeared.** The shader does not fix
   AI-generated text errors in `district_court.png` ("DISTRIET"),
   `kino_monumental.png` ("MONUHENTAL"), or
   `P&S_logo_wooden_board.png` ("COUHSELORS / FOSSIBLY OPEN"). These need to
   be hand-corrected at the source PNG before they ship.
2. **Sprite size mismatch (Cula 124 vs cast 112) is not affected.** Pick one
   size and re-export the odd one out; see `art/ASSET_STATUS_CH1.md`.
3. **Crisp pixel-art edges soften slightly under the dither.** If this reads
   wrong on the office set, run those rooms without UnifyPost (Option B
   above) and apply it only in the street scenes where the painterly props
   live.
4. **No outline pass yet.** A Sobel-style edge detector is a possible v2
   addition. The current shader assumes the assets carry their own outlines.

## Rolling back

The feature is fully removable: delete the `UnifyPost` node from Main.tscn
(or whichever scene you added it to). No autoloads, no script changes
elsewhere, no asset edits. The shader files can stay or be deleted; nothing
else references them.
