class_name SFXPlayer
extends AudioStreamPlayer
## A transient player to play SFX, will be deleted after playing


func _init() -> void:
    self.bus = "SFX"
    self.finished.connect(self.queue_free)
