shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D albedo : source_color;
uniform vec2 viewport_size ;

void fragment(){

    ALBEDO = texture(albedo, UV).rgb;
}