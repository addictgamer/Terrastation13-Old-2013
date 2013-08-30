
/proc/FindOccupationCandidates(list/unassigned, job, level)
	var/list/candidates = list()

	for (var/mob/new_player/player in unassigned)
		if (player.preferences.occupation[level] == job)
			if (jobban_isbanned(player, job))
				continue
//			if (player.jobs_restricted_by_gamemode && (job in player.jobs_restricted_by_gamemode))
//				continue
			candidates += player

	return candidates

/proc/ResetOccupations()
	for(var/mob/new_player/player in world)
		if (player)
			if (player.mind)
				player.mind.assigned_role = null
				player.mind.special_role = null
	return

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effects besides of modifying "assigned_role".
 **/
/proc/DivideOccupations()
	var/list/unassigned = list()
	var/list/occupation_eligible = occupations.Copy()

	for (var/mob/new_player/player in world)
		if (player.client && player.ready && !player.mind.assigned_role)
			unassigned += player
			for (var/level = 1 to 3)
				if (jobban_isbanned(player, player.preferences.occupation[level]))
					player.preferences.occupation[level] = "Assistant"

			// If someone picked AI before it was disabled, or has a saved profile with it
			// on a game that now lacks it, this will make sure they don't become the AI,
			// by changing that choice to Captain.
			if (!config.allow_ai)
				for (var/level = 1 to 3)
					if (player.preferences.occupation[level] == "AI")
						player.preferences.occupation[level] = "Captain"

	if (unassigned.len == 0)
		return 0

	//Check for a Captain first
	for (var/level = 1 to 3)
		var/list/candidates = FindOccupationCandidates(unassigned, "Captain", level)
		if (candidates.len)
			var/mob/new_player/candidate = pick(candidates)
			unassigned -= candidate
			candidate.mind.assigned_role = "Captain"
			break

	//Then check for an AI
	for (var/level = 1 to 3)//Malf is a bit special as it replaces a normal job
		var/list/candidates = FindOccupationCandidates(unassigned, "AI", level)
		if (ticker.mode.name == "AI malfunction")
			for(var/mob/new_player/player in candidates)
				if (!player.preferences.be_special & BE_MALF)
					candidates -= player
		if (candidates.len)
			var/mob/new_player/candidate = pick(candidates)
			unassigned -= candidate
			candidate.mind.assigned_role = "AI"
			break
	//Malf NEEDS an AI so force one
	if ((ticker.mode.name == "AI malfunction")&&(occupation_eligible["AI"] > 0))
		unassigned = shuffle(unassigned)
		for(var/mob/new_player/player in unassigned)
			if (jobban_isbanned(player, "AI"))
				continue
			else
				player.mind.assigned_role = "AI"
				unassigned -= player
				break
	//Now we can go though the rest of the jobs and players who set prefs
	for (var/level = 1 to 3)
		//Assistants are checked first
		for (var/occupation in assistant_occupations)
			if (unassigned.len == 0)
				break
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			while(candidates.len && assistant_occupations[occupation])
				assistant_occupations[occupation]--
				var/mob/new_player/candidate = pick_n_take(candidates)
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
		//Now everyone else
		for (var/occupation in occupation_eligible)
			if (unassigned.len == 0)
				break
			if (occupation_eligible[occupation] == 0)
				continue
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			while (candidates.len && occupation_eligible[occupation])
				occupation_eligible[occupation]--
				var/mob/new_player/candidate = pick_n_take(candidates)
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
	//Last try to fill in any leftover jobs with leftover players
	if (unassigned.len)
		var/list/vacancies = list()
		for (var/occ in occupation_eligible)
			for (var/i = 1 to occupation_eligible[occ])
				vacancies += occ

		for(var/mob/new_player/candidate in unassigned)
			if (!unassigned.len || !vacancies.len)	break
			var/occupation = pick(vacancies)
			if (!jobban_isbanned(candidate, occupation))
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
				vacancies -= occupation

		for(var/mob/new_player/player in unassigned)
			if (unassigned.len == 0)
				break
			var/list/occupationsPossible = list()
			for(var/occ in assistant_occupations)
				if (assistant_occupations[occ])
					occupationsPossible += occ
				player.mind.assigned_role = pick(occupationsPossible)
				assistant_occupations[player.mind.assigned_role]--
