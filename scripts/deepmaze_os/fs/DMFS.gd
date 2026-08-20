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

## List the meta inside a directory of [param path] (should be absolute path).[br]
## Returns array of [DMFSNode.Meta] if success.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: [code]x[/code].[br]
## * Final Directory: [code]r+x[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path] resolves to a file.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path].[br]
func listDir(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Check existance, `x` permission and folder-ness.
    var traverse_result := self.checkDirTraversal(path, actor)
    if traverse_result.is_error:
        return traverse_result

    # # Check read permission of target node.
    var fs_node := self.getRawFSNode(path)
    if fs_node.read_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to read the content of folder: `",
                path, "`."
            )
        )

    # # Return the meta info.
    var meta_arrar: Array[DMFSNode.Meta] = []
    for child_node in fs_node.children:
        meta_arrar.append(child_node.meta)

    return DMFSResult.createOK(meta_arrar)

## Get the meta information of the FS node at [param path] (should be absolute path).[br]
## Returns [DMFSNode.Meta] if success.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: none.[br]
## * Final Directory: none.[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path] resolves to a file.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path].[br]
func stat(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Check existance, `x` permission and folder-ness.
    var traverse_result := self.checkDirTraversal(path.get_base_dir(), actor)
    if traverse_result.is_error:
        return traverse_result

    # # OK to return the meta info
    var fs_node := self.getRawFSNode(path)
    if fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                path, "`."
            )
        )

    return DMFSResult.createOK(fs_node.meta)

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

## Update the last modification time of a file/folder.
## If attempting to touch a non-exists file, create it instead.
## However, if the parent folder does not exist,
##  it will fail.[br][br]
##
## Checks permission for (if target exists):[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Target: [code]w[/code].[br][br]
##
## Checks permission for (if target [b]not[/b] exists):[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: [code]w+x[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param path] does not exists.
##   Or, creating a new file but parent folder does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If given [param path] contains a name that is a file but used as a folder.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing [param path],
##    or does not have enough permission for parent dir to create a new file.[br]
func touch(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Check if can traverse first.
    var traverse_result := self.checkDirTraversal(path.get_base_dir(), actor)
    if traverse_result.is_error:
        return traverse_result # Might be permission error.

    # # Check if target exists.
    var resolve_result := self.resolveRawPath(path)
    # If target exists and could be accessed, try update last modify timestamp.
    if resolve_result.is_ok:
        var fs_node: DMFSNode = resolve_result.value
        var parent_path := DMFS.getParentPath(path)

        # Check target `w` (intermediate `x` permission checked before).
        var parent__fs_node := self.getRawFSNode(parent_path) # must exists
        if parent__fs_node.exec_permission > actor:
            return DMFSResult.createError(
                DMFSResult.Error.permission_denied,
                str(
                    "No enough permission to access children inside this folder: `",
                    parent_path, "`."
                )
            )
        elif fs_node.write_permission > actor:
            return DMFSResult.createError(
                DMFSResult.Error.permission_denied,
                str(
                    "No enough permission to touch file: `",
                    parent_path, "`."
                )
            )
        else:
            fs_node.updateTimeOfLastModify()
            return DMFSResult.createOK(
                null,
                str("Last modification time updated: `", path, "`.")
            )
    # If `touch` target does not exists.
    elif resolve_result.error == DMFSResult.Error.not_found:
        # Check if touching a file.
        if not path.ends_with("/"): # Create it instead.
            # # Check if parent folder exists.
            var parent_path := path.get_base_dir()
            var parent__resolve_result := self.resolveRawPath(parent_path)
            if parent__resolve_result.is_ok:
                # Check parent `w+x` permission in `create`.
                var create_result := self.create(
                    parent_path, path.get_file(),
                    DMFSNode.Type.file, actor
                )
                if create_result.is_ok:
                    return DMFSResult.createOK(
                        null,
                        str("Created file: `", path, "`.")
                    )
                else:
                    return create_result
            else: # Cannot resolve parent folder of the file-to-create.
                return parent__resolve_result
        # Touching non-existing folder.
        else:
            # Just return the error.
            return resolve_result
    # If anything else not correct when resolving target path.
    else:
        # Just return the error.
        return resolve_result

## Remove (delete) the target file/folder.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: [code]w+x[/code].[br]
## * Target: none.[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param path] does not exists.
##   Or, creating a new file but parent folder does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If given [param path] contains a name that is a file but used as a folder.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for removing [param path],
##    or no enough permission for accessing one of the folder in the given [param path].[br]
## * [enum DMFSResult.Error.operation_not_allowed]:
##   If attempting to remove root directory.[br]
func remove(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Do not allow to remove root dir itself.
    if path == "/":
        return DMFSResult.createError(
            DMFSResult.Error.operation_not_allowed,
            "Cannot remove the root directory."
        )

    # # Check `x` for intermediate.
    var parent_path := DMFS.getParentPath(path)
    var traverse_result := self.checkDirTraversal(parent_path, actor)
    if traverse_result.is_error:
        return traverse_result

    # # Check permission.
    var parent__fs_node := self.getRawFSNode(parent_path)
    # `parent__fs_node` must exists, checked by `checkDirTraversal` before.
    if parent__fs_node.write_permission > actor or parent__fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to remove children inside this folder: `",
                parent_path, "`."
            )
        )

    # # Check target's existance.
    var target__fs_node := self.getRawFSNode(path)
    if target__fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                path, "`."
            )
        )

    # # Remove the FS node.
    # Must success, because checked folder-ness and existance before.
    parent__fs_node.removeChild(target__fs_node)
    return DMFSResult.createOK()

