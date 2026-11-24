shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float water_level : hint_range(-0.2, 1.2) = 1.05;
uniform float wave_amplitude = 0.022;
uniform float wave_frequency = 16.0;
uniform float flow_speed = 6.0;
uniform vec4 mud_color_deep : source_color = vec4(0.24, 0.16, 0.10, 0.90);
uniform vec4 mud_color_shallow : source_color = vec4(0.40, 0.29, 0.18, 0.78);
uniform vec4 foam_color : source_color = vec4(0.88, 0.82, 0.72, 0.95);
uniform float turbulence : hint_range(0.0, 1.0) = 0.85;

void fragment() {
	// 1. Hitung garis permukaan air dinamis bergelombang
	float wave1 = sin(SCREEN_UV.x * wave_frequency + TIME * flow_speed) * wave_amplitude;
	float wave2 = sin(SCREEN_UV.x * (wave_frequency * 2.1) - TIME * (flow_speed * 1.3) + 1.4) * (wave_amplitude * 0.45);
	float wave3 = cos(SCREEN_UV.x * (wave_frequency * 0.6) + TIME * (flow_speed * 0.7)) * (wave_amplitude * 0.35);
	float surface_y = water_level + wave1 + wave2 + wave3;

	// Jika di atas air, tidak dirender kecuali percikan tipis
	if (SCREEN_UV.y < surface_y) {
		float spray_dist = surface_y - SCREEN_UV.y;
		float spray_noise = sin(SCREEN_UV.x * 80.0 + TIME * 15.0);
		if (spray_dist < 0.008 && spray_noise > 0.4) {
			COLOR = vec4(foam_color.rgb, (1.0 - spray_dist / 0.008) * 0.6);
		} else {
			discard;
		}
	} else {
		// 2. Di bawah permukaan air (terendam banjir)
		float depth = clamp((SCREEN_UV.y - surface_y) / 0.4, 0.0, 1.0);

		// Distorsi arus air keruh
		vec2 distort = vec2(
			sin(SCREEN_UV.y * 30.0 + TIME * 7.0) * 0.012 + cos(SCREEN_UV.x * 22.0 + TIME * 4.5) * 0.007,
			cos(SCREEN_UV.x * 28.0 - TIME * 6.0) * 0.008 + sin(SCREEN_UV.y * 20.0 + TIME * 3.5) * 0.005
		) * turbulence;

		vec4 bg = texture(screen_texture, SCREEN_UV + distort);

		// Gradien lumpur cokelat pekat & garis arus sediment
		float current_streak = sin((SCREEN_UV.x * 14.0 - TIME * flow_speed * 1.6) + SCREEN_UV.y * 10.0) * 0.5 + 0.5;
		vec4 mud_tint = mix(mud_color_shallow, mud_color_deep, depth * 0.65 + current_streak * 0.35);

		// Busa tebal di puncak ombak air banjir
		float foam_dist = SCREEN_UV.y - surface_y;
		float foam_factor = smoothstep(0.028, 0.0, foam_dist);
		float foam_bubbles = sin(SCREEN_UV.x * 65.0 + TIME * 14.0) * cos(SCREEN_UV.y * 45.0 + TIME * 8.0);
		if (foam_dist < 0.018 && foam_bubbles > 0.0) {
			foam_factor = clamp(foam_factor + foam_bubbles * 0.35, 0.0, 1.0);
		}

		// Campurkan warna latar terendam dengan air lumpur keruh
		vec4 submerged = mix(bg, mud_tint, clamp(0.50 + depth * 0.45, 0.0, 0.96));
		COLOR = mix(submerged, foam_color, foam_factor * 0.90);
	}
}
