shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, ambient_light_disabled, fog_disabled, shadows_disabled, specular_disabled, blend_mix;

uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D mask;
uniform vec3 fill_color : source_color;

void vertex() {
	  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec4 mask_color = texture(mask, SCREEN_UV);
	float depth = texture(depth_texture, SCREEN_UV).x;
	// normalized device coordinates
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	// Visualize linear depth
	//ALBEDO.rgb = vec3(fract(linear_depth));
	
	// Visualize world coordinates
	//vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//vec3 world_position = world.xyz / world.w;
	//ALBEDO.rgb = fract(world_position).xyz;
	
	// idk why this works but i got it from a video: https://www.youtube.com/watch?v=wyGWuGQO63Y
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	// gets only the things closer to it.
	vec3 depth_mask = mix(vec3(ceil(depth)), vec3(0), lessThan(vec3(3), vec3(depth)));
	// mix in the screen texture mask
	depth_mask = mix(vec3(mask_color.a), depth_mask, greaterThan(depth_mask,vec3(1)));
	//ALBEDO = depth_mask;
	ALBEDO = mix(vec3(0), fill_color, 1.0-depth_mask.x);
	ALPHA = mix(1, 0, depth_mask.x);
	//ALBEDO = mix(vec3(0.0), ALBEDO, depth_mask.x);
	//ALBEDO = vec3(depth*0.01);
	//ALBEDO = ALBEDO;
	
	// TODO: TRY THIS TO MAKE SECTIONS TRANSPARENT!!!! saw in a radom post online. Might be usefull
	// discard = true;
}

void light() {
    DIFFUSE_LIGHT = vec3(0.0);
	SPECULAR_LIGHT = vec3(0.0);
}