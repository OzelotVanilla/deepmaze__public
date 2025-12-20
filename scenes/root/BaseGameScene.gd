@abstract
class_name BaseGameScene
extends ColorRect
## The base class of scene for this game


## Main scene that controls the switching of scene.
@onready var main_scene__ref: SceneRoot


func _ready() -> void:
    var scene_root__try: Node = self.get_parent()
    while scene_root__try is not SceneRoot and scene_root__try != null:
        scene_root__try = scene_root__try.get_parent()
    self.main_scene__ref = scene_root__try
