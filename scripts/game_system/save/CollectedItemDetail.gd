class_name CollectedItemDetail
extends Resource


## Timestamp of the time when it is obtained.
@export var timestamp_of_obtained: int

## The ID of the item, depends on its type
##  (e.g., relic or exploration log).
@export var item_id: int

## Whether this item is newly obtained, and not seen yet.
@export var whether_new: bool = false
