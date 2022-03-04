shader_type spatial;

render_mode unshaded, cull_front;

uniform float outline_width : hint_range(0,1,0.01);
uniform vec4 outline_color : hint_color = vec4(1.0);

void vertex() {
	VERTEX += outline_width * VERTEX;
}

void fragment() {
	ALBEDO = outline_color.xyz;
}