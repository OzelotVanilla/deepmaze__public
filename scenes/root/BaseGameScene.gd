@abstract
class_name BaseGameScene
extends ColorRect
## The base class of scene for this game


## Root scene that controls the switching of scene.
@onready var root_scene__ref: SceneRoot


func _ready() -> void:
    var scene_root__try: Node = self.get_parent()
    while scene_root__try is not SceneRoot and scene_root__try != null:
        scene_root__try = scene_root__try.get_parent()
    self.root_scene__ref = scene_root__try

func _enter_tree() -> void:
    # This will make `_ready` called again when enters tree again.
    self.request_ready()

## Do some post init work.[br][br]
##
## Useful when the previous scene need to bring data to next scene.
## Having an empty default implementation if the child class does not need [code]postInit[/code].
func postInit(args: Array[Variant]) -> void:
    pass
