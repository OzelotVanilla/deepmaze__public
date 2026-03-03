@tool # Need to dynamically change parameter of shader.
class_name CollectedItemShowcase
extends PanelContainer


@onready var available__ref: Control = $Available

@onready var picture_rect__ref: TextureRect = $Available/Background

@onready var unavailable__ref: Control = $Unavailable


var pic_path: StringName:
    set(new_path):
        pic_path = new_path
        if new_path == null or new_path.length() <= 0:
            self._setAsUnavailable()
        else:
            self._setAsAvailable(new_path)


func _ready() -> void: self.__onReady__()


## Private. Called by setter of [member pic_path].
func _setAsAvailable(new_pic_path):
    self.available__ref.show()
    self.unavailable__ref.hide()
    self.picture_rect__ref.texture = load(new_pic_path)

## Private. Called by setter of [member pic_path].
func _setAsUnavailable():
    self.unavailable__ref.show()
    self.available__ref.hide()

func __onReady__():
    pass
