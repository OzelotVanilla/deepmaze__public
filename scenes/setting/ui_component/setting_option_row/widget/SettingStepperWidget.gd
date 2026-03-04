@tool
class_name SettingStepperWidget
extends SettingWidget
## The actual widget in the right side of [SettingOptionRow] enabling choosing in list.


@onready var left_arrow__ref: TextureButton = $LeftArrow

@onready var right_arrow__ref: TextureButton = $RightArrow


## Do not change this directly. Use [method setWidgetValue] instead.
var choosed_index: int = 0:
    set(new_index):
        choosed_index = new_index
        self.changed.emit(self.getWidgetValue())

var stepper_list: Array[String]:
    get:
        if self.option_row__ref != null:
            return (self.option_row__ref.param as SettingStepperWidgetParam).stepper_list
        else:
            # Do not print error when SettingStepperWidget is just created in editor.
            if not Engine.is_editor_hint():
                printerr("option_row__ref is not found.")
            return []


@onready var label__ref: Label = $Label


func _ready() -> void:
    super.__onReady__() # `super()` does not work here.
    self.__onReady__()


## Set the string value of settings, update the label's text.
func setWidgetValue(value: Variant):
    if value is not String:
        printerr("Invalid data: ", value)
        return

    var index = self.stepper_list.find(value)
    if index < 0:
        printerr("Value `", value, "` not found in list.")
        return
    else:
        self.choosed_index = index

    self.label__ref.text = self.stepper_list[self.choosed_index]

func getWidgetValue():
    return self.stepper_list[self.choosed_index]

func onReceivingLeftAction():
    var list = self.stepper_list
    var len_list = list.size()
    self.choosed_index = (self.choosed_index - 1 + len_list) % len_list
    self.label__ref.text = list[self.choosed_index]

func onReceivingRightAction():
    var list = self.stepper_list
    var len_list = list.size()
    self.choosed_index = (self.choosed_index + 1) % len_list
    self.label__ref.text = list[self.choosed_index]

func __onReady__():
    self.choosed_index = 0
    if self.stepper_list.size() > 0:
        self.label__ref.text = self.stepper_list[0]

    if not self.left_arrow__ref.pressed.is_connected(self.onReceivingLeftAction):
        self.left_arrow__ref.pressed.connect(self.onReceivingLeftAction)
    if not self.right_arrow__ref.pressed.is_connected(self.onReceivingRightAction):
        self.right_arrow__ref.pressed.connect(self.onReceivingRightAction)
