Description
====

This folder stores maze related files:
* `Maze`: Maze itself, contains map data.
* `NavHintArea`: An area containing logic of navigation/hint-of-direction/check.

Debug
====

Display `NavHintArea` in Game
----

First, turn on the debug option `NavHintArea.debug__show_visuals` in `NavHintArea`.

* The coloured arrow stands for **turn direction**:
  * Yellow and small: pre-hint.
  * Green and big: hint.
  * No arrow should be showed if `turn_direction` is empty.
* The coloured small ball around corner is **nav direction**.
* The blue frame stands for checking area.
