class_name GameRelicPage
extends BaseGameScene
## Showing collected relic.
##
## Code copied from [GameExplorationLogPage].


@onready var item_vbox__ref: CollectedItemVBox = $Margin/OutVBox/MainHBox/ItemVBox

@onready var text_box__ref: ScrollableTextBox = $Margin/OutVBox/MainHBox/VBox/TextBox

@onready var picture_box__ref: CollectedItemShowcase = $Margin/OutVBox/MainHBox/VBox/PictureBox


func _ready() -> void:
    super()
    self.__onReady__()

func _unhandled_input(event: InputEvent) -> void: self.__handleUnprocessedInput__(event)


func on_CollectedItemVBox_row_focus_entered(row: CollectedItemVBoxRow):
    # Adjust the UI.
    self.setTextToShow(tr(RelicTextEntry.getPOIDForText(row.item_key)))
    self.text_box__ref.scroll_offset = 0 # In case it is scrolled before.
    self.setPictureToShow(row.item_pic_path)

    # If there is a "new" sign, turn it off.
    if row.item_whether_new == true and save_manager.save != null:
        var index = save_manager.save.collected_item.relic.find_custom(
            func (e: CollectedItemDetail): return e.item_id == row.item_key
        )
        if index > -1:
            save_manager.save.collected_item.relic[index].whether_new = false
        else:
            printerr(
                "GameRelicPage: ",
                "entry not found for `on_CollectedItemVBox_row_focus_entered`."
            )

## Go back to the outer page.
func goBack():
    # Save the changes if a "new" item is viewed.
    if save_manager.save != null:
        save_manager.saveToLocalFile()

    self.root_scene__ref.popScene()

## If offset is set, the scroll box will accept that.
func setTextToShow(text: String):
    if text.length() <= 0:
        self.text_box__ref.text = tr("ui.nothing_to_see_here")
    else:
        self.text_box__ref.text = text

func setPictureToShow(pic_path: StringName):
    if pic_path.length() <= 0 or not FileAccess.file_exists(pic_path):
        self.picture_box__ref.pic_path = ""
    else:
        self.picture_box__ref.pic_path = pic_path

## This function loads the collected relic,
##  put them into log item box.
func loadCollectedRelic():
    if save_manager.isLocalSaveFileExist():
        save_manager.ensureLoaded()
        for d in save_manager.save.collected_item.relic:
            self.item_vbox__ref.addItem(
                d.item_id, # key
                tr(RelicTextEntry.getPOIDForTitle(d.item_id)),
                d.timestamp_of_obtained,
                d.whether_new,
                d.pic_path
            )

func __onReady__():
    self.loadCollectedRelic()
    if not self.item_vbox__ref.row_focus_entered.is_connected(
        self.on_CollectedItemVBox_row_focus_entered
    ):
        self.item_vbox__ref.row_focus_entered.connect(
            self.on_CollectedItemVBox_row_focus_entered
        )

    # Select first item if exists.
    if self.item_vbox__ref.first_row__ref != null:
        self.item_vbox__ref.first_row__ref.grab_focus()

    self.request_ready()

func __handleUnprocessedInput__(event: InputEvent):
    if event.is_action_pressed("ui_cancel"):
        self.get_viewport().set_input_as_handled()
        self.goBack()
