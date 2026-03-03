class_name CollectedItemVBox
extends PanelContainer
## Show the item ([CollectedItemDetail]) in a scrollable vbox, can show a "new" label


## When a row is focused.
## Helpful for setting [member CollectedItemDetail.whether_new] to false.
signal row_focus_entered(row: CollectedItemVBoxRow)


const packed_row_scene = preload(
    "res://ui_component/container/collected_item_vbox/CollectedItemVBoxRow.tscn"
)


@onready var vbox__ref: VBoxContainer = $Margin/Scroll/VBox

@onready var label__ref: Label = $Margin/NothingToSeeLabel


var item_dict: Dictionary[Variant, CollectedItemVBoxRow] = {}

var first_row__ref: CollectedItemVBoxRow = null

var last_focused_row__ref: CollectedItemVBoxRow = null


func _ready() -> void: self.__onReady__()


## Will be add at the end of the list.
## The first line will be used as the item's name.
func addItem(
    item_key: Variant,
    item_title: String,
    item_timestamp: float,
    item_whether_new: bool,
    item_pic_path: StringName = ""
):
    var row: CollectedItemVBoxRow = CollectedItemVBox.packed_row_scene.instantiate()
    row.item_key = item_key
    ## Name should be the first line of item.
    row.item_name = item_title
    row.item_whether_new = item_whether_new
    row.item_pic_path = item_pic_path
    row.item_vbox__ref = self
    row.focus_entered.connect(
        func():
            self.row_focus_entered.emit(row)
    )

    # When "new" is not shown, do not let space expand to right to grab focus.
    row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

    self.item_dict.set(item_key, row)
    self.vbox__ref.add_child(row)

    if self.first_row__ref == null:
        self.first_row__ref = row

    self.refreshDisplayStatus()

func removeItem(item_key: Variant):
    if not self.item_dict.has(item_key):
        printerr(str("No such ItemVBoxRow with key `", item_key, "`."))

    var row_obj: CollectedItemVBoxRow = self.item_dict.get(item_key)
    self.item_dict.erase(item_key)
    self.vbox__ref.remove_child(row_obj)
    row_obj.queue_free()

    self.refreshDisplayStatus()

## Decide whether show item list, or show nothing-to-see label.
## This method does not modify the items in [code]VBox[/code].
func refreshDisplayStatus():
    if self.item_dict.size() <= 0:
        self._showAsNoItem()
    else:
        self._showItems()

## Do not call this method until necessary.
## Let the container to detect if it has children or not.[br][br]
##
## Show a label that tells users there is no item.
func _showAsNoItem():
    self.label__ref.show()
    self.vbox__ref.hide()

## Do not call this method until necessary.
## Let the container to detect if it has children or not.[br][br]
##
## Show item list.
func _showItems():
    self.vbox__ref.show()
    self.label__ref.hide()

func __onReady__():
    pass
