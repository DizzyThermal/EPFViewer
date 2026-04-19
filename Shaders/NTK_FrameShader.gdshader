shader_type canvas_item;

uniform sampler2D palette_tex : filter_nearest, repeat_disable;
uniform sampler2D mask_tex : filter_nearest, repeat_disable;

uniform int initial_color_offset = 0;
uniform int animated_color_offset = 0;

uniform int animation_range_count = 0;
uniform ivec4 animation_ranges[16];

int apply_initial_offset(int idx) {
	// Range Filters for Color Offsets
	if ((idx >= 48 && idx <= 135) || 
			(idx >= 176 && idx <= 255)) {
		return (idx + initial_color_offset) % 256;
	}
	return idx;
}

int apply_animation_offset(int idx) {
	// Palette Animation Ranges
	for (int i = 0; i < animation_range_count; i++) {
		int min_i = animation_ranges[i].x;
		int max_i = animation_ranges[i].y;
		if (idx >= min_i && idx <= max_i) {
			int range_len = (max_i - min_i) + 1;
			int pos = idx - min_i;
			int shifted = (pos + animated_color_offset) % range_len;
			if (shifted < 0) {
				shifted += range_len;
			}
			return min_i + shifted;
		}
	}
	return idx;
}

void fragment() {
	vec4 index_sample = texture(TEXTURE, UV);
	int raw_idx = int(round(index_sample.r * 255.0));

	int mapped_idx = apply_initial_offset(raw_idx);
	mapped_idx = apply_animation_offset(mapped_idx);

	vec2 palette_uv = vec2((float(mapped_idx) + 0.5) / 256.0, 0.5);
	vec4 color = texture(palette_tex, palette_uv);

	float mask_alpha = 1.0;
	if (textureSize(mask_tex, 0).x > 0) {
		mask_alpha = texture(mask_tex, UV).a;
	}

	COLOR = vec4(color.rgb, color.a * mask_alpha);
}