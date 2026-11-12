shader_type canvas_item;

uniform sampler2D water_strip : filter_nearest, repeat_enable;
uniform bool vertical_flow = false;
uniform bool bend_to_east = false;
uniform float flow_speed = 16.0;
uniform float ripple_amp = 2.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

vec3 sample_murky_flow(float along, float across) {
	// Gelombang arus berputar menyusuri sungai + geseran fase per jalur agar muara/laut luas tidak berpola kolom berulang.
	float phase = sin(across * 0.032) * 44.0 + cos(across * 0.017) * 26.0;
	float wave = sin(along * 0.075 + TIME * 2.1) * ripple_amp;
	vec2 uv_main = vec2((along + phase - TIME * flow_speed) / 384.0, (across + wave) / 64.0);
	vec4 c1 = texture(water_strip, uv_main);

	float wave2 = sin(along * 0.055 - TIME * 1.55) * 1.5;
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

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a <= 0.01) {
		discard;
	}
	vec3 rgb;
	if (bend_to_east) {
		float east_blend = smoothstep(352.0, 432.0, world_pos.y) * smoothstep(464.0, 560.0, world_pos.x);
		if (east_blend <= 0.001) {
			rgb = sample_murky_flow(world_pos.y, world_pos.x);
		} else if (east_blend >= 0.999) {
			rgb = sample_murky_flow(world_pos.x, world_pos.y);
		} else {
			rgb = mix(sample_murky_flow(world_pos.y, world_pos.x), sample_murky_flow(world_pos.x, world_pos.y), east_blend);
		}
	} else if (vertical_flow) {
		rgb = sample_murky_flow(world_pos.y, world_pos.x);
	} else {
		rgb = sample_murky_flow(world_pos.x, world_pos.y);
	}
	COLOR = vec4(rgb, base.a);
}
