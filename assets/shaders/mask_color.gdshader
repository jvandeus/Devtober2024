shader_type canvas_item;

uniform vec3 mask_color : source_color;

float color_match(vec3 color1, vec3 color2) {
	float min_diff = 0.01;
	float max_diff = 0.5;
	float diff = abs(length(color1 - color2));
	return diff <= max_diff? 1.0 : 0.0;
}

void fragment() {
	//vec4 mask_color = texture(mask, UV);
	//vec4 border_color = texture(border, UV);
	COLOR.a = mix(1.0, 0.0, color_match(mask_color.rgb, COLOR.rgb));
	//COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border_color.a);
}
