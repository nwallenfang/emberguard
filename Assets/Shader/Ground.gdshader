// NOTE: Shader automatically converted from Godot Engine 3.4.3.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D grass_texture_albedo : hint_albedo;
uniform sampler2D grass_texture_normal : hint_normal;
uniform sampler2D dirt_texture_albedo : hint_albedo;
uniform sampler2D dirt_texture_normal : hint_normal;
uniform sampler2D ground_mask;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);

uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform vec2 tex_scale;

uniform float border_size;
uniform float border_smooth_size;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}




void fragment() {
	float mix_factor = smoothstep(0.0, 0.2, texture(ground_mask, UV).r);
	vec4 albedo_tex = mix(texture(grass_texture_albedo, UV*tex_scale), texture(dirt_texture_albedo, UV*tex_scale), mix_factor);
	vec4 normal_tex = mix(texture(grass_texture_normal, UV*tex_scale), texture(dirt_texture_normal, UV*tex_scale), mix_factor);
	float border_position = max(0.0, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)) - border_size);
	float border_value = 1.0 - clamp(border_position / border_smooth_size, 0.0, 1.0);
	ALBEDO = mix(albedo_tex.rgb, vec4(0.0).rgb, border_value);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	NORMALMAP = normal_tex.rgb;
	NORMALMAP_DEPTH = normal_scale;
	
	
}
