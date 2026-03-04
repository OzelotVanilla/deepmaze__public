@icon("res://.godot/editor/icons/Button.svg")
class_name FocusButton
extends Button


const normal_stylebox = preload("res://ui_component/button/focus_button/FocusButton_normal_stylebox.tres")

const focus_stylebox = preload("res://ui_component/button/focus_button/FocusButton_focus_stylebox.tres")

const font = preload("res://assets/fonts/ark-pixel-12px-monospaced-latin.otf")

## Should be the same as focused.
const pressed_stylebox = focus_stylebox


func refreshHoverStylebox():
    self.remove_theme_stylebox_override("hover")
    self.remove_theme_color_override("font_hover_color")

    # Check focus state and give proper stylebox.
    if self.has_focus():
        self.add_theme_stylebox_override("hover", focus_stylebox)
        self.add_theme_color_override("font_hover_color", Color("#000000"))
    else:
        self.add_theme_stylebox_override("hover", normal_stylebox)
        self.add_theme_color_override("font_hover_color", Color("#ffffff"))

func _ready() -> void:
    # Size.
    self.custom_minimum_size = Vector2(300, 80)

    # Font.
    self.add_theme_font_override(
        "font",
        FocusButton.font
    )
    self.add_theme_font_size_override(
        "font_size",
        32
    )
    self.add_theme_color_override("font_color",         Color("#ffffff"))
    self.add_theme_color_override("font_focus_color",   Color("#000000"))
    self.add_theme_color_override("font_pressed_color", Color("#000000"))

    # Stylebox.
    self.add_theme_stylebox_override(
        "normal",
        GameTitleButton.normal_stylebox
    )
    self.add_theme_stylebox_override(
        "pressed",
        GameTitleButton.pressed_stylebox
    )
    self.add_theme_stylebox_override(
        "focus",
        GameTitleButton.focus_stylebox
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
