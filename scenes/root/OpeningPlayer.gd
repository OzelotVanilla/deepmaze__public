@tool
class_name OpeningPlayer
extends VideoStreamPlayer


## Set whether the opening video is able to be skipped.
## This will override the [param can_skip] in [method playOpeningVideo]
##  when the node is ready.
@export var is_skippable: bool = true:
    set(new_value):
        if is_skippable == new_value:
            return

        is_skippable = new_value
        self.notify_property_list_changed()

## Set at when, the user could skip the opening.
## Meaningful only when [member is_skippable] is [code]true[/code].
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var skip__after: float = 0.0

## Set how long player should hold to skip.
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var skip__hold_time: float = 2.0


var is_playing_opening := false


func _ready() -> void: self.__onReady__()
func _validate_property(property: Dictionary) -> void: self.__validateProperty__(property)
func _input(event: InputEvent) -> void: self.__onProcessInput__(event)


func playOpeningVideo(can_skip: bool):
    self.is_playing_opening = true

    can_skip = self.is_skippable or can_skip

    self.show()
    self.set_process_input(false)
    self.play()

    if can_skip:
        if self.skip__after > 0:
            await get_tree().create_timer(self.skip__after).timeout
        self.set_process_input(true)

    await self.finished
    self.is_playing_opening = false
    self.hide()

func __onReady__():
    # Do not init if opened in editor.
    if Engine.is_editor_hint():
        return

func __validateProperty__(property: Dictionary) -> void:
    const prop_valid_only_if_skippable := [
        "skippable_after", "skip_hold_time"
    ]

    if property.name in prop_valid_only_if_skippable:
        if self.is_skippable:
            property.usage |= PropertyUsageFlags.PROPERTY_USAGE_EDITOR # Show
        else:
            property.usage &= ~ PropertyUsageFlags.PROPERTY_USAGE_EDITOR # Hide

func __onProcessInput__(event: InputEvent):
    if not self.is_playing_opening:
        return

    if event is InputEventKey:
        if event.is_echo() or not event.is_pressed():
            return
    elif event is InputEventMouseButton:
        if not event.is_pressed():
            return
    elif event is InputEventJoypadButton:
        if not event.is_pressed():
            return
    else:
        return

    self.stop()
    self.finished.emit()
    get_viewport().set_input_as_handled()
