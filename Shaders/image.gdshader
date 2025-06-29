shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D albedo_texture : source_color;

void fragment() {
    vec3 color = texture(albedo_texture, UV).rgb;

    // Apply gamma correction (linear → sRGB)
    //color = pow(color, vec3(1.0 / 2.2));

    ALBEDO = color;
}
