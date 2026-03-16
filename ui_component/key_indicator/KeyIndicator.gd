@tool
class_name KeyIndicator
extends PanelContainer


## Name of the action added to global input map.
## If not empty, key indicator will use this name to show corresponding key.
@export var action_name: StringName = ""


## Convert button index to name, based on XBox/SteamDeck layout.
const button_index_to_name__xbox: Dictionary[int, String] = {
    JoyButton.JOY_BUTTON_A: "A",
    JoyButton.JOY_BUTTON_B: "B",
    JoyButton.JOY_BUTTON_X: "X",
    JoyButton.JOY_BUTTON_Y: "Y",
}


@onready var label__ref: Label = $Label


func _ready() -> void: self.__onReady__()


func on_input_manager_input_source_changed(to: InputManager.InputSource):
    var ExpectedEventType
    match to:
        InputManager.InputSource.keyboard:
            self.theme_type_variation = "KeyIndicator_Square"
            ExpectedEventType = "InputEventKey"

        InputManager.InputSource.controller:
            self.theme_type_variation = "KeyIndicator_Round"
            ExpectedEventType = "InputEventJoypadButton"

    self.refreshLabelText(ExpectedEventType)

## Refresh the text that should be showed for the label.
## If no text can be retrieved, will not set anything.
func refreshLabelText(ExpectedEventType: String = ""):
    if self.action_name.length() <= 0:
        return

    if ExpectedEventType.length() <= 0:
        match InputManager.input_source:
            InputManager.InputSource.keyboard:
                ExpectedEventType = "InputEventKey"

            InputManager.InputSource.controller:
                ExpectedEventType = "InputEventJoypadButton"

            # Fallback.
            _:
                ExpectedEventType = "InputEventKey"

    # # Set the label text according to editor/runtime.
    var action_events: Array # InputEvent[]
    if Engine.is_editor_hint():
        action_events = ProjectSettings.get_setting(str("input/", self.action_name))["events"]
    else:
        action_events = InputMap.action_get_events(self.action_name)

    if action_events.size() > 0:
        var event: InputEvent =  action_events \
            .filter(func(e): return e.is_class(ExpectedEventType)) \
            .front()
        if event != null:
            self.label__ref.text = KeyIndicator.getKeyName(event)

static func getKeyName(event: InputEvent) -> String:
    if   event is InputEventKey:
        var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
        var text = OS.get_keycode_string(keycode)
        return text
    elif event is InputEventJoypadButton:
        return KeyIndicator.button_index_to_name__xbox[event.button_index]
    else:
        printerr("Unsupport event `", event.get_class(),"` for `KeyIndicator.getKeyName`.")
        return ""

func __onReady__():
    if not input_manager.input_source_changed.is_connected(
        self.on_input_manager_input_source_changed
    ):
        input_manager.input_source_changed.connect(self.on_input_manager_input_source_changed)

    self.refreshLabelText()
