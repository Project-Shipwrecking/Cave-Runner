shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo : source_color;
uniform vec2 viewport_size ;

void fragment(){
    vec3 local_pos = VERTEX;

    // Project X and Y from mesh space into UV (adjust to fit your box size)
    //vec2 uv = local_pos.xy; // or .xz if your screen faces Z
    //uv = uv * 0.5 + 0.5; // Normalize to 0–1

    ALBEDO = texture(albedo, SCREEN_UV).rgb;
}