`DeepMaze` public repository
====

This repo is a stripped-down public repository for the game `DeepMaze`, 
 storing the selected code that can be made public.

`DeepMaze` is a maze exploring game developed by Godot Engine,
 while player experiences the special levels, collect story pieces,
 and go deeper.


Why this repository exists
----

This repo discloses selected part of design/implementation
 of the game system & logic.

Until permitted, this repository is not granted to be forked.


What is included
----

* Selected gameplay systems
* Input or player control related code
* Ability/Skill system, equipment abstractions
* UI components
* Save/Config related structures
* Selected scenes and scripts


What is omitted
----

* Proprietary assets
* Full production data that could be used to run/build the game
* Unreleased content
* Parts restricted by team policy

This is intentional, so the repository should be read as a technical mirror
 rather than a complete game source release.


Recommended files to read first
----

* Input handling and ball behaviour:
  Start with [`InputManager`](./scenes/root/InputManager.gd),
   [`BallInputController`](./entity/ball/BallInputController.gd),
   and [`Ball`](./entity/ball/Ball.gd).  
  Together, these files show how raw input, movement intent,
   and final in-game ball behaviour are handled in separate layers.
* Ability/Skill system design:
  Start with [`Equipment`](./scripts/equipment/Equipment.gd),
   [`Ability`](./scripts/ability/Ability.interface.gd),
   and [`Skill`](./scripts/skill/Skill.interface.gd).
  These files show how reusable gameplay effects are organised
   around a shared abstraction, while keeping abilities and skills
   as separate gameplay concepts.
* UI components and state synchronisation:
  See the [`ui_component/`](./ui_component/) directory for reusable UI parts.  
  As examples, [`QuarterWidget`](./ui_component/quarter_widget/QuarterWidget.gd)
   reacts to changes in saved game state, while
   [`ArrowIndicatorTextBox`](./ui_component/container/arrow_indicator_text_box/ArrowIndicatorTextBox.gd)
   shows how a UI component can update its display from externally assigned data.
* Save/Config system design:
  Start with [`ConfigManager`](./scripts/game_system/config/ConfigManager.gd),
   [`SaveManager`](./scripts/game_system/save/SaveManager.gd),
   [`GameConfig`](./scripts/game_system/config/GameConfig.gd),
   and [`GameSave`](./scripts/game_system/save/GameSave.gd).  
  These files show how user settings and gameplay progress are stored separately
   using Godot `Resource` files, and how game-state-related save data is structured
   for resuming in-progress runs.


Design highlights
----

* Separation between input interpretation and in-game player behavior
* Shared abstraction for equipment, abilities, and skills
* UI components designed to react to game state or save data
* Separate handling of configuration data and gameplay progress data


Repository structure
----

* `entity/ball/`: Contains ball's scene (including ball's collision shape), 
   and logic about ball controlling.
* `scenes/`: Contains scenes such as settings or collection viewing (e.g., `relic` here) page.
* `scripts/`: Game system or shared logic.
* `ui_component/`: Reusable UI component.


Notes on build / execution
----

This repository is not intended to provide a full build-able distribution.
The code stored here is for review rather than for execution.


Related Links
----

Project summary and video: [Google Drive shared folder, in Japanese](https://drive.google.com/drive/folders/1bx9ZRhvsmXK9_PBuXycOMVN2BjhRneSK?usp=sharing)