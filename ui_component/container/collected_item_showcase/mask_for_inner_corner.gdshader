// Template and tool function generated from ChatGPT.
// This shader cuts the pixels that should not be presented
//  when there is a corner radius setting in outer panel.
shader_type canvas_item;

uniform vec2   outer_rect_size = vec2(512.0, 222.0) ;

uniform float  corner_radius = 10 ;

uniform float  border_width  = 6 ;

varying vec2   local_position;

bool isInsideRect(vec2 p, vec2 min_pos, vec2 max_pos)
{
    return (
        p.x >= min_pos.x &&
        p.x <= max_pos.x &&
        p.y >= min_pos.y &&
        p.y <= max_pos.y
    ) ;
}


/**
 * Test if the position is inside the inner rectangle with a corner.
 *
 * In Godot, corner radius consider the border width.
 * For the circle center at the corner:
 * * The distance to inner edge of border is `corner_radius - border_width`.
 * * The distance to outer edge of border is just `corner_radius`.
 */
bool isInInnerRectWithCorner(
    vec2 position,
    vec2 size
)
{
    float diff_len = corner_radius - border_width ;
    /** Half of the width of inner rectangle, including border */
    float half_inner_width  = (size.x - 2.0 * border_width) / 2.0 ;
    /** Half of the height of inner rectangle, including border */
    float half_inner_height = (size.y - 2.0 * border_width) / 2.0 ;

    // Make the position re-axis-ed to center.
    position += vec2(half_inner_width, half_inner_height);

    // First, check if the point is in the rectangle that does not touch the corner.
    // safe_rect_1: wide, safe_rect_2: thin.
    vec2 min_pos_of_safe_rect_1 = vec2(
        half_inner_width + border_width,
        half_inner_height - diff_len
     ) ;
    vec2 min_pos_of_safe_rect_2 = vec2(
        half_inner_width - diff_len,
        half_inner_height + border_width
     ) ;
    return ( false
        || isInsideRect(position, -min_pos_of_safe_rect_1, min_pos_of_safe_rect_1)
        || isInsideRect(position, -min_pos_of_safe_rect_2, min_pos_of_safe_rect_2)
        || distance(position, vec2(half_inner_width - diff_len, half_inner_height - diff_len)) <= diff_len // LU
        || distance(position, vec2(half_inner_width - diff_len, -half_inner_height + diff_len)) <= diff_len // LD
        || distance(position, vec2(-half_inner_width + diff_len, half_inner_height - diff_len)) <= diff_len // RU
        || distance(position, vec2(-half_inner_width + diff_len, -half_inner_height + diff_len)) <= diff_len // RD
    ) ;
}

void vertex()
{
    // VERTEX is the local position in this drawn rect.
    // NOTICE: minus means go to right or down side.
    local_position = -VERTEX;
}

void fragment()
{
    vec2 size = outer_rect_size ;

    // If not inside
    if (!isInInnerRectWithCorner(local_position, size))
    {
        discard;
    }

    COLOR = texture(TEXTURE, UV) * COLOR;
}