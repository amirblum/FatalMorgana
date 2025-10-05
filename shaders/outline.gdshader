shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_size = 1.5;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float alpha = base.a;
    float outline = 0.0;

    // sample around the current pixel
    for (float x = -outline_size; x <= outline_size; x++) {
        for (float y = -outline_size; y <= outline_size; y++) {
            outline = max(outline, texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE).a);
        }
    }

    if (alpha > 0.0) {
        COLOR = base * COLOR; // main sprite with modulation
    } else if (outline > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = vec4(0.0);
    }
}