//			player.mind.assigned_role = pick(assistant_occupations)

	return 1

/mob/living/carbon/human/proc/Equip_Rank(rank, joined_late)

	switch(rank)
		if ("Chaplain")
			var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible/booze(src)
			src.equip_if_possible(B, slot_l_hand)
			src.equip_if_possible(new /obj/item/device/pda/chaplain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			//if (prob(15))
			//	src.see_invisible = 15 -- Doesn't work as see_invisible is reset every world cycle. -- Skie
			//The two procs below allow the Chaplain to choose their religion. All it really does is change their bible.
			spawn(0)
				var/religion_name = "Christianity"
				var/new_religion = input(src, "You are the Chaplain. Would you like to change your religion? Default is Christianity, in SPACE.", "Name change", religion_name)

				if ((length(new_religion) == 0) || (new_religion == "Christianity"))
					new_religion = religion_name

				if (new_religion)
					if (length(new_religion) >= 26)
						new_religion = copytext(new_religion, 1, 26)
					new_religion = dd_replacetext(new_religion, ">", "'")
					switch(lowertext(new_religion))
						if ("christianity")
							B.name = pick("The Holy Bible","The Dead Sea Scrolls")
						if ("satanism")
							B.name = "The Unholy Bible"
						if ("cthulu")
							B.name = "The Necronomicon"
						if ("islam")
							B.name = "Quran"
						if ("scientology")
							B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
						if ("chaos")
							B.name = "The Book of Lorgar"
						if ("imperium")
							B.name = "Uplifting Primer"
						if ("toolboxia")
							B.name = "Toolbox Manifesto"
						if ("homosexuality")
							B.name = "Guys Gone Wild"
						if ("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks")
							B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
							brainloss = 100 // starts off retarded as fuck
						if ("science")
							B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
						else
							B.name = "The Holy Book of [new_religion]"

			spawn(1)
				var/deity_name = "Space Jesus"
				var/new_deity = input(src, "Would you like to change your deity? Default is Space Jesus.", "Name change", deity_name)

				if ( (length(new_deity) == 0) || (new_deity == "Space Jesus") )
					new_deity = deity_name

				if (new_deity)
					if (length(new_deity) >= 26)
						new_deity = copytext(new_deity, 1, 26)
						new_deity = dd_replacetext(new_deity, ">", "'")
				B.deity_name = new_deity

				var/accepted = 0
				var/outoftime = 0
				spawn(200) // 20 seconds to choose
					outoftime = 1
				while(!accepted)
					if (!B) break // prevents possible runtime errors

					switch(input(src,"Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Daederic Scroll", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Necronomicon"))
						if ("Koran")
							B.icon_state = "koran"
							B.item_state = "koran"
						if ("Scrapbook")
							B.icon_state = "scrapbook"
							B.item_state = "scrapbook"
						if ("Daederic Scroll")
							B.icon_state = "daederic_scroll"
							B.item_state = "daederic"
						if ("Creeper")
							B.icon_state = "creeper"
							B.item_state = "syringe_kit"
						if ("White Bible")
							B.icon_state = "white"
							B.item_state = "syringe_kit"
						if ("Holy Light")
							B.icon_state = "holylight"
							B.item_state = "syringe_kit"
						if ("Athiest")
							B.icon_state = "athiest"
							B.item_state = "syringe_kit"
						if ("Tome")
							B.icon_state = "tome"
							B.item_state = "syringe_kit"
						if ("The King in Yellow")
							B.icon_state = "kingyellow"
							B.item_state = "kingyellow"
						if ("Ithaqua")
							B.icon_state = "ithaqua"
							B.item_state = "ithaqua"
						if ("Scientology")
							B.icon_state = "scientology"
							B.item_state = "scientology"
						if ("the bible melts")
							B.icon_state = "melted"
							B.item_state = "melted"
						if ("Necronomicon")
							B.icon_state = "necronomicon"
							B.item_state = "necronomicon"
						else
							// if christian bible, revert to default
							B.icon_state = "bible"
							B.item_state = "bible"

					src:update_clothing() // so that it updates the bible's item_state in his hand

					switch(input(src,"Look at your bible - is this what you want?") in list("Yes","No"))
						if ("Yes")
							accepted = 1
						if ("No")
							if (outoftime)
								src << "Welp, out of time, buddy. You're stuck. Next time choose faster."
								accepted = 1

				if (ticker)
					ticker.Bible_icon_state = B.icon_state
					ticker.Bible_item_state = B.item_state
					ticker.Bible_name = B.name


		if ("Geneticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/genetics(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_s_store)

		if ("Chemist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/chemist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/chemist(src), slot_wear_suit)

		if ("Janitor")
			src.equip_if_possible(new /obj/item/clothing/under/rank/janitor(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/janitor(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)

		if ("Clown")
			if (src.gender == FEMALE)
				src.equip_if_possible(new /obj/item/clothing/under/sexyclown(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/mask/gas/sexyclown(src), slot_wear_mask)
			else //MALE or NEUTER

				src.equip_if_possible(new /obj/item/clothing/under/rank/clown(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(src), slot_wear_mask)
			//All genders require these.
			src.equip_if_possible(new /obj/item/device/pda/clown(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/clown (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/bikehorn(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/stamp/clown(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/toy/crayon/rainbow(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/toy/crayonbox(src), slot_in_backpack)
			src.mutations |= CLOWN

		if ("Mime")
			if (src.gender == FEMALE)
				src.equip_if_possible(new /obj/item/clothing/under/sexymime(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/mask/gas/sexymime(src), slot_wear_mask)
			else //MALE or NEUTER
				src.equip_if_possible(new /obj/item/clothing/under/mime(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/mask/gas/mime(src), slot_wear_mask)
				src.equip_if_possible(new /obj/item/clothing/suit/suspenders(src), slot_wear_suit)
			//All genders require these.
			src.equip_if_possible(new /obj/item/clothing/head/beret(src), slot_head)
			src.equip_if_possible(new /obj/item/device/pda/mime(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/white(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/toy/crayon/mime(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(src), slot_in_backpack)
			src.verbs += /client/proc/mimespeak
			src.verbs += /client/proc/mimewall
			src.mind.special_verbs += /client/proc/mimespeak
			src.mind.special_verbs += /client/proc/mimewall
			src.miming = 1

		if ("Station Engineer")
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/engineer(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/orange(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/storage/utilitybelt/full(src), slot_l_hand) //currently spawns in hand due to traitor assignment requiring a PDA to be on the belt. --Errorage
			//src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves) removed as part of Dangercon 2011, approved by Urist_McDorf --Errorage
			src.equip_if_possible(new /obj/item/device/t_scanner(src), slot_r_store)

		if ("Shaft Miner")
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/engineer(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_mine (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/under/rank/miner(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/satchel(src), slot_in_backpack)

		if ("Assistant")
			src.equip_if_possible(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)

		if ("Detective")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/det(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/detective(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/det_hat(src), slot_head)
			var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(src)
			CIG.light("")
			src.equip_if_possible(CIG, slot_wear_mask) // sorry, no more cigar
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/fcard_kit(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/fcardholder(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/suit/det_suit(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/detective_scanner(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/zippo(src), slot_l_store)
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/candy_corn(src), slot_h_store)
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
			L.imp_in = src
			L.implanted = 1

		if ("Medical Doctor")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_s_store)

		if ("Captain")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/captain (src), slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/captain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/captain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/captain(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/caphat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
			L.imp_in = src
			L.implanted = 1

		if ("Security Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/security(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_s_store)
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
			L.imp_in = src
			L.implanted = 1

		if ("Warden")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/warden(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/warden(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(src), slot_glasses)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/emergency(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/taser(src), slot_s_store)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
			L.imp_in = src
			L.implanted = 1

		if ("Scientist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sci (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/under/rank/scientist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/science(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/gas(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/tank/oxygen(src), slot_l_hand)

		if ("Head of Security") //ready to come in game and kick ass - Microwave
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hos (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/heads/hos(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/hos(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/emergency(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(src), slot_glasses)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/gun/energy(src), slot_s_store)
			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
			L.imp_in = src
			L.implanted = 1

		if ("Head of Personnel")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hop (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/heads/hop(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)

		if ("Atmospheric Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)

		if ("Bartender")
			src.equip_if_possible(new /obj/item/clothing/under/rank/bartender(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(src), slot_in_backpack)

		if ("Chef")
			src.equip_if_possible(new /obj/item/clothing/under/rank/chef(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/chef(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/chefhat(src), slot_head)

		if ("Roboticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_rob (src), slot_ears) // -- DH
			src.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)

		if ("Botanist") //slot_s_store will free the hands of the working class
			src.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/botanic_leather(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/suit/apron(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/analyzer/plant_analyzer(src), slot_s_store)

		if ("Librarian")
			src.equip_if_possible(new /obj/item/clothing/under/suit_jacket/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/barcodescanner(src), slot_l_hand)

		if ("Lawyer")
			if (!lawyer)
				lawyer = 1
				src.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/suit/lawyer/bluejacket(src), slot_wear_suit)
				src.equip_if_possible(new /obj/item/device/pda/lawyer(src), slot_belt)
			else
				src.equip_if_possible(new /obj/item/clothing/under/lawyer/purpsuit(src), slot_w_uniform)
				src.equip_if_possible(new /obj/item/clothing/suit/lawyer/purpjacket(src), slot_wear_suit)
				src.equip_if_possible(new /obj/item/device/pda/lawyer(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/detective_scanner(src), slot_in_backpack)//Why do they even get this?
			src.equip_if_possible(new /obj/item/weapon/storage/briefcase(src), slot_l_hand)

		if ("Quartermaster")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/qm (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_l_hand)

		if ("Cargo Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)

		if ("Chief Engineer")
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/engineer(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/ce (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves) //changed to black as part of dangercon 2011, approved by Urist_McDorf --Errorage
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat/white(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/storage/utilitybelt/full(src), slot_l_hand) //currently spawns in hand due to traitor assignment requiring a PDA to be on the belt. --Errorage
			var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(src)
			CIG.light("")
			src.equip_if_possible(CIG, slot_wear_mask) // sorry, no more cigar
			//src.equip_if_possible(new /obj/item/clothing/glasses/meson(src), slot_glasses) Removed as part of DangerCon 2011, approved by Urist_McDorf, --Errorage
			src.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/heads/ce(src), slot_belt)

		if ("Research Director")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/rd (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/research_director(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/heads/rd(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			//src.equip_if_possible(new /obj/item/weapon/pen(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_r_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_s_store)

		if ("Chief Medical Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/cmo (src), slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chief_medical_officer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/heads/cmo(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/cmo(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_s_store)

		if ("Virologist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/storage/box/survival(src.back), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/mask/surgical(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/virologist(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_s_store)

		if ("Cyborg")
//			Robotize()

		if ("AI")
			src.mind.assigned_role = "AI"

		else
			src << "RUH ROH! Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

	spawnId(rank)
	if (rank == "Captain")
		world << "<b>[src] is the captain!</b>"
	src << "<B>You are the [rank].</B>"
	src.job = rank
	if (src.mind)
		src.mind.assigned_role = rank

	if (!joined_late && rank != "Tourist")
		var/obj/S = null
		for(var/obj/landmark/start/sloc in world)
			if (sloc.name != rank)
				continue
			if (locate(/mob) in sloc.loc)
				continue
			S = sloc
			break
		if (!S)
			S = locate("start*[rank]") // use old stype
		if (istype(S, /obj/landmark/start) && istype(S.loc, /turf))
			src.loc = S.loc
//			if (S.name == "Cyborg")
//				src.Robotize()
	/*else
		var/list/L = list()
		for(var/area/arrival/start/S in world)
			L += S
		if (L.len < 1) // Added this check to stop the empty list bug -- TLE
			return	 // **
		var/A = pick(L)
		var/list/NL = list()
		for(var/turf/T in A)
			if (!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if (O.density)
						clear = 0
						break
				if (clear)
					NL += T
		src.loc = pick(NL)
		*/
	if (src.mind)
		if (src.mind.assigned_role == "Cyborg")
			src << "YOU ARE GETTING BORGED NOW"
			src.Robotize()
			return
	if (src.mind)
		if (src.mind.assigned_role == "AI")
			src << "Welcome, AI."
			src.AIize() //Make AI.
	src.equip_if_possible(new /obj/item/device/radio/headset(src), slot_ears)
	var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(src)
	new /obj/item/weapon/storage/box/survival(BPK)
	src.equip_if_possible(BPK, slot_back,1)
	/*
	spawn(10)
		var/obj/item/weapon/camera_test/CT = new/obj/item/weapon/camera_test(src.loc)
		CT.afterattack(src, src, 10)
		var/obj/item/weapon/photo/PH
		PH = locate(/obj/item/weapon/photo,src.loc)
		if (PH)
			PH.layer = 3
			src.equip_if_possible(PH, slot_in_backpack)
		del(CT)*/ //--For another day - errorage
	return


/mob/living/carbon/human/proc/spawnId(rank)
	var/obj/item/weapon/card/id/C = null
	switch(rank)
		if ("Cyborg")
			return
		if ("Captain")
			C = new /obj/item/weapon/card/id/gold(src)
		else
			C = new /obj/item/weapon/card/id(src)
	if (C)
		C.registered = src.real_name
		C.assignment = rank
		C.name = "[C.registered]'s ID Card ([C.assignment])"
		C.access = get_access(C.assignment)
		src.equip_if_possible(C, slot_wear_id)
	src.equip_if_possible(new /obj/item/weapon/pen(src), slot_r_store)
	//src.equip_if_possible(new /obj/item/device/radio/signaler(src), slot_belt)
	src.equip_if_possible(new /obj/item/device/pda(src), slot_belt)
	if (istype(src.belt, /obj/item/device/pda))
		var/obj/item/device/pda/pda = src.belt
		pda.owner = src.real_name
		pda.ownjob = src.wear_id.assignment
		pda.name = "PDA-[src.real_name] ([pda.ownjob])"
/*
	if (istype(src.r_store, /obj/item/device/pda))  //damned mime PDAs not starting in belt slot
		var/obj/item/device/pda/pda = src.r_store
		pda.owner = src.real_name
		pda.ownjob = src.wear_id.assignment
		pda.name = "PDA-[src.real_name] ([pda.ownjob])"
*/
	if (rank == "Clown")
		spawn clname(src) //All this does is give the clown its name and special PDA.

/client/proc/mimewall()
	set category = "Mime"
	set name = "Invisible wall"
	set desc = "Create an invisible wall on your location."
	if (usr.stat)
		usr << "Not when you're incapicated."
		return
	if (!usr.miming)
		usr << "You still haven't atoned for your speaking transgression. Wait."
		return
	usr.verbs -= /client/proc/mimewall
	spawn(100)
		usr.verbs += /client/proc/mimewall
	for (var/mob/V in viewers(usr))
		if (V!=usr)
			V.show_message("[usr] looks as if a wall is in front of them.", 3, "", 2)
	usr << "You form a wall in front of yourself."
	var/obj/forcefield/F =  new /obj/forcefield(locate(usr.x,usr.y,usr.z))
	F.icon_state = "empty"
	F.name = "invisible wall"
	F.desc = "You have a bad feeling about this."
	spawn (300)
		del (F)
	return

/client/proc/mimespeak()
	set category = "Mime"
	set name = "Speech"
	set desc = "Toggle your speech."
	if (usr.miming)
		usr.miming = 0
	else
		usr << "You'll have to wait if you want to atone for your sins."
		spawn(3000)
			usr.miming = 1
	return