## Copy a file/folder to another place.
## The meta data will be all copied,
##  except the timestamp of creation and last modified will be updated.[br]
## Refuse to copy to target if a same-name FS node already exists.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Source Parent Directory: [code]x[/code] only.[br]
## * Dest Parent Directory: [code]w+x[/code].[br]
## * Target: [code]r[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param source_path] does not exists.
##   Or, their parent folder does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If given [param source_path] or [param dest_path]
##    contains a name that is a file but used as a folder.[br]
## * [enum DMFSResult.Error.already_exists]:
##   If [param dest_path] already exists.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for parent of [param source_path] or [param dest_path],
##    or no enough permission for reading [param source_path].[br]
func copy(
    source_path: String, dest_path: String,
    actor: DMPermission.Level
) -> DMFSResult:
    # # Check traverse.
    var source_parent_path := DMFS.getParentPath(source_path)
    var dest_parent_path   := DMFS.getParentPath(dest_path)
    var traverse_result__source := self.checkDirTraversal(source_parent_path, actor)
    var traverse_result__dest   := self.checkDirTraversal(dest_parent_path, actor)
    if traverse_result__source.is_error:
        return traverse_result__source
    if traverse_result__dest.is_error:
        return traverse_result__dest

    # # Check source parent's `x`.
    # Do not need to do check here, since already done by traversal check.

    # # Check target existance and `r`.
    var source__fs_node := self.getRawFSNode(source_path)
    if source__fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                source_path, "`."
            )
        )
    if source__fs_node.read_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to read: `",
                source_parent_path, "`."
            )
        )

    # # Check dest parent's `w+x`.
    var dest_parent__fs_node := self.getRawFSNode(dest_parent_path)
    if dest_parent__fs_node.write_permission > actor or dest_parent__fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to create new child at this folder: `",
                source_parent_path, "`."
            )
        )

    # # Check if same-name FS node already exists.
    var name_to_create := dest_path.trim_prefix(dest_parent_path)
    if dest_parent__fs_node.hasChildWithName(name_to_create):
        return DMFSResult.createError(
            DMFSResult.Error.already_exists,
            str(
                "File/Folder asked to create already exists, cannot overwrite: `",
                dest_path, "`."
            )
        )

    # # Allows copying.
    var copied_fs_node := source__fs_node.duplicate(true) # deep duplicate
    copied_fs_node.name = name_to_create
    copied_fs_node.time_of_creation = DMPC.getZonedTimestamp()
    copied_fs_node.updateTimeOfLastModify()
    dest_parent__fs_node.addChild(copied_fs_node)

    return DMFSResult.createOK()

