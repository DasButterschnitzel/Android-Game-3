shader_type canvas_item;
// Debug only: simulates colour vision deficiencies on the whole screen so the
// rule "colour never carries information alone" can be checked in the engine.
// mode: 1 protanopia, 2 deuteranopia, 3 tritanopia (Machado et al. 2009,
// severity 1.0, applied in linear RGB), 4 greyscale.

uniform int mode = 2;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

vec3 to_linear(vec3 c) { return pow(c, vec3(2.2)); }
vec3 to_srgb(vec3 c) { return pow(clamp(c, 0.0, 1.0), vec3(1.0 / 2.2)); }

void fragment() {
	vec3 c = to_linear(texture(screen_tex, SCREEN_UV).rgb);
	mat3 m = mat3(1.0);
	if (mode == 1) {
		m = mat3(vec3(0.152286, 0.114503, -0.003882), vec3(1.052583, 0.786281, -0.048116), vec3(-0.204868, 0.099216, 1.051998));
	} else if (mode == 2) {
		m = mat3(vec3(0.367322, 0.280085, -0.011820), vec3(0.860646, 0.672501, 0.042940), vec3(-0.227968, 0.047413, 0.968881));
	} else if (mode == 3) {
		m = mat3(vec3(1.255528, -0.078411, 0.004733), vec3(-0.076749, 0.930809, 0.691367), vec3(-0.178779, 0.147602, 0.303900));
	}
	vec3 r = m * c;
	if (mode == 4) {
		r = vec3(dot(c, vec3(0.2126, 0.7152, 0.0722)));
	}
	COLOR = vec4(to_srgb(r), 1.0);
}
