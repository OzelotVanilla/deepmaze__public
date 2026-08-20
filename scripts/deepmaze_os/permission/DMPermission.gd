class_name DMPermission
extends RefCounted


enum Level
{
    staff,
    admin,
    root
}


static func canAccess(user_level: Level, required_level: Level) -> bool:
    return user_level >= required_level
