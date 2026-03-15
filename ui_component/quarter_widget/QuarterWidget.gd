class_name QuarterWidget
extends PanelContainer


func _enter_tree() -> void: self.__onEnterTree__()
func _exit_tree() -> void: self.__onExitTree__()


@onready var count_label__ref: Label = $HBoxContainer/CountLabel


## Will read the save data's quarter count,
##  does not include the buffered game state diff data.
func readQuarterValueFromSave():
    save_manager.ensureLoaded()

    if save_manager.save.currency != null:
        self.count_label__ref.text = str(save_manager.save.currency.quarter_count)

func __onEnterTree__():
    self.ready.connect(
        self.readQuarterValueFromSave,
        ConnectFlags.CONNECT_ONE_SHOT
    )

    if not save_manager.isLocalSaveFileExist():
        return

    save_manager.ensureLoaded()

    if save_manager.save.currency != null:
        save_manager.save.currency.changed.connect(self.readQuarterValueFromSave)

func __onExitTree__():
    if save_manager.save.currency.changed.is_connected(self.readQuarterValueFromSave):
        save_manager.save.currency.changed.disconnect(self.readQuarterValueFromSave)
