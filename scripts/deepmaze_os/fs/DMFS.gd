class_name DMFS
extends Resource
## File System in DeepMaze OS, hold ability of make/modify/delete files in the OS
##
## [DMFS] will provide API to access the data stored in the PC ([DMFSNode]s).
## However, it forces permission check for most API.[br][br]
##
## Please use the permission-checked API for the most time.


## The root directory [code]/[/code] of the file system.[br][br]
##
## [b]Notice[/b]: Do not be confused with [code]/root[/code],
##  which stands for the home directory for user [code]root[/code].
@export var root_dir := DMFSNode.createFolder("root")


## Fetch corresponding [b]raw[/b] [DMFSNode] at [param path]
##  (only accepts absolute directory) inside [DMFSResult].[br][br]
##
## This method should only be used inside [DMFS].
## To access the dir structure or content of files,
##  use other provided API instead.[br][br]
##
## Use [method getRawFSNode] if error info is not important.[br][br]
##
## Returns:[br]
## * [code]/path/file[/code]: [DMFSResult] with [DMFSNode] inside.[br]
## * [code]/path/file/[/code]: [enum DMFSResult.Error.not_folder].[br]
## * [code]/path/file/something[/code]: [enum DMFSResult.Error.not_folder].[br]
## * [code]/path/folder[/code]: [DMFSResult] with [DMFSNode] inside.[br]
## * [code]/path/folder/[/code]: [DMFSResult] with [DMFSNode] inside.[br]
## * [code]/missing[/code]: [enum DMFSResult.Error.not_found].[br]
## * [code]/[/code]: [DMFSResult] with [DMFSNode] (of root dir) inside.[br]
## * nothing: [enum DMFSResult.Error.path_invalid].[br]
func resolveRawPath(path: String) -> DMFSResult:
    if path.is_empty():
        return DMFSResult.createError(
            DMFSResult.Error.path_invalid,
            "Provided path is empty."
        )
    if not path.begins_with("/"):
        return DMFSResult.createError(
            DMFSResult.Error.path_invalid,
            str(
                "Provided path is not an absolute path: `",
                path, "`."
            )
        )

    var result: DMFSNode = self.root_dir
    var names: Array[String]
    names.assign(path.split("/", false))

    # # If getting `/` dir.
    if names.size() == 0:
        return DMFSResult.createOK(result)

    # # Traverse directories.
    var path_checking: String = "/"
    for name in names.slice(0, -1): # Do not allow empty element.
        path_checking = path_checking.path_join(name)
        result = result.getChildByName(name)
        # Not exists
        if result == null:
            return DMFSResult.createError(
                DMFSResult.Error.not_found,
                str(
                    "Provided path does not exists: `",
                    path, "`."
                )
            )
        if result.is_file: # Should be directory, otherwise no `children`.
            return DMFSResult.createError(
                DMFSResult.Error.not_folder,
                str(
                "File used as a folder: `",
                path_checking, "`."
            )
            )

    # # Handle last `name` in `names`.
    var fs_node := result.getChildByName(names.back())

    if fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                path, "`."
            )
        )
    # Consider the FS node not exists if inquery a file with trailing "/".
    elif fs_node.is_file and path.ends_with("/"):
        return DMFSResult.createError(
            DMFSResult.Error.not_folder,
            str(
                "Provided path is not a folder: `",
                path, "`."
            )
        )
    else:
        return DMFSResult.createOK(fs_node)

## Fetch corresponding [b]raw[/b] [DMFSNode] at [param path]
##  (only accepts absolute directory).[br][br]
##
## This method should only be used inside [DMFS].
## To access the dir structure or content of files,
##  use other provided API instead.[br][br]
##
## Use [method resolveRawPath] if need to know the detailed reason of error.[br][br]
##
## Returns:[br]
## * [code]/path/file[/code]: [DMFSNode][br]
## * [code]/path/file/[/code]: [code]null[/code][br]
## * [code]/path/file/something[/code]: [code]null[/code][br]
## * [code]/path/folder[/code]: [DMFSNode][br]
## * [code]/path/folder/[/code]: [DMFSNode][br]
## * [code]/missing[/code]: [code]null[/code][br]
## * [code]/[/code]: [DMFSNode] of root dir.[br]
## * nothing: [code]null[/code].[br]
func getRawFSNode(path: String) -> DMFSNode:
    var resolve_result := self.resolveRawPath(path)
    if resolve_result.is_ok:
        return resolve_result.value
    else:
        return null

