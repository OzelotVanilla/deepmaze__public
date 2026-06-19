White Cane Solution of Navigation
========


Brief
--------

Create a circle that changes radius according to the speed of ball.
If the ball is fast, make the circle bigger.
This navigation solution gets inspiration from the white cane.


Idea
--------

`Ball` contains two `WhiteCaneCircle` (`Area2D`),
 searching for `WhiteCaneDetectArea` (`Area2D`).
The radius of the `WhiteCaneCircle` changes according to ball's speed.
When the white cane touches the detect area,
 sound of nav/turn should be played.


Flow of Generation and Utilisation
--------

1. When maze was done, put `WhiteCaneDetectArea`s at each turning point.
2. Only allows the first `WhiteCaneDetectArea` in the route to exit,
    to be monitored by `WhiteCaneCircle`.
3. When ball exits the `WhiteCaneDetectArea` with `Area2D.monitoring == true`,
    regenerates path and `WhiteCaneDetectArea`.


Implementation
--------

Since in the current implementation,
 `NavHintArea` is constantly regenerated (if the coord of ball changes)
 to keep the correctness of the navigation,
 a part of the flow could be reused in this white cane solution.
