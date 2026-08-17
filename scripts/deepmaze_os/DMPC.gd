class_name DMPC
extends Resource
## Represents the PC that player operates in this game
##
## This class is the operating interface between player
##  and the virtual computer defined in this game.


## File System of DeepMaze OS.
@export var fs: DMFS = DMFS.new()


static func getZonedTimestamp() -> int:
    return Time.get_unix_time_from_system() \
           + Time.get_time_zone_from_system()["bias"] * 60 # `bias` is in minute
