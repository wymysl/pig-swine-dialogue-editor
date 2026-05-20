# Portrait Generation Brief

This directory contains character portraits for the dialogue system. The visual direction uses a **hybrid register** system inspired by Polish art:

- **Warm register** — naive Polish illustration (Butenko-adjacent) for normal dialogue
- **Dark register** — Aleksandra Waliszewska-inspired dark symbolism for intense moments

See `CONVENTIONS.md` §Art direction for the full two-layer system.

## Current Runtime Cut

The current dialogue UI loads one flat portrait per character from:

```gdscript
res://art/portraits/%s.png
```

Until Code adds expression-specific portrait paths, the cost-efficient cut is
one runtime portrait per character. Generate 512x512 sources if useful for
quality, but commit only the runtime export the UI can display. Full expression
sets are a future pass, not a prerequisite for Chapter 1.

## Register Assignment

### Characters with BOTH registers:
- **Mr. Pig** — warm for normal office, dark for panic/crisis states
- **Judge** — dark only (institutional grotesque)
- **Halina** — warm for initial meeting, dark for testimony/memory scenes
- **Cula** — warm for normal, dark for Casebook encounters (player perspective)

### Characters with WARM register only:
- **Asia** — composed, professional, always warm
- **Murrow** — earnest, slightly nervous, always warm
- **Whimsy** — theatrical but warm (his theatricality is comedy, not horror)
- **Crab** — rumpled, alert, always warm
- **Mr. Swine** — smooth, confident, always warm (his menace is subtle)

## Expression Sets

### Warm register — 4 expressions per character:
- `neutral.png` — default resting face
- `speaking.png` — mouth open, engaged
- `surprised.png` — eyebrows up, slight alarm
- `stressed.png` — tension visible, forced composure

### Dark register — 2–4 additional expressions:
- `dark_neutral.png` — same character, Waliszewska mood
- `dark_stressed.png` — the anxiety made visible
- `dark_panic.png` — (Mr. Pig only) full crisis
- `dark_intense.png` — (Judge, Halina) institutional/emotional weight

## Prompts

### Warm Register

**Style anchor:**
> Small format gouache painting, naive Polish illustration technique, flat warm earth-tone colors, slightly satirical, expressive but grounded, institutional office setting, visible brushstroke texture.

**Negative:**
> photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark

**Per-character prompt structure:**
> [Character physical description], [expression/emotion], [clothing]. [Style anchor]. Palette: [hex codes].

**Example — Asia, neutral:**
> Young Polish woman with brown ponytail, calm composed expression, mustard cardigan over cream shirt. Small format gouache painting, naive Polish illustration technique, flat warm earth-tone colors, slightly satirical, expressive but grounded, institutional office setting, visible brushstroke texture. Palette: #1a1410, #e6b08a, #c8a868, #e8e4d8, #1c2a40

### Dark Register (Waliszewska)

**Style anchor:**
> Small format oil painting, naive primitive technique, Polish dark symbolism, Młoda Polska mood, grotesque folk-art, warm earth tones with sickly accents, slightly unsettling, gouache texture, Balto-Slavic atmosphere.

**Negative:**
> photorealistic, 3D render, anime, digital art, cute, clean, corporate

**Example — Mr. Pig, dark_panic:**
> Anthropomorphic pig in too-tight navy suit, wide panicked eyes, snout wrinkled in distress, suit buttons straining, body slightly contorted. Small format oil painting, naive primitive technique, Polish dark symbolism, Młoda Polska mood, grotesque folk-art, warm earth tones with sickly accents, slightly unsettling, gouache texture, Balto-Slavic atmosphere. Palette: #1a1410, #f0c8c0, #1c2a40, #7a1f2a, #0d0a08

## Casebook Cards

Each Casebook judgment/legal concept gets a **full Waliszewska** illustration — a small symbolic painting:

**Style anchor:**
> Small format oil painting on wood panel, naive primitive technique, Polish dark symbolism, Młoda Polska mood, allegorical legal imagery, scales and figures, institutional grotesque, Balto-Slavic folklore, warm earth tones with cold accents.

**Examples of concepts to illustrate:**
- "Article 14 ECHR — Prohibition of Discrimination" → scales held by distorted hands
- "Procedural Deadline" → approaching dark shapes, bureaucratic dread
- "Burden of Proof" → a figure carrying impossible weight
- "Opposing Counsel's Argument" → a mouth that's all teeth

## Technical Notes

- **Source Resolution:** 512×512 px
- **Current Runtime Export:** flat PNG per character in `art/portraits/`
- **Format:** PNG with transparent background (character only, no scene)
- **Future Expression Storage:** `art/portraits/<char>/` — e.g., `art/portraits/mr_pig/dark_panic.png`
- **Tool:** Any AI image generator (Midjourney, DALL-E, etc.) — NOT Pixellab (which is for pixel sprites)
- **Session discipline:** Generate all warm portraits for one character in one session. Generate all dark portraits in a separate session. Never mix.
- **Palette latitude:** Portraits have wider color latitude than world sprites but must stay tonally aligned with the game palettes. Dark portraits may introduce off-palette darks and sickly highlights.
