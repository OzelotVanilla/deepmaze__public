class_name SoundNavSystem
extends Node


## Solution of sound nav system.
enum Solution
{
    ## Use a tile that saves the turn-direction.
    ## When stepping on that tile, sound will be triggered.
    nav_hint_area,

    ## Place an detecting area on the corner, making the ball surrounded with 2 circles.
    ## The circles will change its radius according to the moving speed of ball.
    ## When the circle touches the detecting area, sound will be triggered.
    white_cane
}
