Description
====

The main page and the logic of the game.

Ball Type
----

There is not only one type of ball that could be controlled.
Each ball have an instinct skill.
* Wall clip: black small ball.

Algorithm of Navigation Generation and Hint SFX Playing
----

### What need to be nav-ed/checked/played ?

Definitions:

* `nav_direction` (`n`): the correct path movement direction.
* `turn_direction` (`t`): the direction/key to hint
   when player is approaching a corner and need to turn
* `sfx_direction` (`s=`): the direction sfx to play when a ball enters from an accepted side.

Logic of navigation and checking:

* When a new level was shown, a nav path should be generated,
   and player should know the first direction they should go.
* Player is notif-ed by a sfx of direction for turning
   when there is a corner on the path to nav target.
  The direction for turning, considering the speed and inertia of ball,
   is played before the ball approaches the corner,
   so as the player have enough time to think and turn.
* There should be a regeneration mechanism
   while player is not proceeding through the nav path.
  Therefore, at the start/corner, while player goes to wrong direction,
   nav path should be regenerated.

For the sound to play / not to play:

* Usually the turn direction in player is proceeding well.
* At start point, nav direction.
* When player goes to the wrong path and trying to move back,
   while path is regenerated, nav direction should be played.

All in all, if moving in right way to exit (assuming ball has speed),
 the turn direction is played.
If no, need to nav player back to path.

### Design of `NavHintArea`

There is two types of nav hint type (`NavHintArea.HintType`):
* Pre hint tiles (`P s=?`):
   plays direction in low volume.
* Normal hint tiles (`N s=?`):
   plays direction in normal volume.

A tile could be marked as checking (`NavHintArea.is_checking`). Notated as `C`.
This affects visual/debug meaning and hint metadata, but runtime path
regeneration is not triggered directly by checking-area exit signals.

In annotated screenshots:
* Orange small dot is `P`.
* Green dot is `N`.
* Blue square is a checking area.

![Description of Generation](./.pic/nav_area_generation_desc.png)

Each nav area stores the three directions as discussed above:
* `nav_direction` (`n`): used for accepted/rejected checks and wrong-way correction.
* `turn_direction` (`t`): Could be empty (`Vector2i.ZERO`)
   if current block does not need to show a turn hint.
* `sfx_direction` (`s=?`): Could be the same as `nav_direction` (`s=n`) or `turn_direction` (`s=t`).
   Could be empty (`Vector2i.ZERO`) if current block is intended to check
   the ball without playing an accepted-enter sfx.

### Generation of Navigation Path (using `NavHintArea`s)

#### General Image

For example, there is a L corner that players comes from upper side, need to turn to the right.
* `P s=t` plays a pre hint that tells player need to press "right" key to turn later.
* `N s=t` plays a hint that tells player that need to press "right" now in order to turn
   (the ball has inertia so player should turn in advance).
* Similarly, `P s=n` and `N s=n` plays navigation direction.
* If `C`, the tile is a checking marker in the generated hint path.
  Path regeneration itself is handled by the physics watcher described below.

#### Generation Process

For the starting point, set it as `N s=n` and `C`.

For a corner, defines the L-point as tile `X`,
 and `X +/- n` as the next/prev `n` tile in the path points
 (need to consider if start point is near corner):

* If `X - 2` is the starting point:
  * Set `X - 2` as `N s=n` and `C`.
  * Set `X - 1` as `P s=t`.
  * Set `X` as `C`.
* If `X - 1` is the starting point:
  * Set `X - 1` as `N s=n` and `C`.
  * Set `X` as `N s=n` and `C`.
* Else, normally:
  * Set `X - 2` as `P s=t`.
  * Set `X - 1` as `N s=t`.
  * Set `X` as `C`.

Except the start tile, do not generate anything on non-corner-neighbour tiles.

During the processing of generation,
 there might be situation that a new tile is replacing the last generated tile.
In this situation, all the data except `is_checking`,
 should be replaced by latter tile.

At runtime:

* `NavHintArea` enter/exit signals are used for hint SFX only.
* `MazeGame._physics_process` watches the ball's maze coord.
  When the coord changes, it calls `requestRegenerateNavPath()`.
* `requestRegenerateNavPath()` only records the latest ball coord
   and marks the nav path regeneration state machine as pending.
  It is a request, not an immediate completed rebuild.
* The state machine rebuilds from *latest ball coord* to *nav target*.
  New areas are added with `monitoring = false`,
   then monitoring and signal connections are enabled on the following physics tick.
* If the ball keeps moving while a rebuild is pending,
   only the latest coord is kept for the next rebuild.
