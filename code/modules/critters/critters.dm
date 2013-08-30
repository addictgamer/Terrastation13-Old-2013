/obj/critter/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	icon = 'otherthing.dmi'
	icon_state = "otherthing"
	health = 80
	max_health = 80
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 1
	atkcritter = 1
	atkmech = 1
	atksame = 1
	firevuln = 1
	brutevuln = 1
	melee_damage_lower = 25
	melee_damage_upper = 50
	angertext = "runs"
	attacktext = "chomps"


/obj/critter/roach
	name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	health = 5
	max_health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 0
	attacktext = "bites"

	Die()
		..()
		del(src)


/obj/critter/killertomato
	name = "killer tomato"
	desc = "Oh shit, you're really fucked now."
	icon_state = "killertomato"
	health = 15
	max_health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 2


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if (..())
			var/success = 0
			if (istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if (istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if (success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0



/obj/critter/spore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	icon_state = "spore"
	density = 1
	health = 1
	max_health = 1
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 2


	Die()
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		src.alive = 0
		var/turf/T = get_turf(src.loc)
		if (T)
			T.hotspot_expose(700,125)
			explosion(T, -1, -1, 2, 3)
		del src


	ex_act(severity)
		src.Die()


/obj/critter/blob
	name = "blob"
	desc = "Some blob thing."
	icon_state = "blob"
	pass_flags = PASSBLOB
	health = 20
	max_health = 20
	aggressive = 1
	defensive = 0
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 0.5
	melee_damage_lower = 2
	melee_damage_upper = 8
	angertext = "charges"
	attacktext = "hits"

	Die()
		..()
		del(src)



/obj/critter/walkingmushroom
	name = "Walking Mushroom"
	desc = "A...huge...mushroom...with legs!?"
	icon_state = "walkingmushroom"
	health = 15
	max_health = 15
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 1


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if (..())
			var/success = 0
			if (istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if (istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if (success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0



/obj/critter/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	health = 5
	max_health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = 0
	atkcarbon = 1
	atksilicon = 1
	attacktext = "bites"

// We can maybe make these controllable via some console or something
/obj/critter/manhack
	name = "manhack"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator"
	pass_flags = PASSTABLE
	health = 15
	max_health = 15
	aggressive = 1
	opensdoors = 1
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	atkmech = 1
	firevuln = 0 // immune to fire
	brutevuln = 1
	//ventcrawl = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	//chasestate = "viscerator_attack"
	deathtext = "is smashed into pieces!"

	Die()
		..()
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <b>[src]</b> [src.deathtext]", 1)
		del(src)

/obj/critter/melterling
	name = "Melterling"
	desc = "Some volatile mimicry of a much more dangerous Melter. There are probably more of these lurking around somewhere."
	icon = 'mob.dmi'
	icon_state = "humansouth"
	density = 1
	health = 1
	max_health = 1
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 2


	Die()
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		src.alive = 0
		var/turf/T = get_turf(src.loc)
		if (T)
			T.hotspot_expose(700,125)
			explosion(T, -1, -1, 2, 3)
		del src


	ex_act(severity)
		src.Die()


