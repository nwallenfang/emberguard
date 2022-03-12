// NOTE: Shader automatically converted from Godot Engine 3.4.3.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_never,cull_disabled, diffuse_burley,specular_schlick_ggx, unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_magic : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
varying float id;

float clamp_and_map_and_pow(float value, float istart, float istop, float ostart, float ostop, float p) {
	value = clamp(value, istart, istop);
	return pow(ostart + (ostop - ostart) * ((value - istart) / (istop - istart)), p);
}

float clamp_and_map(float value, float istart, float istop, float ostart, float ostop) {
	value = clamp(value, istart, istop);
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

float map(float value, float istart, float istop, float ostart, float ostop) {
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	id =  3.7 * WORLD_MATRIX[2][1] + 5.7 * WORLD_MATRIX[0][2];
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 magic_tex = texture(texture_magic,base_uv + vec2(TIME * .3 + id));
	vec3 alb = ALBEDO = albedo.rgb;
	float alp = pow(albedo_tex.r, .9) * pow(magic_tex.r, .5);
	float distance_to_middle = distance(vec2(.5,.5),UV);
	float clamp_distance = 1.0 - clamp_and_map(distance_to_middle, 0.0, 0.3, 0.0, 1.0);
	clamp_distance = pow(clamp_distance, 2.0);
	ALPHA = clamp(alp + clamp_distance, .0, 1.0);
	ALBEDO = mix(alb, vec3(1.0), clamp_distance);
	//EMISSION = ALBEDO * 3.0;
}
