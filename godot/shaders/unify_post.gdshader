// Unify-post screen-space shader.
//
// Purpose: collapse the visual gap between pixel-art assets (sprites, tilesets)
// and painterly/illustrated assets (building facades, street props) by forcing
// the entire screen through a fixed palette with Bayer dithering.
//
// Toggle at runtime via UnifyPost.visible or the `strength` uniform.
// strength = 0.0 -> pass-through (no change)
// strength = 1.0 -> full palette quantize + dither

shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;
uniform float dither_strength : hint_range(0.0, 0.15) = 0.04;
uniform float strength : hint_range(0.0, 1.0) = 1.0;

// Starter palette derived from art/palettes/marszalkowska_palette.png
// (18 colors, mixed warm/neutral/cool). Edit this array to swap palettes;
// the loop bound at the bottom is `< 18`, change it too if you add/remove rows.
const vec3 PAL[18] = vec3[](
	vec3(0.051, 0.039, 0.035), // ink black
	vec3(0.110, 0.094, 0.082), // soot
	vec3(0.353, 0.357, 0.384), // slate
	vec3(0.608, 0.576, 0.545), // taupe
	vec3(0.898, 0.882, 0.835), // cream
	vec3(0.412, 0.290, 0.196), // walnut
	vec3(0.898, 0.690, 0.541), // tan
	vec3(0.937, 0.796, 0.757), // blush
	vec3(0.788, 0.631, 0.400), // honey
	vec3(0.922, 0.788, 0.224), // mustard
	vec3(0.745, 0.365, 0.212), // amber
	vec3(0.478, 0.122, 0.161), // oxblood
	vec3(0.824, 0.227, 0.227), // signal red
	vec3(0.365, 0.169, 0.275), // plum
	vec3(0.110, 0.165, 0.247), // ink blue
	vec3(0.267, 0.412, 0.498), // slate blue
	vec3(0.231, 0.388, 0.275), // moss
	vec3(0.522, 0.678, 0.584)  // sage
);

// Bayer 4x4 ordered-dither matrix, normalized to roughly [-0.5, +0.5].
const float BAYER[16] = float[](
	-0.5000, -0.0000, -0.3750,  0.1250,
	 0.2500, -0.2500,  0.3750, -0.1250,
	-0.3125,  0.1875, -0.4375,  0.0625,
	 0.4375, -0.0625,  0.3125, -0.1875
);

void fragment() {
	vec3 src = texture(screen_tex, SCREEN_UV).rgb;

	int bx = int(mod(FRAGCOORD.x, 4.0));
	int by = int(mod(FRAGCOORD.y, 4.0));
	float bias = BAYER[by * 4 + bx] * dither_strength;

	vec3 candidate = clamp(src + vec3(bias), 0.0, 1.0);

	vec3 best = candidate;
	float best_d = 999.0;
	for (int i = 0; i < 18; i++) {
		vec3 d = candidate - PAL[i];
		float dist = dot(d, d);
		if (dist < best_d) {
			best_d = dist;
			best = PAL[i];
		}
	}

	COLOR.rgb = mix(src, best, strength);
	COLOR.a = 1.0;
}
