/proc/check_whitelist(mob/M)
	if(!M)
		return 0
	if(check_rights(R_ADMIN, 0, M))
		return 1
	return M.client.command_whitelist

/proc/is_species_whitelisted(mob/M, var/species_name)
	var/datum/species/S = all_species[species_name]
	return is_alien_whitelisted(M, S)

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!M || !species)
		return 0
	if(check_rights(R_ADMIN, 0, M))
		return 1

	if(istype(species,/datum/species))
		var/datum/species/S = species
		if(!(S.spawn_flags & (SPECIES_IS_WHITELISTED|SPECIES_IS_RESTRICTED)))
			return 1
		return whitelist_lookup(S.name, M.client)

	if(istype(species,/datum/language))
		var/datum/language/L = species
		if(!(L.flags & (WHITELISTED|RESTRICTED)))
			return 1
		return whitelist_lookup(L.name, M.client)

	return 0

/proc/whitelist_lookup(var/species, var/client/C)
	if(!species || !C)
		return 0
	LAZYINITLIST(C.alien_whitelist)
	if(C.alien_whitelist[species] == 1)
		return 1
	return 0

/proc/get_alien_flag(var/species)
	var/list/aliens = list( "diona" = A_WHITELIST_DIONA,
							"skrell" = A_WHITELIST_SKRELL,
							"tajara" = A_WHITELIST_TAJARA,
							"unathi" = A_WHITELIST_UNATHI,
							"wryn" = A_WHITELIST_WRYN,
							"machine" = A_WHITELIST_MACHINE,
							"resomi" = A_WHITELIST_RESOMI)
	var/alien_flag = 0

	if( lowertext( species ) in aliens )
		alien_flag = aliens[lowertext( species )]

	return alien_flag

/client/proc/add_whitelist()
	set category = "Admin"
	set name = "Write to whitelist"
	set desc = "Adds or removes a user to any whitelist available in the directory mid-round."

	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/client/C
	switch(alert("Is player online?","Set whitelist","Yes","No"))
		if("Yes")
			C = input("Please, select a player!", "Add User to Whitelist") in GLOB.clients
			if(!C || C == src)
				usr << "<span class='warning'>Either he/she does not exsist or you've tried promoting yourself.</span>"
				return 0
		if("No")
			C = input("Please enter ckey of player (be sure about this!)", "Add User to Whitelist") as text
			if(!C || C == src)
				usr << "<span class='warning'>Either he/she does not exsist or you've tried promoting yourself.</span>"
				return 0

	var/type = input("Select what type of whitelist", "Add User to Whitelist") as null|anything in list( "Command Whitelist", "Alien Whitelist", "Donators" )

	switch(type)
		if("Command Whitelist")
			if(C.command_whitelist)
				switch(input("Remove whitelist?", "remove Whitelist", "Yes", "No"))
					if("Yes")
						message_admins("[key_name_admin(usr)] has un-whitelisted [C].")
						to_chat(C, "un-Whitelisted for command roles.")
						C.command_whitelist = 0
					else
						usr << "<span class='warning'>Could not add [C] to the command whitelist. Already on whitelist.</span>"
						return 0
			else
				message_admins("[key_name_admin(usr)] has whitelisted [C].")
				to_chat(C, "Whitelisted for command roles.")
				C.command_whitelist = 1
		if("Alien Whitelist")
			var/datum/species/race = input("Which species?") as null|anything in whitelisted_species
			if(!race)
				return 0
			C.alien_whitelist[race] = 1
			message_admins("[key_name_admin(usr)] has whitelisted [C] for [race].")
			to_chat(C, "Whitelisted for race [race].")
		if("Donators")
			if(is_donator(C))
				usr << "<span class='warning'>Could not add [C] to donators. Already a donator.</span>"
				return 0
			C.donator = 1
			C.donatorsince = world.realtime
			message_admins("[key_name_admin(usr)] has added [C] as a donator.")
			to_chat(C, "Donator status added.")
	if(C.saveclientdb(C.ckey))
		usr << "Whitelist written to file."
	else
		usr << "Whitelist could not be written, please try again or contact laser."