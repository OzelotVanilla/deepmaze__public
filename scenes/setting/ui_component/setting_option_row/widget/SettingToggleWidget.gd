@tool
class_name SettingToggleWidget
extends SettingWidget


var toggle_status: bool = false:
    set(new_value):
        toggle_status = new_value
        if new_value == true:
            self.on_indicator_x__ref.modulate  = Color.BLACK
            self.off_indicator_x__ref.modulate = Color.TRANSPARENT
        else:
            self.on_indicator_x__ref.modulate  = Color.TRANSPARENT
            self.off_indicator_x__ref.modulate = Color.BLACK

@onready var on_indicator_x__ref: TextureRect = $OnIndicator/Margin/X

@onready var off_indicator_x__ref: TextureRect = $OffIndicator/Margin/X


func _ready() -> void:
    super.__onReady__()
    self.__onReady__()


func setWidgetValue(value: Variant):
    if value is bool:
        self.toggle_status = value
    else:
        printerr("Invalid data: ", value)

func getWidgetValue():
    return self.toggle_status

func turnToOn():
    self.toggle_status = true

func turnToOff():
    self.toggle_status = false

func onReceivingLeftAction():
    self.turnToOn()

func onReceivingRightAction():
    self.turnToOff()

func __onReady__():
    pass
