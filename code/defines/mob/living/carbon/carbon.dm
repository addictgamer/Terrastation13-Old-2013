/mob/living/carbon/
	can_be_gibbered = 1
	gender = MALE
	var/list/stomach_contents = list()

	var/brain_op_stage = 0.0
	var/eye_op_stage = 0.0
	var/appendix_op_stage = 0.0

	var/datum/disease2/disease/virus2 = null
	var/list/datum/disease2/disease/resistances2 = list()