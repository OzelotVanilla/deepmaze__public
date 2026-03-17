@abstract
class_name Ability
extends Equipment
## Base class for all ability, which is effective as long as it is equipped.


## Constant for all available ability.
static var available_ability: Dictionary[MazeGame.BallType, Script] = {
    MazeGame.BallType.wall_clip: WallClipAbility
}:
    set(_toss):
        pass

## [code]{ball_type: {icon_path: "", animation_path: ""}}[/code].
static var _stored__res_path_info: Variant = null # Dictionary[MazeGame.BallType, Dictionary]

## Constant for ability's icon path: [code]{ball_type: icon_path}[/code].
static var ability_icon_path__dict: Dictionary[MazeGame.BallType, StringName]:
    get():
        if Ability._stored__res_path_info == null:
            Ability.updateResourcePathInfo()
        var result: Dictionary[MazeGame.BallType, StringName] = {}
        for k in Ability._stored__res_path_info.keys():
            result[k] = Ability._stored__res_path_info[k]["icon_path"]

        return result

## Constant for ability's animation path: [code]{ball_type: animation_path}[/code].
static var ability_animation_path__dict: Dictionary[MazeGame.BallType, StringName]:
    get():
        if Ability._stored__res_path_info == null:
            Ability.updateResourcePathInfo()
        var result: Dictionary[MazeGame.BallType, StringName] = {}
        for k in Ability._stored__res_path_info.keys():
            result[k] = Ability._stored__res_path_info[k]["animation_path"]

        return result


## Enable the ability, so the player will benefit from that.
@abstract func enable() -> Error;

## Disable the ability, restore the status.
@abstract func disable() -> Error;

## Path for ability's animation.
var animation_path: StringName


## Update const of ability's resource path.
static func updateResourcePathInfo():
    if Ability._stored__res_path_info != null:
        Ability._stored__res_path_info.clear()
    else:
        Ability._stored__res_path_info = {}

    for ball_type in Ability.available_ability.keys():
        var ability: Ability = Ability.available_ability[ball_type].new()
        Ability._stored__res_path_info[ball_type] = {
            "icon_path": ability.icon_path,
            "animation_path": ability.animation_path
        }
