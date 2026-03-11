@tool
@icon("res://.godot/editor/icons/Button.svg")
class_name DottedBgButton
extends Button


const theme_variation__normal_name := StringName("DottedBgButton_Normal")

const theme_variation__focus_name := StringName("DottedBgButton_Focus")

#region StyleBox used.
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
#endregion


var should_show_focus_style: bool = false:
    set(value):
        if should_show_focus_style != value:
            should_show_focus_style = value
            self.refreshHoverStylebox()


func refreshHoverStylebox():
    # Check focus state, and whether should show "focused" stylebox, and give proper stylebox.
    if self.should_show_focus_style or self.has_focus():
        self.theme_type_variation = DottedBgButton.theme_variation__focus_name
    else:
        self.theme_type_variation = DottedBgButton.theme_variation__normal_name

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
    # Default theme type variation.
    self.theme_type_variation = DottedBgButton.theme_variation__normal_name

    # Signal.
    if not self.mouse_entered.is_connected(self.on_mouse_entered):
        self.mouse_entered.connect(self.on_mouse_entered)
    if not self.mouse_exited.is_connected(self.on_mouse_exited):
        self.mouse_exited.connect(self.on_mouse_exited)
    if not self.focus_entered.is_connected(self.on_focus_entered):
        self.focus_entered.connect(self.on_focus_entered)
    if not self.focus_exited.is_connected(self.on_focus_exited):
        self.focus_exited.connect(self.on_focus_exited)
