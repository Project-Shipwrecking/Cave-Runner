shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo;
uniform vec3 face_direction = vec3(0.0, 0.0, 1.0);
uniform vec2 face_size = vec2(1.0, 1.0);
uniform mat3 object_basis;
uniform vec3 object_origin;
uniform mat4 camera_inv_transform;

void fragment() {
    vec3 n = normalize(NORMAL);
    if (dot(n, face_direction) < 0.99) {
        discard;
    }
	
	vec3 world_pos = object_basis * VERTEX + object_origin;
vec4 camera_local_pos = camera_inv_transform * vec4(world_pos, 1.0);

    vec2 uv = camera_local_pos.xy / face_size + 0.5;

    // Optionally flip uv.y if needed:
    uv.y = 1.0 - uv.y;

    //ALBEDO = texture(albedo, uv).rgb;
	ALBEDO = pow(texture(albedo, uv).rgb, vec3(2.2));

}