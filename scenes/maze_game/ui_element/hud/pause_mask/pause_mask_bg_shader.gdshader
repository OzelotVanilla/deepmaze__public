shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.54, 0.54, 0.54, 1.0);
uniform float stripes_per_unit = 20.0; // Stripe density in object space

void fragment()
{
    // Base UV coordinates (0..1), attached to the object
    vec2 uv = UV;

    // Compute aspect ratio correction:
    // SCREEN_PIXEL_SIZE = (1 / viewport_width, 1 / viewport_height)
    // width / height = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

    // Make UV space isotropic (equal scale in X and Y)
    vec2 p = vec2(uv.x * aspect, uv.y);

    // True 45-degree direction in isotropic space
    float t = floor((p.x + p.y) * stripes_per_unit);
    float m = mod(t, 2.0);

    COLOR = mix(color_a, color_b, m);
}