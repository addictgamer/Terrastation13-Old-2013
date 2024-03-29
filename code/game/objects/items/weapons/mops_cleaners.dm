/*
CONTAINS:
SPACE CLEANER
MOP

*/
/obj/item/weapon/cleaner/New()
	var/datum/reagents/R = new/datum/reagents(250)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 250)

/obj/item/weapon/cleaner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/cleaner/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return

	var/obj/decal/D = new/obj/decal(get_turf(src))
	D.create_reagents(5)
	src.reagents.trans_to(D, 5)

	var/list/rgbcolor = list(0,0,0)
	var/finalcolor
	for(var/datum/reagent/re in D.reagents.reagent_list) // natural color mixing bullshit/algorithm
		if (!finalcolor)
			rgbcolor = GetColors(re.color)
			finalcolor = re.color
		else
			var/newcolor[3]
			var/prergbcolor[3]
			prergbcolor = rgbcolor
			newcolor = GetColors(re.color)

			rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
			rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
			rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

			finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
			// This isn't a perfect color mixing system, the more reagents that are inside,
			// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
			// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
			// If you add brighter colors to it it'll eventually get lighter, though.

	D.name = "chemicals"
	D.icon = 'chempuff.dmi'

	D.icon += finalcolor

	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	spawn(0)
		for(var/i=0, i<3, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
			sleep(3)
		del(D)

	if (isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 10)

	return

/obj/item/weapon/cleaner/examine()
	set src in usr
	for(var/datum/reagent/R in reagents.reagent_list)
		usr << text("\icon[] [] units of [] left!", src, round(R.volume), R.name)
	//usr << text("\icon[] [] units of cleaner left!", src, src.reagents.total_volume)
	..()
	return

/obj/item/weapon/chemsprayer/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 10)

/obj/item/weapon/chemsprayer/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/chemsprayer/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return

	playsound(src.loc, 'spray2.ogg', 50, 1, -6)

	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if (src.reagents.total_volume < 1) break
		var/obj/decal/D = new/obj/decal(get_turf(src))
		D.name = "chemicals"
		D.icon = 'chempuff.dmi'
		D.create_reagents(5)
		src.reagents.trans_to(D, 5)

		var/rgbcolor[3]
		var/finalcolor
		for(var/datum/reagent/re in D.reagents.reagent_list)
			if (!finalcolor)
				rgbcolor = GetColors(re.color)
				finalcolor = re.color
			else
				var/newcolor[3]
				var/prergbcolor[3]
				prergbcolor = rgbcolor
				newcolor = GetColors(re.color)

				rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
				rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
				rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

				finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])

		D.icon += finalcolor

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/decal/D = Sprays[i]
			if (!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			del(D)
	sleep(1)

	if (isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 10)

	return

/obj/item/weapon/chemsprayer/examine()
	set src in usr
	usr << text("\icon[] [] units of cleaner left!", src, src.reagents.total_volume)
	..()
	return

// MOP

/obj/item/weapon/mop/New()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if (src.reagents.total_volume < 1 || mopcount >= 5)
		user << "\blue Your mop is dry!"
		return

	if (istype(A, /turf/simulated))
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[] begins to clean []</B>", user, A), 1)
		sleep(40)
		user << "\blue You have finished mopping!"
		src.reagents.reaction(A,1,10)
		A.clean_blood()
		for(var/obj/rune/R in A)
			del(R)
		for(var/obj/decal/cleanable/crayon/R in A)
			del(R)
		mopcount++
	else if (istype(A, /obj/decal/cleanable/blood) || istype(A, /obj/decal/cleanable/poop) || istype(A, /obj/overlay) || istype(A, /obj/decal/cleanable/xenoblood) || istype(A, /obj/rune) || istype(A,/obj/decal/cleanable/crayon) || istype(A,/obj/decal/cleanable/vomit) )
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[user] begins to clean [A]</B>"), 1)
		sleep(20)
		if (A)
			user << "\blue You have finished mopping!"
			var/turf/U = A.loc
			src.reagents.reaction(U)
		if (A) del(A)
		mopcount++

	if (mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
		spawn(5)
			src.reagents.clear_reagents()
			mopcount = 0

	return



/*
 *  Hope it's okay to stick this shit here: it basically just turns a hexadecimal color into rgb
 */

proc/GetColors(hex)
    hex = uppertext(hex)
    var
        hi1 = text2ascii(hex, 2)
        lo1 = text2ascii(hex, 3)
        hi2 = text2ascii(hex, 4)
        lo2 = text2ascii(hex, 5)
        hi3 = text2ascii(hex, 6)
        lo3 = text2ascii(hex, 7)
    return list(((hi1>= 65 ? hi1-55 : hi1-48)<<4) | (lo1 >= 65 ? lo1-55 : lo1-48),
        ((hi2 >= 65 ? hi2-55 : hi2-48)<<4) | (lo2 >= 65 ? lo2-55 : lo2-48),
        ((hi3 >= 65 ? hi3-55 : hi3-48)<<4) | (lo3 >= 65 ? lo3-55 : lo3-48))









