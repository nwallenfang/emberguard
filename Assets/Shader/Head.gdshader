shader_type spatial;
render_mode blend_mix, unshaded;

uniform float hairline = .2;
uniform float fire_texture_scale = .1;
uniform float fire_scale = .1;
uniform sampler2D fire_height;
uniform vec4 inner_color: hint_color;
uniform vec4 outer_color: hint_color;

void vertex()
{
	if (VERTEX.y > hairline)
	{
		vec2 xz_scaled = VERTEX.xz * fire_texture_scale + vec2(TIME/5.0);
		float fire = texture(fire_height, xz_scaled).r * fire_scale;
		VERTEX.y += fire;
	}
	
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment()
{
	vec3 base_color = vec3(0.0);
	float basic_fresnel = fresnel(3.0, NORMAL, VIEW);
	ALBEDO = mix(inner_color, outer_color, pow(basic_fresnel, .3)).rgb;//base_color + basic_fresnel;
	ALPHA = 1.0-pow(basic_fresnel, 3.0);
}