## Check if specified [param path] (in absolute path) could be accessed
##  by checking if each directory has enough [code]x[/code] permission.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: [code]x[/code].[br]
## * Final Directory: [code]x[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path] resolves to a file.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path].[br]
func checkDirTraversal(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    if path.is_empty():
        return DMFSResult.createError(
            DMFSResult.Error.path_invalid,
            "Provided path is empty."
        )

    var result: DMFSNode = self.root_dir
    var names: Array[String]
    names.assign(path.split("/", false))
    if names.size() == 0: # Getting `/` dir.
        # `/` should be always traversable.
        return DMFSResult.createOK()

    # # Traverse directories.
    var path_checking: String = "/"
    for name in names: # Do not allow empty element.
        path_checking = path_checking.path_join(name)
        result = result.getChildByName(name)
        if result == null:
            return DMFSResult.createError(
                DMFSResult.Error.not_found,
                str(
                    "Provided path does not exists: `",
                    path_checking, "`."
                )
            )
        if result.is_file: # Should be directory, otherwise no `children`.
            return DMFSResult.createError(
                DMFSResult.Error.not_folder,
                str(
                    "Provided path resolves to a file, not a folder: `",
                    path_checking, "`."
                )
            )
        if result.exec_permission > actor:
            return DMFSResult.createError(
                DMFSResult.Error.permission_denied,
                str(
                    "No enough permission to traverse to provided path: `",
                    path_checking, "`."
                )
            )

    return DMFSResult.createOK()

## Create an FS node at given dir.
## Will assign time-of-creation and modification at the time this method is executed.[br][br]
##
## The read/write/exec permission of created FS node,
##  is the [b]same[/b] as the [param actor].[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: [code]w+x[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param target_dir_path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If given [param target_dir_path] resolves to a file.[br]
## * [enum DMFSResult.Error.already_exists]:
##   If there is already a file/folder named [param name].[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing [param target_dir_path],
##    or does not have [code]x[/code] permission for intermediate dir.[br]
func create(
    target_dir_path: String, name: String,
    type: DMFSNode.Type,
    actor: DMPermission.Level
) -> DMFSResult:
    if not target_dir_path.ends_with("/"):
        target_dir_path = str(target_dir_path, "/")

    # # Check `x` for intermediate first.
    var traverse_result := self.checkDirTraversal(target_dir_path, actor)
    if traverse_result.is_error:
        return traverse_result
    var fs_node := self.getRawFSNode(target_dir_path)

    # Invalid path.
    if fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                target_dir_path, "`."
            )
        )
    # Target dir path resolves to file, not folder.
    if fs_node.is_file:
        return DMFSResult.createError(
            DMFSResult.Error.not_folder,
            str(
                "Provided path is not a folder: `",
                target_dir_path, "`."
            )
        )
    # If already exists same-name file/folder.
    if fs_node.hasChildWithName(name):
        return DMFSResult.createError(
            DMFSResult.Error.already_exists,
            str(
                "File/Folder asked to create already exists: `",
                target_dir_path.path_join(
                    name if type == DMFSNode.Type.file else str(name, "/")
                ), "`."
            )
        )
    # No enough permission.
    if fs_node.write_permission > actor or fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to create file/folder at: `",
                target_dir_path, "`."
            )
        )

    var new_fs_node: DMFSNode
    match type:
        DMFSNode.Type.file:
            new_fs_node = DMFSNode.createFile(name)
        DMFSNode.Type.folder:
            new_fs_node = DMFSNode.createFolder(name)

    new_fs_node.time_of_creation = DMPC.getZonedTimestamp()
    new_fs_node.time_of_last_modify = new_fs_node.time_of_creation
    new_fs_node.read_permission  = actor
    new_fs_node.write_permission = actor
    new_fs_node.exec_permission  = actor

    fs_node.addChild(new_fs_node)

    return DMFSResult.createOK()