## Move a file/folder to another place,
##  or change its name.
## The meta data will be all reserved.[br]
## Refuse to copy to target if a same-name FS node already exists.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Source Parent Directory: [code]w+x[/code].[br]
## * Dest Parent Directory: [code]w+x[/code].[br]
## * Target: none.[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.not_found]:
##   If given [param source_path] does not exists.
## * [enum DMFSResult.Error.not_folder]:
##   If given [param source_path] or [param dest_path]
##    contains a name that is a file but used as a folder.[br]
## * [enum DMFSResult.Error.already_exists]:
##   If [param dest_path] already exists.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for parent of [param source_path] or [param dest_path],
##    or no enough permission for reading [param source_path].[br]
func move(
    source_path: String, dest_path: String,
    actor: DMPermission.Level
) -> DMFSResult:
        # # Check traverse.
    var source_parent_path := DMFS.getParentPath(source_path)
    var dest_parent_path   := DMFS.getParentPath(dest_path)
    var traverse_result__source := self.checkDirTraversal(source_parent_path, actor)
    var traverse_result__dest   := self.checkDirTraversal(dest_parent_path, actor)
    if traverse_result__source.is_error:
        return traverse_result__source
    if traverse_result__dest.is_error:
        return traverse_result__dest

    # # Check source parent's `w+x`.
    var source_parent__fs_node := self.getRawFSNode(source_parent_path)
    if source_parent__fs_node.write_permission > actor or source_parent__fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to modify child at this folder: `",
                source_parent_path, "`."
            )
        )

    # # Check target existance.
    var source__fs_node := self.getRawFSNode(source_path)
    if source__fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "Provided path does not exists: `",
                source_path, "`."
            )
        )

    # # Check dest parent's `w+x`.
    var dest_parent__fs_node := self.getRawFSNode(dest_parent_path)
    if dest_parent__fs_node.write_permission > actor or dest_parent__fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to create new child at this folder: `",
                source_parent_path, "`."
            )
        )

    # # Check if same-name FS node already exists.
    var name_to_create := dest_path.trim_prefix(dest_parent_path)
    if dest_parent__fs_node.hasChildWithName(name_to_create):
        return DMFSResult.createError(
            DMFSResult.Error.already_exists,
            str(
                "File/Folder asked to create already exists, cannot overwrite: `",
                dest_path, "`."
            )
        )

    # # Copy first, then delete old.
    # Copy.
    var copied_fs_node := source__fs_node.duplicate(true) # deep duplicate
    copied_fs_node.name = name_to_create
    dest_parent__fs_node.addChild(copied_fs_node)
    # Delete old.
    source_parent__fs_node.removeChild(source__fs_node)

    return DMFSResult.createOK()

## Read the content of a file.[br]
## Returns deep copy of [DMFSContent] if success.[br][br]
##
## [b]Notice[/b]: If a file is going to be [b]executed[/b],
##  instead of using this method, use [method resolveExecutable],
##  which also checked [code]x[/code] permission.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: none.[br]
## * Target: [code]r[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.path_invalid]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path],
##    until the parent folder of target, resolves to a file.[br]
## * [enum DMFSResult.Error.not_file]:
##   If the destination resolves to a folder.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path],
##    or cannot read the target.[br]
func readFile(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Check existance, `x` permission and folder-ness.
    var traverse_result := self.checkDirTraversal(path.get_base_dir(), actor)
    if traverse_result.is_error:
        return traverse_result

    # # Check if destination file exists.
    var target_file_node := self.getRawFSNode(path)
    if target_file_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "File does not exists: `",
                path, "`."
            )
        )

    # # Check if reading a folder.
    if target_file_node.is_folder:
        return DMFSResult.createError(
            DMFSResult.Error.not_file,
            str(
                "Provided path resolves to a folder, not a file: `",
                path, "`."
            )
        )

    # # Check if enough permission to read that file.
    if target_file_node.read_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to read this file: `",
                path, "`."
            )
        )

    # Return deep duplication of file's content.
    return DMFSResult.createOK(target_file_node.content.duplicate(true))

