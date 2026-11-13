shader_type canvas_item;

// Angin lembut untuk pohon pixel-art.
// Offset UV dilakukan per piksel, jadi tajuk dan ranting ikut melengkung,
// sementara pangkal batang tetap tertanam di tanah.

uniform float sway_pixels : hint_range(0.0, 12.0) = 2.6;
uniform float sway_speed : hint_range(0.0, 4.0) = 0.85;
uniform float flutter_pixels : hint_range(0.0, 6.0) = 0.9;
uniform float bend_height : hint_range(0.5, 4.0) = 1.75;

varying vec2 v_world_pos;
varying vec4 v_color;

void vertex() {
	// Posisi dunia dipakai sebagai fase acak, supaya tiap pohon
	// bergoyang dengan irama yang sedikit berbeda.
	v_world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
	// Simpan modulate vertex; di fragment() COLOR sudah tercampur tekstur,
	// jadi kita perlu warna vertex aslinya agar tidak menggelapkan sprite.
	v_color = COLOR;
}

void fragment() {
	vec2 uv = UV;

	// 0 = pangkal batang, 1 = puncak tajuk.
	float height = clamp(1.0 - uv.y, 0.0, 1.0);
	float bend = pow(height, bend_height);

	float phase = v_world_pos.x * 0.043 + v_world_pos.y * 0.071;
	float t = TIME * sway_speed;

	// Hembusan utama + gelombang susulan yang merambat ke atas.
	float gust = sin(t * 1.15 + phase) * 0.62
			+ sin(t * 0.41 - height * 2.6 + phase * 1.7) * 0.38;

	// Desir daun lebih cepat dan hanya terasa di area tajuk.
	float leaf_mask = smoothstep(0.38, 0.85, height);
	float flutter = sin(t * 7.3 + height * 19.0 + uv.x * 11.0 + phase * 5.0) * 0.6
			+ sin(t * 11.7 - height * 31.0 - uv.x * 23.0 + phase * 3.0) * 0.4;

	float dx = (gust * sway_pixels + flutter * flutter_pixels * leaf_mask) * bend;
	uv.x += dx * TEXTURE_PIXEL_SIZE.x;

	// Sedikit gerak vertikal agar tajuk terasa "bernapas".
	uv.y += flutter * 0.18 * leaf_mask * bend * TEXTURE_PIXEL_SIZE.y;

	COLOR = texture(TEXTURE, uv) * v_color;
}
