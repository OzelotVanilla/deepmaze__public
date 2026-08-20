@tool
class_name DMFSContent
extends Resource
## Content of the file-typed [DMFSNode].


enum StorageType
{
    ## Value not set.
    not_set,
    ## The content is inline-stored to resource file.
    inline,
    ## The content is referring an existing asset.
    ## Should not allow most editing.
    referring_asset
}

enum DataType
{
    ## Value not set.
    not_set,
    ## The content is text, allowing text operation.
    text_based,
    ## The content is binary, not allowing text operation.
    binary
}


## The way that data is stored in resource file.
@export var storage_type: StorageType:
    set(new_type):
        if storage_type != new_type:
            storage_type = new_type
            self.notify_property_list_changed()

## The form of the content.[br][br]
##
## [b]Notice[/b]: This field will be automatically set-ed
##  if [member storage_type] is [enum StorageType.asset_ref],
##  since [member data_type] can be deduced from the class inheriting [DMFSAssetRef].
@export var data_type: DataType:
    set(new_type):
        if data_type != new_type:
            data_type = new_type
            self.notify_property_list_changed()

## The text of the content.
## Will be showed in terminal if command such as [code]cat[/code] is used.
@export var text: String = "":
    set(new_value):
        text = new_value
        self.changed.emit()

## The actual resource referencing to.
## If this is empty, means no resource file is referencing.
@export var asset_ref: DMFSAssetRef

## Whether the file is inline-stored.
var is_inline_stored: bool:
    get():
        return self.storage_type == StorageType.inline

## Whether the file is referring to an asset.
var is_referring_asset: bool:
    get():
        return self.storage_type == StorageType.referring_asset

## Whether the current content is a text-based.
var is_text_file: bool:
    get():
        return self.data_type == DataType.text_based

## Whether the current content is referring a binary content.
var is_binary: bool:
    get():
        return self.data_type == DataType.binary


func _validate_property(property: Dictionary) -> void: self.__onValidateProperty__(property)


func __onValidateProperty__(property: Dictionary):
    if property.name == "text" and self.is_referring_asset:
        property.usage = PropertyUsageFlags.PROPERTY_USAGE_NO_EDITOR
    if property.name == "asset_ref" and self.is_inline_stored:
        property.usage = PropertyUsageFlags.PROPERTY_USAGE_NO_EDITOR
