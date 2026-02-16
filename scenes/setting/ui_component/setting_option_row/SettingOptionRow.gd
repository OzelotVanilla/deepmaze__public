@tool
class_name SettingOptionRow
extends PanelContainer
## The long panel contains the settings label and control
##
## [code]@tool[/code]-annotated for seeing the effect of changing text in editor.


const normal_stylebox = preload(
    "res://ui_component/button/dotted_bg_button/DottedBgButton_normal_stylebox.tres"
)

const focus_stylebox = preload(
    "res://ui_component/button/dotted_bg_button/DottedBgButton_focus_stylebox.tres"
)

const slider_widget = preload(
    "res://scenes/setting/ui_component/setting_option_row/widget/SettingSliderWidget.tscn"
)

const toggle_widget = preload(
    "res://scenes/setting/ui_component/setting_option_row/widget/SettingToggleWidget.tscn"
)

const stepper_widget = preload(
    "res://scenes/setting/ui_component/setting_option_row/widget/SettingStepperWidget.tscn"
)


enum OptionCategory
{
    ## Do not show widget at right.
    none,
    ## Show a left/right arrow for choosing though list.
    stepper,
    ## ON/OFF toggle.
    toggle,
    ## Slider that allows fine adjusting.
    slider,
}


@onready var option_label__ref: Label = $Margin/HBox/OptionLabel

@onready var widget_slot__ref: Control = $Margin/HBox/WidgetSlot


## Could be [SettingStepperWidget], [SettingToggleWidget] or [SettingSliderWidget].
var widget: SettingWidget


## The specific parameter of this setting row
@export var param: SettingWidgetParam:
    set(new_param):
        param = new_param
        if not new_param.changed.is_connected(self.updateFromParam):
            new_param.changed.connect(self.updateFromParam)
        self.updateFromParam()


func _ready() -> void: self.__onReady__()
func _input(event: InputEvent) -> void: self.__handleInput__(event)


func onReceivingLeftAction():
    pass

func onReceivingRightAction():
    pass

func onReceivingValueFromWidget(value: String):
    pass

## Update the UI and function of this setting row from [param param].
func updateFromParam():
    if not self.is_inside_tree() or self.param == null:
        return

    self.option_label__ref.text = self.param.label_text
    # Instantiate widget to WidgetSlot.
    for c in self.widget_slot__ref.get_children(): c.queue_free()
    if   self.param is SettingStepperWidgetParam:
        var stepper = SettingOptionRow.stepper_widget.instantiate() as SettingWidget
        self.widget_slot__ref.add_child(stepper)
        self.widget = stepper
    elif self.param is SettingToggleWidgetParam:
        var toggle = SettingOptionRow.toggle_widget.instantiate() as SettingWidget
        self.widget_slot__ref.add_child(toggle)
        self.widget = toggle
    elif self.param is SettingSliderWidgetParam:
        var slider = SettingOptionRow.slider_widget.instantiate() as SettingWidget
        self.widget_slot__ref.add_child(slider)
        self.widget = slider
    else:
        printerr("Unsupported param of SettingOptionRow.")

    self.widget.param = self.param

    # Retrieve the config from file, and pass it to widget.
    if not Engine.is_editor_hint():
        self.retrieveFromConfig()

## Retrieve the current config setting, update UI.
func retrieveFromConfig():
    if config_manager.config == null:
        #printerr(
            #"Config file not found. It should be already loaded/created",
            #" when `SettingOptionRow.retrieveFromConfig` is runned.",
            #"Trying to load config from local file."
        #)
        config_manager.loadFromLocalFile()

    self.widget.setWidgetValue(
        config_manager.config.get(self.widget.param.config_name)
    )

func refreshStylebox():
    self.remove_theme_stylebox_override("panel")

    # Check focus state and give proper stylebox.
    if self.has_focus():
        self.add_theme_stylebox_override("panel", focus_stylebox)
    else:
        self.add_theme_stylebox_override("panel", normal_stylebox)

func __onReady__():
    # # Realtime update of UI.
    if self.param != null:
        if not self.param.changed.is_connected(self.updateFromParam):
            self.param.changed.connect(self.updateFromParam)
        self.updateFromParam()

    # # Stylebox.
    self.add_theme_stylebox_override(
        "panel",
        DottedBgButton.normal_stylebox
    )

    # # Signal.
    self.mouse_entered.connect(self.refreshStylebox)
    self.mouse_exited.connect(self.refreshStylebox)
    self.focus_entered.connect(self.refreshStylebox)
    self.focus_exited.connect(self.refreshStylebox)

    self.mouse_entered.connect(
        func():
            self.grab_focus()
    )

func __handleInput__(event: InputEvent):
    if not self.has_focus():
        return

    if   event.is_action_pressed("ui_left", true):
        self.widget.onReceivingLeftAction()
    elif event.is_action_pressed("ui_right", true):
        self.widget.onReceivingRightAction()
