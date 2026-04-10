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
* Pre hint tiles (`P`):
   plays direction in low volume.
* Normal hint tiles (`N`):
   plays direction in normal volume.

A tile could be set as whether it should check the ball exit side
 (`NavHintArea.is_checking`). Notated as `C`.

In annotated screenshots:
* Orange small dot is `P`.
* Green dot is `N`.
* Blue square is a checking area.

![Description of Generation](./.pic/nav_area_generation_desc.png)

Each nav area stores the two directions as discussed above:
* `nav_direction`: used for accepted/rejected checks and wrong-way correction.
* `turn_direction`: Could be empty (`Vector2i.ZERO`)
   if current block is intended to check the ball without hinting a turn.
