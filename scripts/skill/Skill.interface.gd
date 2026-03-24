@abstract
class_name Skill
extends Equipment
## Abstract class for all skill, which is equipped in two slot


## See if the skill could still be used in one level.[br][br]
##
## Check remain count and if the skill could only be used one time in the same level.
var could_be_used_in_this_level: bool:
    get:
        return not (self.only_one_time_per_level and self.had_used_in_this_level) \
           and self.remain_count > 0
