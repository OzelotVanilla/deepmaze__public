@tool
class_name GameSave
extends Resource
## The save file of the game
##
## This file defines the entries to be saved as property.[br][br]
##
## Notice: Game will not save until player dies.


@export var game_state: GameSaveOfGameState

@export var currency: GameSaveOfCurrency

@export var collected_item: GameSaveOfCollectedItem

@export var stat: GameSaveOfStat


func _init() -> void:
    self.game_state = GameSaveOfGameState.new()
    self.currency = GameSaveOfCurrency.new()
    self.collected_item = GameSaveOfCollectedItem.new()
    self.stat = GameSaveOfStat.new()
