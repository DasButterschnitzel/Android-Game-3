shader_type canvas_item;
// Night sky: vertical gradient, paper grain, soft vignette, stars, and a warm
// horizon that rises as dawn approaches (dawn = 0..1). The warmth is kept low
// (behind the skyline) so ghost outlines keep their contrast in later waves.
// One full-screen pass, no textures: cheap on GLES3 mid-range GPUs.

uniform float dawn : hint_range(0.0, 1.0) = 0.0;
uniform vec4 top_color : source_color = vec4(0.039, 0.047, 0.11, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.10, 0.07, 0.19, 1.0);
uniform vec4 dawn_top : source_color = vec4(0.22, 0.27, 0.45, 1.0);
uniform vec4 dawn_bottom : source_color = vec4(0.91, 0.55, 0.39, 1.0);
uniform float grain = 0.05;
uniform float star_density = 0.0016;
uniform float time_s = 0.0;
uniform vec2 screen_px = vec2(720.0, 1280.0);

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = UV;
	vec3 night = mix(top_color.rgb, bottom_color.rgb, uv.y);
	vec3 morning = mix(dawn_top.rgb, dawn_bottom.rgb, pow(uv.y, 2.8));
	vec3 col = mix(night, morning, smoothstep(0.0, 1.0, dawn * dawn));
	// Stars fade out towards dawn and near the horizon.
	vec2 cell = floor(uv * screen_px / 3.0);
	float h = hash(cell);
	float twinkle = 0.6 + 0.4 * sin(time_s * (1.0 + h * 3.0) + h * 40.0);
	float star = step(1.0 - star_density, h) * twinkle * (1.0 - uv.y) * (1.0 - dawn);
	col += vec3(star * 0.85);
	// Paper grain (static) and vignette.
	float g = hash(floor(uv * screen_px)) - 0.5;
	col += g * grain;
	vec2 d = uv - vec2(0.5, 0.45);
	col *= 1.0 - 0.35 * smoothstep(0.35, 0.85, length(d * vec2(1.1, 0.9)));
	COLOR = vec4(col, 1.0);
}
