shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo : source_color;

void fragment(){
	ALBEDO = vec3(texture(albedo, SCREEN_UV).rgb);
	//ALBEDO = vec3(texture(albedo, UV).rgb);
	
}