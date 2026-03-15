class_name ArrowIndicatorTextBox
extends VBoxContainer
## Scrollable text box with two arrows showing scroll-ability
##
## Controller right stick logic copied from [ScrollableTextBox].


var text: String:
    set(new_text):
        if self.is_node_ready():
            self.text_box__ref.text = new_text
            # Set scroll back and refresh arrow display.
            self.scroll_container__ref.scroll_vertical = 0
            await get_tree().process_frame # To let v bar sets its max value correctly.
            self.refreshVisibilityOfArrows.call_deferred()
        text = new_text
    get():
        if self.is_node_ready():
            text = self.text_box__ref.text
        return text


## Scroll speed with the right stick.
@export var right_stick__scroll_speed: float = 400

## Scroll deadzone: 0..1.
## Right stick axis abs value bigger than this value will trigger scrolling.
@export var right_stick__scroll_deadzone: float = 0.2


@onready var text_box__ref: Label = $ScrollContainer/TextBox

@onready var scroll_container__ref: ScrollContainer = $ScrollContainer

@onready var up_arrow__ref: TextureRect = $UpArrow

@onready var down_arrow__ref: TextureRect = $DownArrow


func _ready() -> void: self.__onReady__()
func _process(delta: float) -> void: self.__onProcess__(delta)


func refreshVisibilityOfArrows():
    self.refreshVisibilityOfArrowsByValue(self.scroll_container__ref.scroll_vertical)

func refreshVisibilityOfArrowsByValue(current_value: float):
    var v_scroll_bar := self.scroll_container__ref.get_v_scroll_bar()
    if current_value == -1:
        current_value = v_scroll_bar.value

    var bottom := maxf(v_scroll_bar.min_value, v_scroll_bar.max_value - v_scroll_bar.page)
    # # Up arrow.
    if current_value <= v_scroll_bar.min_value:
        # Hide.
        self.up_arrow__ref.modulate = Color.TRANSPARENT
    else:
        # Show
        self.up_arrow__ref.modulate = Color.BLACK

    # # Down arrow.
    if current_value >= bottom:
        # Hide.
        self.down_arrow__ref.modulate = Color.TRANSPARENT
    else:
        # Show
        self.down_arrow__ref.modulate = Color.BLACK

func __onReady__():
    var v_scroll_bar := self.scroll_container__ref.get_v_scroll_bar()
    if not v_scroll_bar.value_changed.is_connected(self.refreshVisibilityOfArrowsByValue):
        v_scroll_bar.value_changed.connect(self.refreshVisibilityOfArrowsByValue)

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
