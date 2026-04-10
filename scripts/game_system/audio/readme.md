Folder `audio`
====

Manage the audio in this game, contains the logic of sound generating.

Dir Structure
----

* `gameplay`: Script controlling gameplay sounds.

Definition
----

* Gameplay Sound: All the sound produced from gameplay.
* UI Sound: The sound of UI component.
* Functional game sound: The sound in gameplay, that helps player
   to perform an action, such as find exit or relic.
* Entertaining game sound: The sound in gameplay, that generated
   from entities' action and not that helpful for gameplay,
   such as ball rolling sound.

Definition of Bus Layout
----

* `Master`: Master gain of this game, set by game settings.
* `Gameplay`: Master gain of `GameplaySound`, set by game settings.
* `UI`: Master gain of `UISound`, set by game settings.
* `GameplayGain`: All *gameplay sound* should be connected to this,
   set by code (e.g., when changing between normal and listening mode).
* `UIGain`: All *UI sound* should be connected to this
   set by code (e.g., when changing between normal and listening mode).

Sound Specification
----

* Distance to Exit: A 20 sec long loop, should be less repetitive to avoid player feeling bored.
  When far, large reverb param. When close, dry.
* Distance to Relic/Quarter: A beep sound that catches player's attention,
   since pickable items are not frequently appearing.
  When far, large reverb param. When close, dry.

Sound Mode Specification
----

### Normal Mode

Focus on the experience of game various sound effect.
Assumes that **visual info** is the main info player retrieve from game.

* Allow entertaining sound to be heard at **full level**.
* Make functional sound **nearly hard to be listened**.

### Listening Mode

Focus on how to guide player to useful resources/exit.
Assumes that **auditory info** is the main info player retrieve from game.

* Make functional sound **clear to be heard**.
* Let entertaining sound vague as if player is **listening it in the water**.
