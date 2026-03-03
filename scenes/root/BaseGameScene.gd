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


## Stop the processing and input handling.
## Should be called when current scene is not
##  the first child of [member SceneRoot.scene_stack__ref].
func hibernate() -> void:
    get_viewport().gui_release_focus()
    self.hide()
    self.set_process(false)
    self.set_process_input(false)
    self.set_process_unhandled_input(false)
    self.set_process_unhandled_key_input(false)

## Resume the processing and input handling.
## Should be called when current scene became
##  the first child of [member SceneRoot.scene_stack__ref].
func aestivate() -> void:
    self.show()
    self.set_process(true)
    self.set_process_input(true)
    self.set_process_unhandled_input(true)
    self.set_process_unhandled_key_input(true)

## Do some post init work.[br][br]
##
## Useful when the previous scene need to bring data to next scene.
## Having an empty default implementation if the child class does not need [code]postInit[/code].
func postInit(args: Array[Variant]) -> void:
    # Default impl, do not remove this method.
    pass
