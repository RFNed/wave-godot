shader_type canvas_item;

uniform float radius = 32.0;

void fragment() {
	vec2 uv = UV;
	vec2 size = vec2(1.0, 1.0);

	vec2 pos = uv * size;

	float d = length(max(abs(pos - 0.5) - 0.5 + radius / 100.0, 0.0));

	if (d > radius / 100.0) {
		discard;
	}

	COLOR = texture(TEXTURE, UV);
}