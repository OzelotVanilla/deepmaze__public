Description
====

This folder stores maze related files:
* `Maze`: Maze itself, contains map data.
* `NavHintArea`: An area containing logic of navigation/hint-of-direction/check.

Navigation Hint Generation
====

`Maze` owns the low-level data and node generation for `NavHintArea`.

* `createNavHintAreasCache(start, target)` synchronously computes the cached
   nav hint data from the A* path.
* `regenerateNavHintAreaToContainer()` synchronously clears old `NavHintArea`
   nodes and adds new nodes to `NavHintAreaContainer`.
* Newly generated `NavHintArea` nodes start with `monitoring = false`.
   `MazeGame` enables monitoring in a later physics tick by calling
   `enableNavHintAreaMonitoring()`.

`Maze` does not decide when the path should be regenerated. Runtime regeneration
is requested and driven by `MazeGame`'s physics process state machine.

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
