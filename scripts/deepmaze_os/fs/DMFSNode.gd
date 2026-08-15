class_name DMFSNode
extends Resource
## Represents a DeepMazeOS file or folder


## Emits when the [member children] or [member content] is modified.
signal modified()


enum Type
{
    ## File, [member content] is available.
    file,
    ## Folder, [member children] is available.
    folder
}


## The type of this FS node.
@export var type: Type

## The name of this FS node.[br][br]
##
## If [member type] is [enum Type.file], this stands for the file's name.[br]
## If [member type] is [enum Type.folder], this stands for the folder's name.
@export var name: String

## The time (real-world-time) of creation for this FS node.
@export var time_of_creation: float

## The time (real-world-time) of last modification for this FS node.
@export var time_of_last_modify: float

## Access permission of the FS node.
@export var permission: DMPermission.User

## Content of this file (FS node).[br][br]
##
## Unavailable if [member type] is [enum Type.folder].
## If folder, [member children] is available.
@export var content: DMFSContent

## Content of this folder (FS node).
## Do [b]NOT[/b] modify this directly. Use method such as [method addChild] instead. [br][br]
##
## Unavailable if [member type] is [enum Type.file].
## If file, [member content] is available.
@export var children: Array[DMFSNode] = []

## If current FS node is a file.
var is_file:
    get():
        return self.type == Type.file

## If current FS node is a folder.
var is_folder:
    get():
        return self.type == Type.folder


## Create an empty named file.
static func createFile(file_name: String) -> DMFSNode:
    var fs_node := DMFSNode.new()
    fs_node.type = Type.file
    fs_node.name = file_name

    return fs_node

## Create an empty named folder.
static func createFolder(folder_name: String) -> DMFSNode:
    var fs_node := DMFSNode.new()
    fs_node.type = Type.folder
    fs_node.name = folder_name

    return fs_node

## Add a new child [param fs_node] to this [b]folder-typed[/b] FS node.[br][br]
##
## [b]Fails[/b] and return [enum Error.ERR_CANT_OPEN] if current FS node is a file.
## Triggers assertion error in debug build.
func addChild(fs_node: DMFSNode) -> Error:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.addChild` on a file-type.")

    if self.is_file:
        return Error.ERR_CANT_OPEN

    fs_node.time_of_creation = DMPC.getZonedTimestamp()
    fs_node.updateTimeOfLastModify()
    self.children.append(fs_node)

    self.modified.emit()
    return Error.OK

## Remove the child [param fs_node] from this [b]folder-typed[/b] FS node.[br][br]
##
## [b]Fails[/b] and return:[br]
## * [enum Error.ERR_CANT_OPEN]: If current FS node is a file.
##   Triggers assertion error in debug build.[br]
## * [enum Error.ERR_DOES_NOT_EXIST]: If the FS node to remove does not exists in this FS node.
func removeChild(fs_node: DMFSNode) -> Error:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.removeChild` on a file-type.")

    if self.is_file:
        return Error.ERR_CANT_OPEN

    if not self.children.has(fs_node):
        return Error.ERR_DOES_NOT_EXIST

    self.children.erase(fs_node)

    self.modified.emit()
    return Error.OK

## Check if this [b]folder-typed[/b] FS node is empty.[br][br]
##
## Returns [code]false[/code] and print debug error message if current FS node is a file.
## Triggers assertion error in debug build.
func isEmptyFolder() -> bool:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.isEmptyFolder` on a file-type.")

    return self.children.size() <= 0

## Get this [b]folder-typed[/b] FS node's children (shallow copy of [member children]).[br][br]
##
## Returns [code][][/code] and print debug error message if current FS node is a file.
## Triggers assertion error in debug build.
func getChildren() -> Array[DMFSNode]:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.getChildren` on a file-type.")

    return self.children.duplicate()

## Check if this [b]folder-typed[/b] FS node has a child [param fs_node].[br][br]
##
## Returns [code]false[/code] and print debug error message if current FS node is a file.
## Triggers assertion error in debug build.
func hasChild(fs_node: DMFSNode) -> bool:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.hasChild` on a file-type.")

    return self.children.has(fs_node)

## Check if this [b]folder-typed[/b] FS node has a child
##  that name is [param fs_node_name].[br][br]
##
## Returns [code]false[/code] and print debug error message if current FS node is a file.
## Triggers assertion error in debug build.
func hasChildWithName(fs_node_name: String) -> bool:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.hasChildWithName` on a file-type.")

    return \
        self.children.find_custom(
            func(f: DMFSNode): return f.name == fs_node_name
        ) >= 0

## Get this [b]folder-typed[/b] FS node's child by name.[br][br]
##
## Returns [code]null[/code] and print debug error message if current FS node is a file.
## Triggers assertion error in debug build.[br]
## Returns [code]null[/code] if not found.
func getChildByName(fs_node_name: String) -> DMFSNode:
    assert(self.is_folder, "Error: Cannot call `DMFSNode.getChildByName` on a file-type.")

    for node in self.children:
        if node.name == fs_node_name:
            return node

    return null

## Append content to this [b]file-typed[/b] FS node.[br][br]
##
## [b]Fails[/b] and return:[br]
## * [enum Error.ERR_CANT_OPEN]: If current FS node is a folder.
##   Triggers assertion error in debug build.[br]
## * [enum Error.ERR_DOES_NOT_EXIST]: If the FS node to remove does not exists in this FS node.
func appendContent() -> Error:
    assert(self.is_file, "Error: Cannot call `DMFSNode.appendContent` on a folder-type.")

    if self.is_folder:
        return Error.ERR_CANT_OPEN

    return Error.OK

func updateTimeOfLastModify() -> void:
    self.time_of_last_modify = DMPC.getZonedTimestamp()

func _init() -> void:
    if not self.modified.is_connected(self.__on_modified):
        self.modified.connect(self.__on_modified)

func __on_modified():
    self.updateTimeOfLastModify()
