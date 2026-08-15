class_name DMFS
extends Resource
## File System in DeepMaze OS, hold ability of make/modify/delete files in the OS


## The root directory [code]/[/code] of the file system.[br][br]
##
## [b]Notice[/b]: Do not be confused with [code]/root[/code],
##  which stands for the home directory for user [code]root[/codee].
@export var root_dir := DMFSNode.createFolder("root")


## Only accepts absolute directory as [param path].[br][br]
##
## Returns [code]null[/code] if could not found.
func getFSNode(path: String) -> DMFSNode:
    if path.is_empty():
        return null

    var result: DMFSNode = self.root_dir
    var names: Array[String]
    names.assign(path.split("/", false))
    if names.size() == 0:
        return result # Getting `/` dir.

    # # Traverse directories.
    for name in names.slice(0, -1): # Do not allow empty element.
        result = result.getChildByName(name)
        if result == null:
            return null
        if result.is_file: # Should be directory, otherwise no `children`.
            return null

    # # Handle last `name` in `names`.
    # Do not need to check if null, just return.
    return result.getChildByName(names.back())

## Create an FS node at given dir.
## Will assign time-of-creation and modification at the time this method is executed.[br][br]
##
## Returns error for these conditions:[br]
## * [enum Error.ERR_FILE_BAD_PATH]: If given [param target_dir_path] does not exists.[br]
## * [enum Error.ERR_CANT_CREATE]: If given [param target_dir_path] resolves to a file.[br]
## * [enum Error.ERR_ALREADY_EXISTS]: If there is already a file/folder named [param name].
func createFSNodeAt(
    target_dir_path: String, name: String,
    type: DMFSNode.Type
) -> Error:
    var fs_node := self.getFSNode(target_dir_path)

    # Invalid path.
    if fs_node == null:
        return Error.ERR_FILE_BAD_PATH
    # Target dir path resolves to file, not folder.
    if fs_node.is_file:
        return Error.ERR_CANT_CREATE
    # If already exists same-name file/folder.
    if fs_node.hasChildWithName(name):
        return Error.ERR_ALREADY_EXISTS

    var new_fs_node: DMFSNode
    match type:
        DMFSNode.Type.file:
            new_fs_node = DMFSNode.createFile(name)
        DMFSNode.Type.folder:
            new_fs_node = DMFSNode.createFolder(name)

    new_fs_node.time_of_creation = DMPC.getZonedTimestamp()
    new_fs_node.time_of_last_modify = new_fs_node.time_of_creation

    fs_node.addChild(new_fs_node)

    return Error.OK
