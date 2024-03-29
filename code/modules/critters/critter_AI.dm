
/obj/critter

	New()
		spawn(0) process()//I really dont like this much but it seems to work well
		..()


	process()
		set background = 1
		if (!src.alive)	return
		switch(task)
			if ("thinking")
				src.attack = 0
				src.target = null
				sleep(15)
				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (src.wanderer && !src.target) src.task = "wandering"
			if ("chasing")
				if (src.frustration >= max_frustration)
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						ChaseAttack()
						src.task = "attacking"
						src.anchored = 1
						src.target_lastloc = M.loc
					else
						var/turf/olddist = get_dist(src, src.target)
						walk_to(src, src.target,1,4)
						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++
						else
							src.frustration = 0
						sleep(5)
				else src.task = "thinking"
			if ("attacking")
				// see if he got away
				if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc)))
					src.anchored = 0
					src.task = "chasing"
				else
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						if (!src.attacking)	RunAttack()
						if (!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if (M!=null)
								if (M.health < 0)
									src.task = "thinking"
									src.target = null
									src.anchored = 0
									src.last_found = world.time
									src.frustration = 0
									src.attacking = 0
					else
						src.anchored = 0
						src.attacking = 0
						src.task = "chasing"
			if ("wandering")
				patrol_step()
				sleep(10)
		spawn(8)
			process()
		return


	patrol_step()
		var/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/shuttle/floor) || istype(moveto, /turf/unsimulated/floor)) step_towards(src, moveto)
		if (src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"


	Bump(M as mob|obj)//TODO: Add access levels here
		spawn(0)
			if ((istype(M, /obj/machinery/door)))
				if (src.opensdoors)
					M:open()
					src.frustration = 0
			else src.frustration ++
			if ((istype(M, /mob/living/)) && (!src.anchored))
				src.loc = M:loc
				src.frustration = 0
			return
		return


	Bumped(M as mob|obj)
		spawn(0)
			var/turf/T = get_turf(src)
			M:loc = T


	seek_target()
		src.anchored = 0
		var/T = null
		for(var/mob/living/C in view(src.seekrange,src))//TODO: mess with this
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if (istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (istype(C, /mob/living/carbon/) && src.atkcarbon)	src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon)	src.attack = 1
			if (src.attack)
				T = C
				break

		if (!src.attack)
			for(var/obj/critter/C in view(src.seekrange,src))
				if (istype(C, /obj/critter) && !src.atkcritter) continue
				if (istype(C, /obj/mecha) && !src.atkmech) continue
				if (C.health <= 0) continue
				if (istype(C, /obj/critter) && src.atkcritter)
					if ((istype(C, src.type) && !src.atksame) || (C == src))	continue
					src.attack = 1
				if (istype(C, /obj/mecha) && src.atkmech)	src.attack = 1
				if (src.attack)
					T = C
					break

		if (src.attack)
			src.target = T
			src.oldtarget_name = T:name
			src.task = "chasing"
		return


	ChaseAttack()
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> [src.angertext] at [src.target]!", 1)
		return


	RunAttack()
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> [src.attacktext] [src.target]!", 1)
		if (ismob(src.target))


			var/damage = rand(melee_damage_lower, melee_damage_upper)

			if (istype(target, /mob/living/carbon/human))
				var/dam_zone = pick("head", "chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (dam_zone == "chest")
					if ((((target:wear_suit && target:wear_suit.body_parts_covered & UPPER_TORSO) || (target:w_uniform && target:w_uniform.body_parts_covered & LOWER_TORSO)) && prob(10)))
						if (prob(20))
							target:show_message("\blue You have been protected from a hit to the chest.")
							return
				if (istype(target:organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = target:organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						target:UpdateDamageIcon()
					else
						target:UpdateDamage()
				target:updatehealth()

			else
				target:bruteloss += damage

			if (attack_sound)
				playsound(loc, attack_sound, 50, 1, -1)

			AfterAttack(target)


		if (isobj(src.target))
			if (istype(target, /obj/mecha))
				src.target:take_damage(rand(melee_damage_lower,melee_damage_upper))
			else
				src.target:TakeDamage(rand(melee_damage_lower,melee_damage_upper))
		spawn(attack_speed)
			src.attacking = 0
		return



/*TODO: Figure out how to handle special things like this dont really want to give it to every critter
/obj/critter/proc/CritterTeleport(var/telerange, var/dospark, var/dosmoke)
	if (!src.alive) return
	var/list/randomturfs = new/list()
	for(var/turf/T in orange(src, telerange))
		if (istype(T, /turf/space) || T.density) continue
		randomturfs.Add(T)
	src.loc = pick(randomturfs)
	if (dospark)
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	if (dosmoke)
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(10, 0, src.loc)
		smoke.start()
	src.task = "thinking"
*/