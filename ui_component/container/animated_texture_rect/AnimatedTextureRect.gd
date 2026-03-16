@tool
class_name AnimatedTextureRect
extends TextureRect
## UI animation player based on [TextureRect], using [SpriteFrames].


## The requested animation is played and finished.
signal animation_finished(animation_name: StringName)


@export var sprite_frames: SpriteFrames:
    set(new_frames):
        if self.sprite_frames == new_frames:
            return

        sprite_frames = new_frames

        if Engine.is_editor_hint():
            self.frame_index = 0
            self.time_elapsed = 0.0
            self.refreshTexture()

        self.update_configuration_warnings()
        self.refreshTexture()

@export var animation_name: StringName = StringName("default"):
    set(new_name):
        if self.animation_name == new_name:
            return

        animation_name = new_name
        self.frame_index = 0
        self.time_elapsed = 0.0

        if Engine.is_editor_hint():
            self.refreshTexture()

        self.update_configuration_warnings()

## Whether the animation auto-starts after being loaded.
@export var autoplay: bool = false

## Delay when asked to play.
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var play_delay: float = 0.0:
    set(new_delay):
        if play_delay == new_delay:
            return

        play_delay = max(0, new_delay)

## Delay when play is finished, before calling [method stop].
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var stop_delay: float = 0.0:
    set(new_delay):
        if stop_delay == new_delay:
            return

        stop_delay = max(0, new_delay)

## Whether the animation continue playing after finished.
@export var loop: bool = false:
    set(whether_loop):
        if loop == whether_loop:
            return

        loop = whether_loop
        self.notify_property_list_changed()

## Interval between two play (in second), effective only when [member loop] is enabled.
@export_custom(PropertyHint.PROPERTY_HINT_NONE, "suffix:s")
var loop_interval: float = 0.0:
    set(new_interval):
        if loop_interval == new_interval:
            return

        loop_interval = max(0, new_interval)

@export_group("Texture showing at special point", "show_texture__")

## Whether texture should be showed at delay and loop interval time.
@export var show_texture__at_delay_and_interval: bool = true

## Whether texture should be showed when not playing anything.
## If so, the first texture is used.
@export var show_texture__when_not_playing: bool = false

## Whether an animation is being played.
var is_playing: bool = false

## Time elapsed since current playback started.
var time_elapsed: float = 0.0

## Index of the frame to play.
var frame_index: int = 0


func _ready() -> void: self.__onReady__()
func _process(delta: float) -> void: self.__onProcess__(delta)
func _get_configuration_warnings() -> PackedStringArray: return self.__getConfigurationWarnings__()
func _validate_property(property: Dictionary) -> void: self.__validateProperty__(property)


func play():
    if not self.isAnimationValid():
        return

    self.set_process(true)
    self.is_playing = true
    self.time_elapsed = 0.0
    self.frame_index = 0

    if self.play_delay <= 0.0 or self.show_texture__at_delay_and_interval:
        self.refreshTexture()
    else:
        self.texture = null

func pause():
    self.set_process(false)
    self.is_playing = false

func resume():
    if not self.isAnimationValid():
        return

    self.set_process(true)
    self.is_playing = true

func stop():
    self.set_process(false)
    self.is_playing = false
    self.time_elapsed = 0.0
    self.frame_index = 0

    if self.play_delay <= 0.0 or self.show_texture_at_delay_and_interval:
        self.refreshTexture()
    else:
        self.texture = null

## Update the showing texture from animation name and frame position.
func refreshTexture():
    if not self.isAnimationValid():
        self.texture = null
        return

    var frame_count := self.sprite_frames.get_frame_count(self.animation_name)
    if frame_count <= 0 and not self.show_texture__when_not_playing:
        self.texture = null
        return

    var valid_frame_index := clampi(self.frame_index, 0, frame_count - 1)
    self.texture = self.sprite_frames.get_frame_texture(
        self.animation_name, valid_frame_index
    )

func isAnimationValid() -> bool:
    if self.sprite_frames == null:
        return false

    if not self.sprite_frames.has_animation(self.animation_name):
        return false

    if self.sprite_frames.get_frame_count(self.animation_name) <= 0:
        return false

    return true

func __onReady__():
    self.update_configuration_warnings()
    self.set_process(false)

    if self.autoplay:
        self.play()
    else:
        self.refreshTexture()

func __onProcess__(delta: float):
    if not self.is_playing or Engine.is_editor_hint():
        return

    if not self.isAnimationValid():
        return

    var frame_count := self.sprite_frames.get_frame_count(self.animation_name)
    if frame_count <= 0:
        return

    var anime_fps := self.sprite_frames.get_animation_speed(self.animation_name)
    if anime_fps <= 0.0:
        return

    self.time_elapsed += delta

    var time_for_one_frame := 1.0 / anime_fps
    var animation_duration := frame_count * time_for_one_frame

    # Phase 1: waiting for play_delay
    if self.time_elapsed < self.play_delay:
        if self.show_texture_at_delay_and_interval:
            self.texture = self.sprite_frames.get_frame_texture(self.animation_name, 0)
        else:
            self.texture = null
        return

    var playback_elapsed := self.time_elapsed - self.play_delay

    # Non-loop mode.
    if not self.loop:
        var current_index := floori(playback_elapsed / time_for_one_frame)

        # When all frames are played.
        if current_index >= frame_count:
            self.frame_index = frame_count - 1
            self.is_playing = false
            self.refreshTexture()
            if self.stop_delay > 0:
                await self.get_tree().create_timer(self.stop_delay).timeout
                self.animation_finished.emit(self.animation_name)
                if not self.is_playing: # In case a new play started from other script.
                    self.stop()
            else:
                self.animation_finished.emit(self.animation_name)
                self.stop()

            return

        self.frame_index = current_index
        self.refreshTexture()
        return

    # Loop mode.
    else:
        var cycle_duration := animation_duration + self.stop_delay + self.loop_interval
        if cycle_duration <= 0.0:
            return

        var cycle_elapsed := fposmod(playback_elapsed, cycle_duration)

        # In loop interval phase
        if cycle_elapsed >= animation_duration and not self.show_texture__at_delay_and_interval:
            self.texture = null
            return

        var current_index := floori(cycle_elapsed / time_for_one_frame)
        current_index = clampi(current_index, 0, frame_count - 1)

        self.frame_index = current_index
        self.refreshTexture()

func __getConfigurationWarnings__() -> PackedStringArray:
    var warnings := PackedStringArray()

    if self.sprite_frames == null:
        warnings.append("Should set a sprite frame to play.")
        return warnings

    if self.animation_name not in self.sprite_frames.get_animation_names():
        warnings.append(str(
            "Animation name `", self.animation_name, "` not exists in loaded sprite_frames."
        ))
        return warnings

    if self.sprite_frames.get_frame_count(self.animation_name) <= 0:
        warnings.append(str(
            "Animation `", self.animation_name, "` has no frame."
        ))

    return warnings

func __validateProperty__(property: Dictionary) -> void:
    if property.name == "loop_interval":
        if self.loop:
            property.usage |= PropertyUsageFlags.PROPERTY_USAGE_EDITOR
        else:
            property.usage &= ~ PropertyUsageFlags.PROPERTY_USAGE_EDITOR
