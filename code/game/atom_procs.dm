

/atom/proc/MouseDrop_T()
	return

/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/attack_animal(mob/user as mob)
	return

//for aliens, it works the same as monkeys except for alien-> mob interactions which will be defined in the
//appropiate mob files
/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return


// for metroids
/atom/proc/attack_metroid(mob/user as mob)
	return



/atom/proc/hand_h(mob/user as mob)
	return

/atom/proc/hand_p(mob/user as mob)
	return

/atom/proc/hand_a(mob/user as mob)
	return

/atom/proc/hand_al(mob/user as mob)
	src.hand_p(user)
	return


/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/detective_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("\red [src] has been scanned by [user] with the [W]")
	else
		if (!( istype(W, /obj/item/weapon/grab) ) && !(istype(W, /obj/item/weapon/plastique)) &&!(istype(W, /obj/item/weapon/cleaner)) &&!(istype(W, /obj/item/weapon/chemsprayer)) && !(istype(W, /obj/item/weapon/plantbgone)) )
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O << text("\red <B>[] has been hit by [] with []</B>", src, user, W)
	return


/atom/proc/add_fingerprint(mob/living/M as mob)
	if (isnull(M)) return
	if (isnull(M.key)) return
	if (!( src.flags ) & 256)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna))
			return 0
		if (H.gloves)
			if (src.fingerprintslast != H.key)
				src.fingerprintshidden += text("(Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 0
		if (!( src.fingerprints ))
			src.fingerprints = text("[]", md5(H.dna.uni_identity))
			if (src.fingerprintslast != H.key)
				src.fingerprintshidden += text("Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 1
		else
			var/list/L = params2list(src.fingerprints)
			L -= md5(H.dna.uni_identity)
			while(L.len >= 3)
				L -= L[1]
			L += md5(H.dna.uni_identity)
			src.fingerprints = list2params(L)
			if (src.fingerprintslast != H.key)
				src.fingerprintshidden += text("Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
	else
		if (src.fingerprintslast != M.key)
			src.fingerprintshidden += text("Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
	return


/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	if (!( istype(M, /mob/living/carbon/human) ))
		return 0
	if (!( src.flags ) & 256)
		return
	if (!( src.blood_DNA ))
		if (istype(src, /obj/item)&&!istype(src, /obj/item/weapon/melee/energy))//Only regular items. Energy melee weapon are not affected.
			var/obj/item/source2 = src
			source2.icon_old = src.icon
			var/icon/I = new /icon(src.icon, src.icon_state)
			I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
			I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
			I.Blend(new /icon(src.icon, src.icon_state),ICON_UNDERLAY)
			src.icon = I
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else if (istype(src, /turf/simulated))
			var/turf/simulated/source2 = src
			var/list/objsonturf = range(0,src)
			var/i
			for(i=1, i<=objsonturf.len, i++)
				if (istype(objsonturf[i],/obj/decal/cleanable/blood))
					return
			var/obj/decal/cleanable/blood/this = new /obj/decal/cleanable/blood(source2)
			this.blood_DNA = M.dna.unique_enzymes
			this.blood_type = M.b_type
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this
		else if (istype(src, /mob/living/carbon/human))
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else
			return
	else
		var/list/L = params2list(src.blood_DNA)
		L -= M.dna.unique_enzymes
		while(L.len >= 3)
			L -= L[1]
		L += M.dna.unique_enzymes
		src.blood_DNA = list2params(L)
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M as mob)
	if ( istype(src, /turf/simulated) )
		var/obj/decal/cleanable/vomit/this = new /obj/decal/cleanable/vomit(src)
		for(var/datum/disease/D in M.viruses)
			var/datum/disease/newDisease = new D.type
			this.viruses += newDisease
			newDisease.holder = this

// Only adds blood on the floor -- Skie
/atom/proc/add_blood_floor(mob/living/carbon/M as mob)
	if ( istype(M, /mob/living/carbon/monkey) )
		if ( istype(src, /turf/simulated) )
			var/turf/simulated/source1 = src
			var/obj/decal/cleanable/blood/this = new /obj/decal/cleanable/blood(source1)
			this.blood_DNA = M.dna.unique_enzymes
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this

	else if ( istype(M, /mob/living/carbon/alien ))
		if ( istype(src, /turf/simulated) )
			var/turf/simulated/source2 = src
			var/obj/decal/cleanable/xenoblood/this = new /obj/decal/cleanable/xenoblood(source2)
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this

	else if ( istype(M, /mob/living/silicon/robot ))
		if ( istype(src, /turf/simulated) )
			var/turf/simulated/source2 = src
			var/obj/decal/cleanable/oil/this = new /obj/decal/cleanable/oil(source2)
			for(var/datum/disease/D in M.viruses)
				var/datum/disease/newDisease = new D.type
				this.viruses += newDisease
				newDisease.holder = this



/atom/proc/clean_blood()

	if (!( src.flags ) & 256)
		return
	if ( src.blood_DNA )
		if (istype (src, /mob/living/carbon))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			//var/icon/I = new /icon(source2.icon_old, source2.icon_state) //doesnt have icon_old
			//source2.icon = I
		if (istype (src, /obj/item))
			var/obj/item/source2 = src
			source2.blood_DNA = null
//			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = source2.icon_old
			source2.update_icon()
		if (istype(src, /turf/simulated))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = I
	return

/atom/MouseDrop(atom/over_object as mob|obj|turf|area)
	spawn( 0 )
		if (istype(over_object, /atom))
			over_object.MouseDrop_T(src, usr)
		return
	..()
	return

/atom/Click(location,control,params)
	//world << "atom.Click() on [src] by [usr] : src.type is [src.type]"

	if (usr.client.buildmode)
		build_click(usr, usr.client.buildmode, location, control, params, src)
		return

	return DblClick()

/atom/DblClick() //TODO: DEFERRED: REWRITE
//	world << "checking if this shit gets called at all"
	if (world.time <= usr:lastDblClick+1)
//		world << "BLOCKED atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		return
	else
//		world << "atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		usr:lastDblClick = world.time
	if (istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		if (ai.control_disabled)
			return
	if (istype (usr, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/bot = usr
		if (bot.lockcharge) return
	..()


	if (usr.in_throw_mode)
		return usr:throw_item(src)

	var/obj/item/W = usr.equipped()


	if (istype(usr, /mob/living/silicon/robot))
		if (!isnull(usr:module_active))
			W = usr:module_active
		else
			W = null

	if (W == src && usr.stat == 0)
		spawn (0)
			W.attack_self(usr)
		return

	if (((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai)) || usr.stat != 0)
		return

	if ((!( src in usr.contents ) && (((!( isturf(src) ) && (!( isturf(src.loc) ) && (src.loc && !( isturf(src.loc.loc) )))) || !( isturf(usr.loc) )) && (src.loc != usr.loc && (!( istype(src, /obj/screen) ) && !( usr.contents.Find(src.loc) ))))))
		if (istype(usr, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/ai = usr
			if (ai.control_disabled || ai.malfhacking)
				return
		else
			return

	var/t5 = in_range(src, usr) || src.loc == usr

	if (istype(usr, /mob/living/silicon/ai))
		t5 = 1

	if ((istype(usr, /mob/living/silicon/robot)) && W == null)
		t5 = 1

	if (istype(src, /datum/organ) && src in usr.contents)
		return

//	world << "according to dblclick(), t5 is [t5]"
	if (((t5 || (W && (W.flags & 16))) && !( istype(src, /obj/screen) )))
		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return
		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))
			var/direct = get_dir(usr, src)
			var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( usr.loc )
			var/ok = 0
			if ( (direct - 1) & direct)
				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if (5.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)

					if (6.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)

					if (9.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)

					if (10.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

					else
				if (Step_1 && Step_2)
					var/check_1 = 0
					var/check_2 = 0
					if (step_to(D, Step_1))
						check_1 = 1
						for(var/obj/border_obstacle in Step_1)
							if (border_obstacle.flags & ON_BORDER)
								if (!border_obstacle.CheckExit(D, src))
									check_1 = 0
						for(var/obj/border_obstacle in get_turf(src))
							if ((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if (!border_obstacle.CanPass(D, D.loc, 1, 0))
									check_1 = 0

					D.loc = usr.loc
					if (step_to(D, Step_2))
						check_2 = 1

						for(var/obj/border_obstacle in Step_2)
							if (border_obstacle.flags & ON_BORDER)
								if (!border_obstacle.CheckExit(D, src))
									check_2 = 0
						for(var/obj/border_obstacle in get_turf(src))
							if ((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if (!border_obstacle.CanPass(D, D.loc, 1, 0))
									check_2 = 0
					if (check_1 || check_2)
						ok = 1
			else
				if (loc == usr.loc)
					ok = 1
				else
					ok = 1

					//Now, check objects to block exit that are on the border
					for(var/obj/border_obstacle in usr.loc)
						if (border_obstacle.flags & ON_BORDER)
							if (!border_obstacle.CheckExit(D, src))
								ok = 0

					//Next, check objects to block entry that are on the border
					for(var/obj/border_obstacle in get_turf(src))
						if ((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
							if (!border_obstacle.CanPass(D, D.loc, 1, 0))
								ok = 0

			del(D)
			if (!( ok ))

				return 0

		if (!( usr.restrained() ))
			if (W)
				if (t5)
					src.attackby(W, usr)
				if (W)
					W.afterattack(src, usr, (t5 ? 1 : 0))
			else
				if (istype(usr, /mob/living/carbon/human))
					if (usr:a_intent == "help")
						if (istype(src, /mob/living/carbon))
							var/mob/living/carbon/C = src
							if (usr:mutations & HEAL)

								if (C.stat != 2)
									var/t_him = "it"
									if (src.gender == MALE)
										t_him = "his"
									else if (src.gender == FEMALE)
										t_him = "her"
									var/u_him = "it"
									if (usr.gender == MALE)
										t_him = "him"
									else if (usr.gender == FEMALE)
										t_him = "her"

									if (src != usr)
										usr.visible_message( \
										"\blue <i>[usr] places [u_him] palms on [src], healing [t_him]!</i>", \
										"\blue You place your palms on [src] and heal [t_him].", \
										)
									else
										usr.visible_message( \
										"\blue <i>[usr] places [u_him] palms on [u_him]self and heals.</i>", \
										"\blue You place your palms on yourself and heal.", \
										)

									C.oxyloss = max(0, C.oxyloss-25)
									C.toxloss = max(0, C.toxloss-25)

									if (istype(C, /mob/living/carbon/human))
										var/mob/living/carbon/human/H = C
										var/datum/organ/external/affecting = H.organs["chest"]

										var/t = usr:zone_sel:selecting

										if (t in list("eyes", "mouth"))
											t = "head"

										if (H.organs[t])
											affecting = H.organs[t]

										if (affecting.heal_damage(25, 25))
											H.UpdateDamageIcon()
										else
											H.UpdateDamage()
										C.updatehealth()
									else
										C.heal_organ_damage(25, 25)

									C.cloneloss = max(0, C.cloneloss-25)

									C.stunned = max(0, C.stunned-5)
									C.paralysis = max(0, C.paralysis-5)
									C.stuttering = max(0, C.stuttering-5)
									C.drowsyness = max(0, C.drowsyness-5)
									C.weakened = max(0, C.weakened-5)

									if (C.client)
										C.updatehealth()
										C:handle_regular_hud_updates()
									usr:nutrition -= rand(1,10)
									usr:handle_regular_hud_updates()
									usr.next_move = world.time + 6
								else
									usr << "\red [src] is dead and can't be healed."
								return

					src.attack_hand(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.attack_alien(usr, usr.hand)
						else
							if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
								src.attack_ai(usr, usr.hand)

							else
								if (istype(usr, /mob/living/carbon/metroid))
									src.attack_metroid(usr)
								else
									if (istype(usr, /mob/living/simple_animal))
										src.attack_animal(usr)
		else
			if (istype(usr, /mob/living/carbon/human))
				src.hand_h(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/monkey))
					src.hand_p(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.hand_al(usr, usr.hand)
					else
						if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
							src.hand_a(usr, usr.hand)

	else
		if (istype(src, /obj/screen))
			usr.prev_move = usr.next_move
			usr:lastDblClick = world.time + 2
			if (usr.next_move < world.time)
				usr.next_move = world.time + 2
			else
				return
			if (!( usr.restrained() ))
				if ((W && !( istype(src, /obj/screen) )))
					src.attackby(W, usr)

					if (W)
						W.afterattack(src, usr)
				else
					if (istype(usr, /mob/living/carbon/human))
						src.attack_hand(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/monkey))
							src.attack_paw(usr, usr.hand)
						else
							if (istype(usr, /mob/living/carbon/alien/humanoid))
								src.attack_alien(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/human))
					src.hand_h(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.hand_p(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.hand_al(usr, usr.hand)
		else
			if (usr:mutations & LASER && usr:a_intent == "hurt" && world.time >= usr.next_move)
				var/turf/oloc
				var/turf/T = get_turf(usr)
				var/turf/U = get_turf(src)
				if (istype(src, /turf)) oloc = src
				else
					oloc = loc

				if (istype(usr, /mob/living/carbon/human))
					usr:nutrition -= rand(1,5)
					usr:handle_regular_hud_updates()

				var/obj/item/projectile/beam/A = new /obj/item/projectile/beam( usr.loc )
				A.icon = 'genetics.dmi'
				A.icon_state = "eyelasers"
				playsound(usr.loc, 'taser2.ogg', 75, 1)

				A.firer = usr
				A.def_zone = usr:get_organ_target()
				A.original = oloc
				A.current = T
				A.yo = U.y - T.y
				A.xo = U.x - T.x
				spawn( 1 )
					A.process()

				usr.next_move = world.time + 6
	return


/atom/proc/get_global_map_pos()
	if (!islist(global_map) || isemptylist(global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if (cur_y)
			break
//	world << "X = [cur_x]; Y = [cur_y]"
	if (cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

/atom/proc/checkpass(passflag)
	return pass_flags&passflag


//Could not find object proc defines and this could almost be an atom level one.
/obj/proc/process()
	processing_objects.Remove(src)
	return 0