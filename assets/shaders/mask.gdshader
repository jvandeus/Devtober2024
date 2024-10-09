shader_type canvas_item;

uniform sampler2D mask;
uniform sampler2D border;

void fragment() {
	vec4 mask_color = texture(mask, UV);
	vec4 border_color = texture(border, UV);
	COLOR.a = mask_color.a + border_color.a;
	COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border_color.a);
}
