extends Control


@onready var terminal: DMTerminal = $Terminal


@export var pc: DMPC = DMPC.new()


func _ready() -> void: self.__onReady__()


func __onReady__():
    self.terminal.user_name = "testuser"
    self.terminal.user_permission = DMPermission.Level.staff
    self.terminal.pc__ref = self.pc
    self.terminal.initComponentsRef()
