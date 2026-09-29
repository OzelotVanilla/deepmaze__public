class_name MazeTile
extends RefCounted
## ID of tiles/entities when generating [Maze] (used across embedded sub-mazes and generators).


enum
{
    path = 0,
    wall = 1,
    start = 2,
    exit = 3,
    quarter = 4,
    relic = 5,
    ## For special level [constant MazeGame.SpecialLevel.la_barbe_bleue].
    gate_key = 6,
    ## For special level [constant MazeGame.SpecialLevel.veronique].
    fake_exit = 7,
    ## For non-rectangular sub-maze bounds padding
    unclaimed = 99 
}
