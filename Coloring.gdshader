shader_type canvas_item;
uniform vec4 given_color :source_color;
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR = given_color * color;
}
