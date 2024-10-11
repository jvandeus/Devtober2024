shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, ambient_light_disabled, fog_disabled, shadows_disabled, specular_disabled, blend_mix;

uniform sampler2D mask;
uniform sampler2D border;
uniform vec3 fill_color : source_color;

void fragment() {
	vec4 mask_color = texture(mask, UV);
	vec4 border_color = texture(border, UV);
	ALPHA = mix(0, 1, 1.0-mask_color.a);
	ALBEDO = mix(ALBEDO, fill_color, 1.0-mask_color.a);
	ALPHA = mix(ALPHA, border_color.a, border_color.a);
	ALBEDO = mix(ALBEDO, border_color.rgb, border_color.a);
}
