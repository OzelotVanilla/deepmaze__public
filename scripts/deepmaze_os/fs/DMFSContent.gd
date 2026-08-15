class_name DMFSContent
extends Resource
## Content of the file-typed [DMFSNode].


## The text representation of the content.
## Will be showed in terminal if command such as [code]cat[/code] is used.
@export var text_repr: String = "":
    set(new_value):
        text_repr = new_value
        can_link_to_actual_resource = false
        self.changed.emit()

## The actual resource referencing to.
## If this is empty, means no resource file is referencing.
@export var actual_resource_path: StringName = ""

var can_link_to_actual_resource: bool = true
