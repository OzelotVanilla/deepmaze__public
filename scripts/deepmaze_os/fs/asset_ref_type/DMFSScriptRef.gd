@tool
class_name DMFSScriptRef
extends DMFSAssetRef
## [DMFSContent] referring to a executable file.


## The gdscript that is referring to.
## The script should be extending [DMTerminalCommand].
@export var ref_script: Script
