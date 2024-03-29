/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "Stacking machine console"
	icon = 'mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/machine = null

/obj/machinery/mineral/stacking_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, SOUTHEAST))  //THIS "SOUTHEAST" CALL RIGHT HERE MIGHT BE WHY THE FUCKING THING DOESN'T WORK. SOMEBODY DICK WITH THIS.
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/stacking_unit_console/attack_hand(user as mob)

	var/dat

	dat += text("<b>Stacking unit console</b><br><br>")

	if (machine.ore_iron)
		dat += text("Iron: [machine.ore_iron] <A href='?src=\ref[src];release=iron'>Release</A><br>")
	if (machine.ore_steel)
		dat += text("Steel: [machine.ore_steel] <A href='?src=\ref[src];release=steel'>Release</A><br>")
	if (machine.ore_glass)
		dat += text("Glass: [machine.ore_glass] <A href='?src=\ref[src];release=glass'>Release</A><br>")
	if (machine.ore_rglass)
		dat += text("Reinforced Glass: [machine.ore_rglass] <A href='?src=\ref[src];release=rglass'>Release</A><br>")
	if (machine.ore_plasma)
		dat += text("Plasma: [machine.ore_plasma] <A href='?src=\ref[src];release=plasma'>Release</A><br>")
	if (machine.ore_gold)
		dat += text("Gold: [machine.ore_gold] <A href='?src=\ref[src];release=gold'>Release</A><br>")
	if (machine.ore_silver)
		dat += text("Silver: [machine.ore_silver] <A href='?src=\ref[src];release=silver'>Release</A><br>")
	if (machine.ore_uranium)
		dat += text("Uranium: [machine.ore_uranium] <A href='?src=\ref[src];release=uranium'>Release</A><br>")
	if (machine.ore_diamond)
		dat += text("Diamond: [machine.ore_diamond] <A href='?src=\ref[src];release=diamond'>Release</A><br>")
	if (machine.ore_clown)
		dat += text("Bananium: [machine.ore_clown] <A href='?src=\ref[src];release=clown'>Release</A><br><br>")
	if (machine.ore_adamantine)
		dat += text ("Adamantine: [machine.ore_adamantine] <A href='?src=\ref[src];release=adamantine'>Release</A><br><br>")

	dat += text("Stacking: [machine.stack_amt]<br><br>")

	user << browse("[dat]", "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if (..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if (href_list["release"])
		switch(href_list["release"])
			if ("plasma")
				if (machine.ore_plasma > 0)
					var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
					G.amount = machine.ore_plasma
					G.loc = machine.output.loc
					machine.ore_plasma = 0
			if ("uranium")
				if (machine.ore_uranium > 0)
					var/obj/item/stack/sheet/uranium/G = new /obj/item/stack/sheet/uranium
					G.amount = machine.ore_uranium
					G.loc = machine.output.loc
					machine.ore_uranium = 0
			if ("glass")
				if (machine.ore_glass > 0)
					var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass
					G.amount = machine.ore_glass
					G.loc = machine.output.loc
					machine.ore_glass = 0
			if ("rglass")
				if (machine.ore_rglass > 0)
					var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass
					G.amount = machine.ore_rglass
					G.loc = machine.output.loc
					machine.ore_rglass = 0
			if ("gold")
				if (machine.ore_gold > 0)
					var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
					G.amount = machine.ore_gold
					G.loc = machine.output.loc
					machine.ore_gold = 0
			if ("silver")
				if (machine.ore_silver > 0)
					var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
					G.amount = machine.ore_silver
					G.loc = machine.output.loc
					machine.ore_silver = 0
			if ("diamond")
				if (machine.ore_diamond > 0)
					var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
					G.amount = machine.ore_diamond
					G.loc = machine.output.loc
					machine.ore_diamond = 0
			if ("iron")
				if (machine.ore_iron > 0)
					var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
					G.amount = machine.ore_iron
					G.loc = machine.output.loc
					machine.ore_iron = 0
			if ("steel")
				if (machine.ore_steel > 0)
					var/obj/item/stack/sheet/r_metal/G = new /obj/item/stack/sheet/r_metal
					G.amount = machine.ore_steel
					G.loc = machine.output.loc
					machine.ore_steel = 0
			if ("clown")
				if (machine.ore_clown > 0)
					var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
					G.amount = machine.ore_clown
					G.loc = machine.output.loc
					machine.ore_clown = 0
			if ("adamantine")
				if (machine.ore_adamantine > 0)
					var/obj/item/stack/sheet/adamantine/G = new /obj/item/stack/sheet/adamantine
					G.amount = machine.ore_adamantine
					G.loc = machine.output.loc
					machine.ore_adamantine = 0
	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "Stacking machine"
	icon = 'mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_plasma = 0;
	var/ore_iron = 0;
	var/ore_uranium = 0;
	var/ore_clown = 0;
	var/ore_glass = 0;
	var/ore_rglass = 0;
	var/ore_steel = 0;
	var/ore_adamantine = 0;
	var/stack_amt = 5; //ammount to stack before releassing //NOTE: this variable SHOULD be set to 50. I set it to 5 because the console is broken. --LZ

/obj/machinery/mineral/stacking_machine/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if (src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if (src.output) break
		processing_objects.Add(src)
		return
	return

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/obj/item/O
		while (locate(/obj/item, input.loc))
			O = locate(/obj/item, input.loc)
			if (istype(O,/obj/item/stack/sheet/metal))
				ore_iron+= O:amount;
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/diamond))
				ore_diamond+= O:amount;
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/plasma))
				ore_plasma+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/gold))
				ore_gold+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/silver))
				ore_silver+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/clown))
				ore_clown+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/uranium))
				ore_uranium+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/glass))
				ore_glass+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/rglass))
				ore_rglass+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/r_metal))
				ore_steel+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/stack/sheet/adamantine))
				ore_adamantine+= O:amount
				del(O)
				//continue
			if (istype(O,/obj/item/weapon/ore/slag))
				del(O)
				//continue
			O.loc = src.output.loc
	if (ore_gold >= stack_amt)
		var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
		G.amount = stack_amt
		G.loc = output.loc
		ore_gold -= stack_amt
		//return
	if (ore_silver >= stack_amt)
		var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
		G.amount = stack_amt
		G.loc = output.loc
		ore_silver -= stack_amt
		//return
	if (ore_diamond >= stack_amt)
		var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
		G.amount = stack_amt
		G.loc = output.loc
		ore_diamond -= stack_amt
		//return
	if (ore_plasma >= stack_amt)
		var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
		G.amount = stack_amt
		G.loc = output.loc
		ore_plasma -= stack_amt
		//return
	if (ore_iron >= stack_amt)
		var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_iron -= stack_amt
		//return
	if (ore_clown >= stack_amt)
		var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
		G.amount = stack_amt
		G.loc = output.loc
		ore_clown -= stack_amt
		//return
	if (ore_uranium >= stack_amt)
		var/obj/item/stack/sheet/uranium/G = new /obj/item/stack/sheet/uranium
		G.amount = stack_amt
		G.loc = output.loc
		ore_uranium -= stack_amt
		//return
	if (ore_glass >= stack_amt)
		var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass
		G.amount = stack_amt
		G.loc = output.loc
		ore_glass -= stack_amt
		//return
	if (ore_rglass >= stack_amt)
		var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass
		G.amount = stack_amt
		G.loc = output.loc
		ore_rglass -= stack_amt
		//return
	if (ore_steel >= stack_amt)
		var/obj/item/stack/sheet/r_metal/G = new /obj/item/stack/sheet/r_metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_steel -= stack_amt
		//return
	if (ore_adamantine >= stack_amt)
		var/obj/item/stack/sheet/adamantine/G = new /obj/item/stack/sheet/adamantine
		G.amount = stack_amt
		G.loc = output.loc
		ore_adamantine -= stack_amt
		//return
	return
