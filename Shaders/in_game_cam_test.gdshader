shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo : source_color;
uniform vec2 viewport_size = vec2(640.0, 480.0);
uniform mat4 model_matrix;
uniform mat4 camera_inv_transform;

varying vec2 projected_uv;

void vertex() {
    // Compute world position
    vec3 world_pos = (model_matrix * vec4(VERTEX, 1.0)).xyz;

    // Transform to camera space
    vec4 cam_local = camera_inv_transform * vec4(world_pos, 1.0);

    // Orthographic projection
    projected_uv = cam_local.xy / viewport_size + vec2(0.5);
    projected_uv.y = 1.0 - projected_uv.y; // Flip if needed
}

void fragment() {
    if (projected_uv.x < 0.0 || projected_uv.x > 1.0 || projected_uv.y < 0.0 || projected_uv.y > 1.0) {
        discard;
    }

    ALBEDO = texture(albedo, projected_uv).rgb;
}
