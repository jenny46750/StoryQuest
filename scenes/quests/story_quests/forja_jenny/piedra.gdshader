shader_type canvas_item;
uniform vec4 oscuro : source_color = vec4(0.15,0.13,0.17,1.0);
uniform vec4 claro : source_color = vec4(0.50,0.38,0.31,1.0);
void fragment() {
	vec4 tile = texture(TEXTURE, UV);
	float luminancia = dot(tile.rgb, vec3(0.25,0.55,0.20));
	COLOR = vec4(mix(oscuro.rgb, claro.rgb, smoothstep(0.1,0.85,luminancia)), tile.a);
}