## Write the content of a file.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: none.[br]
## * Target: [code]w[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.path_invalid]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path],
##    until the parent folder of target, resolves to a file.[br]
## * [enum DMFSResult.Error.not_file]:
##   If the destination resolves to a folder.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path],
##    or cannot read the target.[br]
func writeFile(
    path: String, content: DMFSContent,
    actor: DMPermission.Level
) -> DMFSResult:
    # # Check existance, `x` permission and folder-ness.
    var traverse_result := self.checkDirTraversal(path.get_base_dir(), actor)
    if traverse_result.is_error:
        return traverse_result

    # # Check if destination file exists.
    var target_file_node := self.getRawFSNode(path)
    if target_file_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "File does not exists: `",
                path, "`."
            )
        )

    # # Check if reading a folder.
    if target_file_node.is_folder:
        return DMFSResult.createError(
            DMFSResult.Error.not_file,
            str(
                "Provided path resolves to a folder, not a file: `",
                path, "`."
            )
        )

    # # Check if enough permission to write that file.
    if target_file_node.write_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to write this file: `",
                path, "`."
            )
        )

    # # Success.
    target_file_node.content = content
    return DMFSResult.createOK()

## Get the FS node for a file that aimed to be executed.[br]
## Returns deep copy of [DMFSContent] if success.[br][br]
##
## [b]Notice[/b]: If a file is going to be [b]only read-ed[/b],
##  instead of using this method, use [method readFile],
##  which does not check [code]x[/code] permission.[br][br]
##
## Checks permission for:[br]
## * Intermediate Directory: [code]x[/code].[br]
## * Parent Directory: none.[br]
## * Target: [code]r+x[/code].[br][br]
##
## Returns error for these conditions:[br]
## * [enum DMFSResult.Error.path_invalid]:
##   If given [param path] does not exists.[br]
## * [enum DMFSResult.Error.not_folder]:
##   If one of the name in the given [param path],
##    until the parent folder of target, resolves to a file.[br]
## * [enum DMFSResult.Error.not_file]:
##   If the destination resolves to a folder.[br]
## * [enum DMFSResult.Error.permission_denied]:
##   If no enough permission for accessing one of the folder in the given [param path],
##    or cannot read the target.[br]
func resolveExecutable(
    path: String, actor: DMPermission.Level
) -> DMFSResult:
    # # Check existance, `x` permission and folder-ness.
    var traverse_result := self.checkDirTraversal(path.get_base_dir(), actor)
    if traverse_result.is_error:
        return traverse_result

    # # Check if the file to be executed, exists.
    var fs_node := self.getRawFSNode(path)
    if fs_node == null:
        return DMFSResult.createError(
            DMFSResult.Error.not_found,
            str(
                "File does not exists: `",
                path, "`."
            )
        )

    # # Check if reading a folder.
    if fs_node.is_folder:
        return DMFSResult.createError(
            DMFSResult.Error.not_file,
            str(
                "Provided path resolves to a folder, not a file: `",
                path, "`."
            )
        )

    # # Check if enough permission to execute that file.
    if fs_node.read_permission > actor or fs_node.exec_permission > actor:
        return DMFSResult.createError(
            DMFSResult.Error.permission_denied,
            str(
                "No enough permission to execute this file: `",
                path, "`."
            )
        )

    # Return deep duplication of file's content.
    return DMFSResult.createOK(fs_node.content.duplicate(true))

## Returns the parent's path of given [param path], with trailing slash.
## Returns [code]/[/code] for root directory.
static func getParentPath(path: String) -> String:
    if path == "/":
        return "/"
    elif path.ends_with("/"):
        return path.rstrip("/").get_base_dir() + "/"
    else:
        return path.get_base_dir() + "/"
