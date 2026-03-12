class_name GameOverMask
extends PanelContainer


@onready var use_quarter_button__ref: DottedBgButton = $ContinuePanel/VBox/UseQuarterButton

@onready var log_text_box__ref: ArrowIndicatorTextBox = $LogPanel/VBox/ArrowedLogBox

@onready var quarter_cost_label__ref: Label = \
    $ContinuePanel/VBox/UseQuarterButton/HBox/QuarterCostLabel

@onready var quarter_count_label__ref: Label = \
    $QuarterPanel/VBox/ClaimButton/HBox/QuarterCountLabel

@onready var relic_count_label__ref: Label = \
    $RelicPanel/VBox/ClaimButton/HBox/RelicCountLabel

@onready var continue_panel__ref: PanelContainer = $ContinuePanel

@onready var log_panel__ref: PanelContainer = $LogPanel

@onready var quarter_panel__ref: PanelContainer = $QuarterPanel

@onready var relic_panel__ref: PanelContainer = $RelicPanel


## Will be init-ed in [method MazeGame.__onReady__].
var game__ref: MazeGame


## Will only be called if have enough quarter and player chooses revive.
## After quarter being used, tell the game to revive from death.
func useQuarterToRevive():
    # Quarter should be used, and game should be saved.
    save_manager.save.currency.quarter_count -= self.game__ref.revive_quarter_cost
    save_manager.saveToLocalFile()

    self.game__ref.reviveGame()

func proceedToWhetherContinue():
    # If not enough quarter, do not show "revive" option.
    if save_manager.save.currency.quarter_count < self.game__ref.revive_quarter_cost:
        self.use_quarter_button__ref.hide()
    else:
        self.quarter_cost_label__ref.text = str(
            "X ", self.game__ref.revive_quarter_cost
        )
        self.use_quarter_button__ref.show()

    # Panel Visibility.
    self.continue_panel__ref.show()
    self.log_panel__ref.hide()
    self.quarter_panel__ref.hide()
    self.relic_panel__ref.hide()

## Show log panel if there is a log obtained,
##  or proceed to quarter panel.
func proceedToLogShowing():
    var available_exploration_logs: Array[int] = \
        save_manager.getArrayOfNotObtainedExplorationLogID()

    if available_exploration_logs.size() <= 0 \
       or not self.game__ref.shouldGenerateExplorationLog():
        self.proceedToQuarterShowing.call_deferred()
        return

    var new_log__id := self.game__ref.generateNewExplorationLog()

    self.log_text_box__ref.text = tr(ExplorationLogTextEntry.getPOIDForText(new_log__id))

    # Panel visibility.
    self.continue_panel__ref.hide()
    self.log_panel__ref.show()
    self.quarter_panel__ref.hide()
    self.relic_panel__ref.hide()

func proceedToQuarterShowing():
    # Need to check if this panel should be showed.
    if save_manager.save.game_state.buffered_diff__currency.quarter_count <= 0:
        self.proceedToRelicShowing.call_deferred()
        return

    # Show the number.
    self.quarter_count_label__ref.text = str(
        save_manager.save.game_state.buffered_diff__currency.quarter_count
    )

    # Panel visibility.
    self.continue_panel__ref.hide()
    self.log_panel__ref.hide()
    self.quarter_panel__ref.show()
    self.relic_panel__ref.hide()

func proceedToRelicShowing():
    # Need to check if this panel should be showed.
    if save_manager.save.game_state.buffered_diff__collected_item.relic.size() <= 0:
        self.goToMenuPage.call_deferred()
        return

    # Show the number.
    self.relic_count_label__ref.text = str(
        save_manager.save.game_state.buffered_diff__collected_item.relic.size()
    )

    # Panel visibility.
    self.continue_panel__ref.hide()
    self.log_panel__ref.hide()
    self.quarter_panel__ref.hide()
    self.relic_panel__ref.show()

func goToMenuPage():
    # Save what player had got.
    self.game__ref.saveFinishedGame()

    # Do not forget this, otherwise your game will freeze:
    self.game__ref.get_tree().paused = false
    self.game__ref.root_scene__ref.popScene()

func _on_GameOverMask_visibility_changed() -> void:
    # Only process when it becomes visible.
    if not self.is_visible_in_tree():
        return

    # Show the continue panel, hide others.
    if self.is_node_ready():
        self.proceedToWhetherContinue()
