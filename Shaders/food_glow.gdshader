shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 rim_color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float rim_power : hint_range(0.1, 10.0) = 3.5;
uniform float rim_intensity : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb;
	ROUGHNESS = 0.45;
	SPECULAR = 0.2;
	
	// Fresnel effect for outline glowing
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	EMISSION = rim_color.rgb * fresnel * rim_intensity;
}
