class_name MazeTileType
extends RefCounted
## Shared enum for maze tile data representation across embedded sub-mazes and generators.


enum Type
{
    path = 0,
    wall = 1,
    start = 2,
    exit = 3,
    quarter = 4,
    relic = 5,
    gate_key = 6,
    fake_exit = 7,
    unclaimed = 99 # Used for non-rectangular sub-maze bounds padding
}
