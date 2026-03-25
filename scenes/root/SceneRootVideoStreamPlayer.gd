@tool
class_name SceneRootVideoStreamPlayer
extends VideoStreamPlayer


func _ready() -> void: self.__onReady__()
func _input(event: InputEvent) -> void: self.__onProcessInput__(event)


## This will awake this VideoStreamPlayer,
##  and hibernate it again when finished.
func playVideoStream(video_stream: VideoStreamTheora):
    if self.is_playing():
        printerr(
            "Another video `", self.get_stream_name(),
            "` is playing. Cannot play two video for `VideoLayer`."
        )
        return

    if video_stream == null:
        printerr("Invalid video stream, check path: ", video_stream.resource_path)
        return

    self.show()
    self.stream = video_stream
    self.play()
    await self.finished
    self.hide()

func __onReady__():
    # Do not init if opened in editor.
    if Engine.is_editor_hint():
        return

func __onProcessInput__(event: InputEvent):
    if not self.is_playing():
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
