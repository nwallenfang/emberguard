shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform float max_opacity = 0.4;

varying float time_factor;
varying float random_factor;
void vertex() {
	time_factor = INSTANCE_CUSTOM.y;
	random_factor = WORLD_MATRIX[3][1];
}

float map(float value, float istart, float istop, float ostart, float ostop) {
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}


void fragment() {
	float middle_uv_x = (UV.x - .5) / 2.0 + .5;
	float time_to_x = .2 -  clamp(abs(middle_uv_x - time_factor), 0, .2);
	float distance_to_sine = abs( UV.y - .5 + .05 * sin(10.0 * random_factor + middle_uv_x  * 4.0 + TIME / 4.0));
	float clamped_distance = 1.0 - map(clamp(distance_to_sine, .0, .01), 0.0, .01, .0, 1.0);
	float clamped_squared = pow(clamped_distance, 5.0);
	float smooth_border = .2;
	float smooth_end = 1.0 - pow(map(max(0.0, abs(UV.x - .5) - (.5 - smooth_border)), 0.0, smooth_border, 0.0, 1.0), 2.0);
	ALBEDO = smooth_end * vec3(1.0) * clamped_squared * time_to_x * 5.0;
	ALPHA = ALBEDO.r * max_opacity;
}