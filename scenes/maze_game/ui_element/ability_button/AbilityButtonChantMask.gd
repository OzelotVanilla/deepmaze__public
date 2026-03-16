# Adopt from ChatGPT.
@tool
class_name AbilityButtonChantMask
extends Control


# Range: [code]0..=1[/code].
var progress: float = 0.0:
    set(new_value):
        progress = clamp(new_value, 0.0, 1.0)
        self.queue_redraw()

## Calculate how long the mask will occupy parent node, in ratio.
## Effective if this value is greater than 0.
@export_range(0, 1, 0.01) var mask_width_ratio: float = 0.3

## The alpha value of left side of mask.
@export_range(0, 1, 0.01) var left_alpha_ratio: float = 0

var mask_colour: Color = Color.TRANSPARENT


func _draw() -> void:
    if self.progress <= 0.0:
        return

    var w := self.size.x * self.progress
    var h := self.size.y
    var l := w * self.mask_width_ratio

    var points := PackedVector2Array([
        Vector2(0, 0) if self.mask_width_ratio <= 0 else Vector2(w - l, 0),
        Vector2(w, 0),
        Vector2(w, h),
        Vector2(0, h) if self.mask_width_ratio <= 0 else Vector2(w - l, h)
    ])

    var right_color := self.mask_colour
    var left_color  := self.mask_colour
    left_color.a *= self.left_alpha_ratio

    var colors := PackedColorArray([
        left_color,
        right_color,
        right_color,
        left_color,
    ])

    draw_polygon(points, colors)
