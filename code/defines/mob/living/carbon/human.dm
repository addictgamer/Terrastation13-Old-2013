/mob/living/carbon/human
	name = "human"
	real_name = "human"
	voice_name = "human"
	icon = 'mob.dmi'
	icon_state = "m-none"


	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0
	var/h_style = "Short Hair"
	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0
	var/f_style = "Shaved"
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0
	var/s_tone = 0.0
	var/age = 30.0
	var/b_type = "A+"

	//var/gaylord = 0 //False by default. Don't set it to true, that's just gay.

	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/under/w_uniform = null
//	var/obj/item/device/radio/w_radio = null
	var/obj/item/clothing/shoes/shoes = null
	var/obj/item/weapon/belt = null
	var/obj/item/clothing/gloves/gloves = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/head/head = null
	var/obj/item/clothing/ears/ears = null
	var/obj/item/weapon/card/id/wear_id = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/obj/item/weapon/s_store = null
	var/obj/item/weapon/h_store = null

	var/space_pirate = 0

	var/icon/stand_icon = null
	var/icon/lying_icon = null

	var/last_b_state = 1.0

	var/image/face_standing = null
	var/image/face_lying = null

	var/hair_icon_state = "hair_a"
	var/face_icon_state = "bald"

	var/list/body_standing = list()
	var/list/body_lying = list()

	var/mutantrace = null

	var/list/organs = list(  )

	//Life()
	//	if (istype(l_hand, /obj/item/weapon)) //If holding a weapon in the left hand.
	//		if (l_hand.needs_held_update) //Check if it needs a held update.
	//			l_hand.held_update() //Update.
	//	if (istype(r_hand, /obj/item/weapon)) //If holding a weapon in the right hand.
	//		if (r_hand.needs_held_update) //Check if it needs a held update.
	//			r_hand.held_update() //Update.

	var/nutrition_decreased_since_last_poop_material = 0

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	nodamage = 1