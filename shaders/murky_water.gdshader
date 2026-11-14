shader_type canvas_item;

uniform sampler2D water_strip : filter_nearest, repeat_enable;
uniform bool vertical_flow = false;
uniform bool bend_to_east = false;
uniform bool is_hilir = false;
uniform float flow_speed = 16.0;
uniform float ripple_amp = 3.5;

varying vec2 world_pos;
varying vec2 map_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	map_pos = VERTEX * 0.5;
}

vec3 sample_murky_flow(float along, float across) {
	// Gelombang arus berputar menyusuri sungai + geseran fase per jalur agar tidak kaku garis lurus.
	float phase = sin(across * 0.032) * 44.0 + cos(across * 0.017) * 26.0;
	float wave = sin(along * 0.075 + TIME * 2.1) * ripple_amp;
	vec2 uv_main = vec2((along + phase - TIME * flow_speed) / 384.0, (across + wave) / 64.0);
	vec4 c1 = texture(water_strip, uv_main);

	float wave2 = sin(along * 0.055 - TIME * 1.55) * 2.2;
	vec2 uv_sub = vec2((along * 0.85 - phase * 0.7 - TIME * (flow_speed * 0.6) + 192.0) / 384.0, (across + wave2 + 28.0) / 64.0);
	vec4 c2 = texture(water_strip, uv_sub);

	float l1 = dot(c1.rgb, vec3(0.299, 0.587, 0.114));
	float l2 = dot(c2.rgb, vec3(0.299, 0.587, 0.114));
	vec3 rgb = c1.rgb;
	if (l2 > 0.45 && l1 < 0.43) {
		rgb = c2.rgb;
	} else if (l2 < 0.21 && l1 > 0.23) {
		rgb = mix(c1.rgb, c2.rgb, 0.45);
	}
	return rgb;
}

vec3 sample_calm_sea(vec2 pos, float time) {
	// Palet air keruh pesisir muara tenang (selaras palet asli water_keruh_strip.png)
	const vec3 c_deep  = vec3(0.243, 0.216, 0.133); // #3e3722 air keruh dalam
	const vec3 c_mid   = vec3(0.325, 0.298, 0.192); // #534c31 air keruh tenang
	const vec3 c_clear = vec3(0.420, 0.380, 0.251); // #6b6140 sedimen keruh terang
	const vec3 c_crest = vec3(0.518, 0.447, 0.322); // #847252 kilau riak ombak lembut
	const vec3 c_foam  = vec3(0.647, 0.580, 0.439); // #a59470 buih pantai pesisir

	// Ombak laut tenang bergelombang horizontal lembut & riak permukaan alami
	float w1 = sin(pos.y * 0.10 + sin(pos.x * 0.022 + time * 0.45) * 2.0 - time * 0.75) * 0.5 + 0.5;
	float w2 = sin(pos.y * 0.05 - cos(pos.x * 0.016 - time * 0.30) * 1.5 + time * 0.45) * 0.5 + 0.5;
	float h_break = sin(pos.x * 0.07 + cos(pos.y * 0.035) * 2.0 + time * 0.60) * 0.5 + 0.5;
	float shimmer = sin(pos.x * 0.035 + pos.y * 0.045 + time * 0.85) * 0.5 + 0.5;
	float comb = w1 * 0.52 + w2 * 0.32 + shimmer * 0.16;

	float crest_val = sin(pos.y * 0.10 + sin(pos.x * 0.022 + time * 0.45) * 2.0 - time * 0.75);
	// Buih tipis lembut saat mendekati bibir pantai pasir
	float shore_prox = clamp((456.0 - pos.y) / 8.0, 0.0, 1.0);
	float shore_lap = sin(pos.x * 0.08 + time * 1.3) * 0.5 + 0.5;

	if (shore_prox > 0.60 && shore_lap > 0.55) {
		return c_foam;
	} else if (crest_val > 0.82 && h_break > 0.48) {
		return c_crest;
	} else if (comb > 0.50) {
		return c_clear;
	} else if (comb > 0.26) {
		return c_mid;
	} else {
		return c_deep;
	}
}

vec3 sample_hilir_water(vec2 pos, float time) {
	if (pos.y >= 448.0) {
		// Di laut selatan (y >= 448): air laut tenang alami
		vec3 sea_rgb = sample_calm_sea(pos, time);
		// Di dekat mulut muara (x ~ 720..752): arus sungai mengalir masuk dan memudar alami ke laut tenang
		float d_mouth = length(vec2((pos.x - 736.0) * 1.15, (pos.y - 448.0) * 1.2));
		if (d_mouth < 65.0) {
			float plume = smoothstep(65.0, 15.0, d_mouth);
			vec3 plume_flow = sample_murky_flow(pos.y, pos.x - 736.0 + 32.0);
			return mix(sea_rgb, plume_flow, plume * 0.65);
		}
		return sea_rgb;
	}

	// Di atas y < 448: Aliran sungai Sungai Deli yang masuk dari Kota Medan
	// 1. Alur horizontal (pos.x < 640): mengalir ke timur menyusuri jalan desa
	vec3 flow_east = sample_murky_flow(pos.x, pos.y - 256.0 + 32.0);

	// 2. Alur belokan ke selatan menuju muara (pos.x > 670): mengalir ke selatan
	vec3 flow_south = sample_murky_flow(pos.y, pos.x - 736.0 + 32.0);

	// Transisi mulus di kelokan
	float t_bend = smoothstep(620.0, 680.0, pos.x);
	return mix(flow_east, flow_south, t_bend);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a <= 0.01) {
		discard;
	}
	vec2 local_pos = vec2(mod(world_pos.x, 960.0), world_pos.y);
	vec3 rgb;
	if (is_hilir) {
		rgb = sample_hilir_water(local_pos, TIME);
	} else if (bend_to_east) {
		float east_blend = smoothstep(352.0, 432.0, local_pos.y) * smoothstep(464.0, 560.0, local_pos.x);
		if (east_blend <= 0.001) {
			rgb = sample_murky_flow(local_pos.y, local_pos.x);
		} else if (east_blend >= 0.999) {
			rgb = sample_murky_flow(local_pos.x, local_pos.y);
		} else {
			rgb = mix(sample_murky_flow(local_pos.y, local_pos.x), sample_murky_flow(local_pos.x, local_pos.y), east_blend);
		}
	} else if (vertical_flow) {
		rgb = sample_murky_flow(local_pos.y, local_pos.x);
	} else {
		rgb = sample_murky_flow(local_pos.x, local_pos.y);
	}
	COLOR = vec4(rgb, base.a);
}
