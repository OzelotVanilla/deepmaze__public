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

const font = preload("res://assets/fonts/ark-pixel-12px-monospaced-latin.otf")


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

func on_mouse_entered():
    if not self.disabled:
        self.grab_focus()

func on_mouse_exited():
    if self.has_focus():
        self.release_focus()

func on_focus_entered():
    self.refreshHoverStylebox()

func on_focus_exited():
    self.refreshHoverStylebox()

func _ready() -> void:
    # Container sizing.
    self.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

    # Text behaviour.
    self.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT

    # Font.
    self.add_theme_font_override(
        "font",
        DottedBgButton.font
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
    if not self.mouse_entered.is_connected(self.on_mouse_entered):
        self.mouse_entered.connect(self.on_mouse_entered)
    if not self.mouse_exited.is_connected(self.on_mouse_exited):
        self.mouse_exited.connect(self.on_mouse_exited)
    if not self.focus_entered.is_connected(self.on_focus_entered):
        self.focus_entered.connect(self.on_focus_entered)
    if not self.focus_exited.is_connected(self.on_focus_exited):
        self.focus_exited.connect(self.on_focus_exited)
