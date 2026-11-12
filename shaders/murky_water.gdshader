shader_type canvas_item;

uniform sampler2D water_strip : filter_nearest, repeat_enable;
uniform bool vertical_flow = false;
uniform float flow_speed = 16.0;
uniform float ripple_amp = 2.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a <= 0.01) {
		discard;
	}
	float along = vertical_flow ? world_pos.y : world_pos.x;
	float across = vertical_flow ? world_pos.x : world_pos.y;

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
	COLOR = vec4(rgb, base.a);
}
