class_name CollectedItemVBoxRow
extends HBoxContainer
## Child of [CollectedItemVBox], showing one row of item.


@onready var dotted_bg_button__ref: DottedBgButton = $DottedBgButton

@onready var spacer__ref: Control = $Spacer

@onready var new_label__ref: Label = $NewLabel


## Name to show in the [DottedBgButton].
var item_name: String:
    set(new_name):
        item_name = new_name
        if self.is_node_ready():
            self.dotted_bg_button__ref.text = item_name
        else:
            self.ready.connect(func():
                self.dotted_bg_button__ref.text = item_name,
                ConnectFlags.CONNECT_ONE_SHOT
            )

## Whether this row should show "NEW" label on the right of the [DottedBgButton].
var item_whether_new: bool = false:
    set(whether_new):
        item_whether_new = whether_new
        if self.is_node_ready():
            self.new_label__ref.visible = whether_new
        else:
            self.ready.connect(func():
                self.new_label__ref.visible = whether_new
                self.spacer__ref.visible = whether_new,
                ConnectFlags.CONNECT_ONE_SHOT
            )

var item_pic_path: StringName = ""

var item_key: Variant

var item_vbox__ref: CollectedItemVBox


func _ready() -> void: self.__onReady__()


func __onMouseEntered():
    self.release_focus() # For triggering `self.__onFocusEntered` again.
    self.grab_focus()

func __onMouseExited():
    # Do not release focus here.
    # If player press enter, and mouse does not move to another place that should grab focus,
    #  game should proceed.
    pass

## Set to deferred mode, since other receiver might need to check
##  [member item_whether_new].
func __onFocusEntered():
    self.dotted_bg_button__ref.should_show_focus_style = true
    self.item_vbox__ref.last_focused_row__ref = self
    self.item_whether_new = false

func __onFocusExited():
    # In case this scene is under gc.
    if self.dotted_bg_button__ref.is_inside_tree():
        self.dotted_bg_button__ref.should_show_focus_style = false
        self.dotted_bg_button__ref.release_focus()

func __onReady__():
    self.mouse_entered.connect(self.__onMouseEntered)
    self.mouse_exited.connect(self.__onMouseExited)
    self.focus_entered.connect(self.__onFocusEntered.call_deferred)
    self.focus_exited.connect(self.__onFocusExited)
    self.dotted_bg_button__ref.focus_entered.connect(self.__onMouseEntered)
