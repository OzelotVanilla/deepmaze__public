class_name ScrollableTextBox
extends PanelContainer
## A scrollable text container allows controller's right stick for scrolling


@onready var scroll_container__ref: ScrollContainer = $Scroll

@onready var label__ref: Label = $Scroll/Label


## Scroll speed with the right stick.
@export var right_stick__scroll_speed: float = 400

## Scroll deadzone: 0..1.
## Right stick axis abs value bigger than this value will trigger scrolling.
@export var right_stick__scroll_deadzone: float = 0.2


var text: String:
    set(new_text):
        self.label__ref.text = new_text
        text = new_text
    get():
        return self.label__ref.text

## Vertical scroll offset for scroll container.
var scroll_offset: int:
    set(new_offset):
        scroll_offset = new_offset
        self.scroll_container__ref.scroll_vertical = new_offset
    get():
        return self.scroll_container__ref.scroll_vertical


func _process(delta: float) -> void: self.__onProcess__(delta)


func __onProcess__(delta: float):
    self.handleRStickScrolling(delta)

func handleRStickScrolling(delta: float):
    var axis_value := Input.get_joy_axis(0, JoyAxis.JOY_AXIS_RIGHT_Y)
    if abs(axis_value) < self.right_stick__scroll_deadzone:
        return

    self.scroll_container__ref.scroll_vertical = clamp(
        self.scroll_container__ref.scroll_vertical
        + roundi(axis_value * delta * self.right_stick__scroll_speed),
        0, # Min.
        int(self.scroll_container__ref.get_v_scroll_bar().max_value) # Max.
    )
