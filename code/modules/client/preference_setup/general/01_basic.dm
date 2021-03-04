datum/preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/spawnpoint = "Default" 			//where this character will spawn (0-2).
	var/metadata = ""
	var/char_lock = 0					//Is this character locked? (persistent)
	var/permadeath = 0					//Is this an ironman/perma death character?
	var/char_dead = 0						//Is this character dead? (Char Lock)
	var/char_deadsince = 0

/datum/category_item/player_setup_item/general/basic
	name = "Basic"
	sort_order = 1

/datum/category_item/player_setup_item/general/basic/load_character(var/savefile/S)
	S["real_name"]				>> pref.real_name
	S["name_is_always_random"]	>> pref.be_random_name
	S["gender"]					>> pref.gender
	S["age"]					>> pref.age
	S["spawnpoint"]				>> pref.spawnpoint
	S["OOC_Notes"]				>> pref.metadata
	S["char_lock"]				>> pref.char_lock
	S["permadeath"]				>> pref.permadeath
	S["char_dead"]				>> pref.char_dead
	S["char_deadsince"]			>> pref.char_deadsince

/datum/category_item/player_setup_item/general/basic/save_character(var/savefile/S)
	S["real_name"]				<< pref.real_name
	S["name_is_always_random"]	<< pref.be_random_name
	S["gender"]					<< pref.gender
	S["age"]					<< pref.age
	S["spawnpoint"]				<< pref.spawnpoint
	S["OOC_Notes"]				<< pref.metadata
	S["char_lock"]				<< pref.char_lock
	S["permadeath"]				<< pref.permadeath
	S["char_dead"]				<< pref.char_dead
	S["char_deadsince"]			<< pref.char_deadsince

/datum/category_item/player_setup_item/general/basic/sanitize_character()
	var/datum/species/S = all_species[pref.species ? pref.species : SPECIES_HUMAN]
	if(!S) S = all_species[SPECIES_HUMAN]
	pref.age                = sanitize_integer(pref.age, S.min_age, S.max_age, initial(pref.age))
	pref.gender             = sanitize_inlist(pref.gender, S.genders, pick(S.genders))
	pref.real_name          = sanitize_name(pref.real_name, pref.species)
	if(!pref.real_name)
		pref.real_name      = random_name(pref.gender, pref.species)
	pref.spawnpoint         = sanitize_inlist(pref.spawnpoint, spawntypes(), initial(pref.spawnpoint))
	pref.be_random_name     = sanitize_integer(pref.be_random_name, 0, 1, initial(pref.be_random_name))

