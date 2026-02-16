@icon("res://.godot/editor/icons/Button.svg")
class_name DottedBgButton
extends Button


const normal_stylebox = preload(
    "res://ui_component/button/dotted_bg_button/DottedBgButton_normal_stylebox.tres"
)

## Should be the same as focused.
const pressed_stylebox = preload(
    "res://ui_component/button/dotted_bg_button/DottedBgButton_focus_stylebox.tres"
)

const focus_stylebox = preload(
    "res://ui_component/button/dotted_bg_button/DottedBgButton_focus_stylebox.tres"
)


var should_show_focus_style: bool = false:
    set(value):
        if should_show_focus_style != value:
            should_show_focus_style = value
            self.refreshHoverStylebox()


func refreshHoverStylebox():
    self.remove_theme_stylebox_override("normal")
    self.remove_theme_stylebox_override("hover")
    self.remove_theme_color_override("font_hover_color")

    # Check if should show "focused" stylebox.
    if self.should_show_focus_style:
        self.add_theme_stylebox_override("normal", DottedBgButton.focus_stylebox)
        self.add_theme_stylebox_override("hover", DottedBgButton.focus_stylebox)
        self.add_theme_color_override("font_hover_color", Color("#000000"))
        return
    else:
        self.add_theme_stylebox_override("normal", DottedBgButton.normal_stylebox)

    # Check focus state and give proper stylebox.
    if self.has_focus():
        self.add_theme_stylebox_override("hover", DottedBgButton.focus_stylebox)
        self.add_theme_color_override("font_hover_color", Color("#000000"))
    else:
        self.add_theme_stylebox_override("hover", DottedBgButton.normal_stylebox)
        self.add_theme_color_override("font_hover_color", Color("#000000"))

func _ready() -> void:
    # Container sizing.
    self.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

    # Text behaviour.
    self.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT

    # Font.
    self.add_theme_font_override(
        "font",
        preload("res://assets/fonts/PressStart2P-Regular_no_descent.tres")
    )
    self.add_theme_font_size_override(
        "font_size",
        32
    )
    self.add_theme_color_override("font_color",         Color("#000000"))
    self.add_theme_color_override("font_focus_color",   Color("#000000"))
    self.add_theme_color_override("font_pressed_color", Color("#000000"))

    # Stylebox.
    self.add_theme_stylebox_override(
        "normal",
        DottedBgButton.normal_stylebox
    )
    self.add_theme_stylebox_override(
        "pressed",
        DottedBgButton.pressed_stylebox
    )
    self.add_theme_stylebox_override(
        "focus",
        DottedBgButton.focus_stylebox
    )

    # Signal.
    self.mouse_entered.connect(self.refreshHoverStylebox)
    self.mouse_exited.connect(self.refreshHoverStylebox)
    self.focus_entered.connect(self.refreshHoverStylebox)
    self.focus_exited.connect(self.refreshHoverStylebox)

    self.mouse_entered.connect(
        func():
            self.grab_focus()
    )