/datum/category_item/player_setup_item/general/basic/content()
	. = list()
	. += "<body>"
	if(pref.char_dead)
		. += "<span class='warning'><b>WARNING: This character is Deceased. ([round((world.realtime - pref.char_deadsince) / 864000, 0.1)] Days Ago)</b></span>"
	if(pref.char_lock)
		. += "<b>Name:</b> "
		. += "<b>[pref.real_name]</b><br>"
		. += "<br>"
		. += "<b>Gender:</b> [gender2text(pref.gender)]<br>"
		. += "<b>Age:</b> [pref.age]<br>"
		. += "<b>Spawn Point:</b> <a href='?src=\ref[src];spawnpoint=1'>[pref.spawnpoint]</a><br>"
		. += "<b>Iron-Man Mode:</b> [pref.permadeath ? "Yes" : "No"]<br>"
		. += "<h3>Persistency Coins</h3><br>"
		. += "<b>Command Coins:</b> [usr.client.command_coin ? "[usr.client.command_coin]" : "None"]<br>"
		. += "<b>Employee Coins:</b> [usr.client.employee_coin ? "[usr.client.employee_coin]" : "None"]<br>"
	else
		. += "<b>Name:</b> "
		. += "<a href='?src=\ref[src];rename=1'><b>[pref.real_name]</b></a><br>"
		. += "<a href='?src=\ref[src];random_name=1'>Randomize Name</A><br>"
		. += "<a href='?src=\ref[src];always_random_name=1'>Always Random Name: [pref.be_random_name ? "Yes" : "No"]</a>"
		. += "<br>"
		. += "<b>Gender:</b> <a href='?src=\ref[src];gender=1'><b>[gender2text(pref.gender)]</b></a><br>"
		. += "<b>Age:</b> <a href='?src=\ref[src];age=1'>[pref.age]</a><br>"
		. += "<b>Spawn Point</b>: <a href='?src=\ref[src];spawnpoint=1'>[pref.spawnpoint]</a><br>"
		. += "<b>Iron-Man Mode:</b> <a href='?src=\ref[src];ironman=1'>[pref.permadeath ? "Yes" : "No"]</a><br>"
		. += "<span class='warning'><font size='2'><i>Warning: do not enable without reading about it <a href='http://www.wiki.apollo-gaming.net/index.php/Permanent_Character_Death'>HERE</a></i></font></span><br>"

		. += "<h3>Persistency Coins</h3>"
		. += "<b>Command Coins:</b> <a href='?src=\ref[src];comcoin=1'>[usr.client.command_coin ? "[usr.client.command_coin]" : "None"]</a><br>"
		. += "<b>Employee Coins:</b> <a href='?src=\ref[src];empcoin=1'>[usr.client.employee_coin ? "[usr.client.employee_coin]" : "None"]</a><br>"

	if(config.allow_Metadata)
		. += "<b>OOC Notes:</b> <a href='?src=\ref[src];metadata=1'> Edit </a><br>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/general/basic/OnTopic(var/href,var/list/href_list, var/mob/user)
	var/datum/species/S = all_species[pref.species]
	if(href_list["rename"])
		var/raw_name = input(user, "Choose your character's name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if(new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				to_chat(user, "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>")
				return TOPIC_NOACTION

	else if(href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

	else if(href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	else if(href_list["gender"])
		var/new_gender = input(user, "Choose your character's gender:", "Character Preference", pref.gender) as null|anything in S.genders
		if(new_gender && CanUseTopic(user))
			pref.gender = new_gender
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["age"])
		var/new_age = input(user, "Choose your character's age:\n([S.min_age]-[S.max_age])", "Character Preference", pref.age) as num|null
		if(new_age && CanUseTopic(user))
			pref.age = max(min(round(text2num(new_age)), S.max_age), S.min_age)
			return TOPIC_REFRESH

	else if(href_list["spawnpoint"])
		var/list/spawnkeys = list()
		for(var/spawntype in spawntypes())
			spawnkeys += spawntype
		var/choice = input(user, "Where would you like to spawn when late-joining?") as null|anything in spawnkeys
		if(!choice || !spawntypes()[choice] || !CanUseTopic(user))	return TOPIC_NOACTION
		pref.spawnpoint = choice
		return TOPIC_REFRESH

	else if(href_list["metadata"])
		var/new_metadata = sanitize(input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , pref.metadata)) as message|null
		if(new_metadata && CanUseTopic(user))
			pref.metadata = new_metadata
			return TOPIC_REFRESH

	else if(href_list["comcoin"])
		if(user.client.command_coin >= 1)
			to_chat(usr, "<b>A command coin instantly promotes your character to unlock head positions. One-time use on 1 character. Use before joining. And save character after use!")
			switch(alert("Use a command coin on character [pref.real_name]?", "Command Coin", "Yes", "No"))
				if("Yes")
					pref.promoted = JOB_LEVEL_HEAD
					user.client.command_coin--
					user.client.playerdb["command_coin"] << user.client.command_coin
					user.client.saveclientdb(user.client.ckey)
					pref.save_character()
					return TOPIC_REFRESH
				else
					to_chat(user, "<span class='warning'>Cancelled.</span>")
					return TOPIC_NOACTION
		else
			to_chat(user, "<span class='warning'>You do not have any coins!</span>")
			return TOPIC_NOACTION
	else if(href_list["empcoin"])
		if(user.client.employee_coin >= 1)
			to_chat(usr, "<b>A employee coin instantly promotes your character to a regular employee, skipping all internship periods. One-time use on 1 character. Use before joining. And save character after use!")
			switch(alert("Use a employee coin on character [pref.real_name]? (Read chat)", "Command Coin", "Yes", "No"))
				if("Yes")
					pref.promoted = JOB_LEVEL_REGULAR
					user.client.employee_coin--
					user.client.playerdb["employee_coin"] << user.client.employee_coin
					user.client.saveclientdb(user.client.ckey)
					pref.save_character()
					return TOPIC_REFRESH
				else
					to_chat(user, "<span class='warning'>Cancelled.</span>")
					return TOPIC_NOACTION
		else
			to_chat(user, "<span class='warning'>You do not have any coins!</span>")
			return TOPIC_NOACTION

	else if(href_list["ironman"])
		switch(alert("Are you absolutely sure you want to enable/disable permanent death (lost on death after round end) for this character?", "Iron-Man Mode", "Yes", "No"))
			if("Yes")
				if(CanUseTopic(user))
					if(pref.permadeath)
						to_chat(user, "<span class='warning'>Iron-Man Mode now turned OFF. (Was on)</span>")
						pref.permadeath = 0
						return TOPIC_REFRESH
					else
						to_chat(user, "<span class='warning'>Iron-Man Mode now turned ON. (Was off)</span>")
						pref.permadeath = 1
					return TOPIC_REFRESH
			else
				if(pref.permadeath)
					to_chat(user, "<span class='warning'>Iron-Man Mode now turned OFF. (Was on)</span>")
					pref.permadeath = 0
					return TOPIC_REFRESH
				else
					to_chat(user, "<span class='warning'>Cancelled.</span>")
					return TOPIC_NOACTION

	return ..()
