/datum/job

	//The name of the job
	var/title = "NOPE"
	//Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access = list()      // Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()              // Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)
	var/list/software_on_spawn = list()   // Defines the software files that spawn on tablets and labtops
	var/department_flag = 0
	var/department_flag2 = 0
	var/total_positions = 0               // How many players can be this job
	var/spawn_positions = 0               // How many players can spawn in as this job
	var/current_positions = 0             // How many players have this job
	var/availablity_chance = 100          // Percentage chance job is available each round

	var/supervisors = null                // Supervisors, who this person answers to directly
	var/selection_color = "#ffffff"       // Selection screen color
	var/list/alt_titles                   // List of alternate titles, if any and any potential alt. outfits as assoc values.
	var/req_admin_notify                  // If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/minimal_player_age = 0            // If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/department = null                 // Does this position have a department tag?
	var/head_position = 0                 // Is this position Command?
	var/minimum_character_age = 0
	var/ideal_character_age = 30
	var/create_record = 1                 // Do we announce/make records for people who spawn on this job?

	var/account_allowed = 1				  // Does this job type come with a station account?
	var/economic_modifier = 2			  // With how much does this job modify the initial account amount?
	var/base_pay = 9 					  // Always minimum wage at all times. Also base = 1 hr, paychecks calculate base * 4
	var/outfit_type                       // The outfit the employee will be dressed in, if any
	var/intern = 0                        // If this job is an intern or not? (Assistants)

	var/loadout_allowed = TRUE            // Whether or not loadout equipment is allowed and to be created when joining.
	var/list/allowed_branches             // For maps using branches and ranks, also expandable for other purposes
	var/list/allowed_ranks                // Ditto

	var/announced = TRUE                  //If their arrival is announced on radio
	var/latejoin_at_spawnpoints           //If this job should use roundstart spawnpoints for latejoin (offstation jobs etc)

	var/hud_icon						  //icon used for Sec HUD overlay

/datum/job/New()
	..()
	if(prob(100-availablity_chance))	//Close positions, blah blah.
		total_positions = 0
		spawn_positions = 0

/datum/job/dd_SortValue()
	return title

/datum/job/New()
	..()
	if(!hud_icon)
		hud_icon = "hud[ckey(title)]"

/datum/job/proc/equip(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	var/decl/hierarchy/outfit/outfit = get_outfit(H, alt_title, branch)
	if(!outfit)
		return FALSE
	. = outfit.equip(H, title, alt_title)

/datum/job/proc/get_outfit(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	if(alt_title && alt_titles)
		. = alt_titles[alt_title]
	if(allowed_branches && branch)
		. = allowed_branches[branch.type] || .
	. = . || outfit_type
	. = outfit_by_type(.)

/datum/job/proc/setup_account(var/mob/living/carbon/human/H)
	if(!account_allowed)
		return
/*
	var/loyalty = 1
	if(H.client)
		switch(H.client.prefs.nanotrasen_relation)
			if(COMPANY_LOYAL)		loyalty = 1.30
			if(COMPANY_SUPPORTATIVE)loyalty = 1.15
			if(COMPANY_NEUTRAL)		loyalty = 1
			if(COMPANY_SKEPTICAL)	loyalty = 0.85
			if(COMPANY_OPPOSED)		loyalty = 0.70

	//give them an account in the station database
	if(!(H.species && (H.species.type in economic_species_modifier)))
		return //some bizarre species like shadow, slime, or monkey? You don't get an account.

	var/species_modifier = economic_species_modifier[H.species.type]
*/
	spawn(10)
		var/datum/money_account/M = H.client.prefs.bank_account
		if(H.mind)
			var/remembered_info = ""
			remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
			remembered_info += "<b>Your account pin is:</b> [M.account_pin]<br>"
			remembered_info += "<b>Your account funds are:</b> T[H.client.prefs.bank_account.bank_balance]<br>"
			LAZYINITLIST(M.transaction_log)
			var/datum/transaction/T = M.transaction_log[1]
			if(T)
				remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
			H.mind.store_memory(remembered_info)

			for(var/obj/item/weapon/card/id/ID in H.contents)
				if(ID)
					ID.associated_account_number = M.account_number

		to_chat(H, "<span class='notice'><b>Your account number is: [M.account_number], your account pin is: [M.account_pin]</b></span>")

// overrideable separately so AIs/borgs can have cardborg hats without unneccessary new()/qdel()
/datum/job/proc/equip_preview(mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch)
	var/decl/hierarchy/outfit/outfit = get_outfit(H, alt_title, branch)
	if(!outfit)
		return FALSE
	. = outfit.equip_base(H, title, alt_title)

/datum/job/proc/get_access()
	if(minimal_access.len && (!config || config.jobs_have_minimal_access))
		return src.minimal_access.Copy()
	else
		return src.access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	return (available_in_days(C) == 0) //Available in 0 days = available right now = player is old enough to play.

/datum/job/proc/available_in_days(client/C)
	if(C && config.use_age_restriction_for_jobs && isnull(C.holder) && isnum(C.player_age) && isnum(minimal_player_age))
		return max(0, minimal_player_age - C.player_age)
	return 0

/datum/job/proc/apply_fingerprints(var/mob/living/carbon/human/target)
	if(!ishuman(target))
		return 0
	for(var/obj/item/item in target.contents)
		apply_fingerprints_to_item(target, item)
	return 1

/datum/job/proc/apply_fingerprints_to_item(var/mob/living/carbon/human/holder, var/obj/item/item)
	item.add_fingerprint(holder,1)
	if(item.contents.len)
		for(var/obj/item/sub_item in item.contents)
			apply_fingerprints_to_item(holder, sub_item)

/datum/job/proc/is_position_available()
	return (current_positions < total_positions) || (total_positions == -1)

/datum/job/proc/has_alt_title(var/mob/H, var/supplied_title, var/desired_title)
	return (supplied_title == desired_title) || (H.mind && H.mind.role_alt_title == desired_title)

/datum/job/proc/is_restricted(var/datum/preferences/prefs, var/feedback)
	if(!is_branch_allowed(prefs.char_branch))
		to_chat(feedback, "<span class='boldannounce'>Wrong branch of service for [title]. Valid branches are: [get_branches()].</span>")
		return TRUE

	if(!is_rank_allowed(prefs.char_branch, prefs.char_rank))
		to_chat(feedback, "<span class='boldannounce'>Wrong rank for [title]. Valid ranks in [prefs.char_branch] are: [get_ranks(prefs.char_branch)].</span>")
		return TRUE

	var/datum/species/S = all_species[prefs.species]
	if(!is_species_allowed(S))
		to_chat(feedback, "<span class='boldannounce'>Restricted species, [S], for [title].</span>")
		return TRUE

	return FALSE

/datum/job/proc/is_species_allowed(var/datum/species/S)
	return !GLOB.using_map.is_species_job_restricted(S, src)

/**
 *  Check if members of the given branch are allowed in the job
 *
 *  This proc should only be used after the global branch list has been initialized.
 *
 *  branch_name - String key for the branch to check
 */
/datum/job/proc/is_branch_allowed(var/branch_name)
	if(!GLOB.using_map || !(GLOB.using_map.flags & MAP_HAS_BRANCH))
		return 1
	if(branch_name == "None" || !branch_name)
		return 0

	if(branch_name == department)
		return 1
	else
		return 0

/datum/job/proc/is_valid_department(var/dept_flag, var/mob/user)
	if(dept_flag == department_flag)
		return 1
	else if(user.client && user.client.prefs)
		if(department_flag & COM && user.client.prefs.promoted == 4)
			return 1 // Command flag but different department is usually department head.
		else
			return 0
	else
		return 0
/**
 *  Check if people with given rank are allowed in this job
 *
 *  This proc should only be used after the global branch list has been initialized.
 *
 *  branch_name - String key for the branch to which the rank belongs
 *  rank_name - String key for the rank itself
 */
/datum/job/proc/is_rank_allowed(var/branch_name, var/rank_name)
	if(!allowed_ranks || !GLOB.using_map || !(GLOB.using_map.flags & MAP_HAS_RANK))
		return 1
	if(branch_name == "None" || rank_name == "None")
		return 0

	var/datum/mil_rank/rank = mil_branches.get_rank(branch_name, rank_name)

	if(!rank)
		crash_with("unknown rank \"[rank_name]\" in branch \"[branch_name]\" passed to is_rank_allowed()")
		return 0

	if(is_type_in_list(rank, allowed_ranks))
		return 1
	else
		return 0

//Returns human-readable list of branches this job allows.
/datum/job/proc/get_branches()
	var/list/res = list()
	for(var/T in allowed_branches)
		var/datum/mil_branch/B = mil_branches.get_branch_by_type(T)
		res += B.name
	return english_list(res)

//Same as above but ranks
/datum/job/proc/get_ranks(branch)
	var/list/res = list()
	var/datum/mil_branch/B = mil_branches.get_branch(branch)
	for(var/T in allowed_ranks)
		var/datum/mil_rank/R = T
		if(B && !(initial(R.name) in B.ranks))
			continue
		res += initial(R.name)
	return english_list(res)

/proc/get_department(var/department_flag, var/bit) //bit changes from text to bit, 1=returns text form, 0=returns bit form
	if(!department_flag) return null
	switch(bit)
		if(1)
			switch(department_flag)
				if(SEC)
					return "Security"
				if(SCI)
					return "Science"
				if(LOG)
					return "Logistics"
				if(ENG)
					return "Engineering"
				if(SRV)
					return "Service"
				if(CIV)
					return "Civilian"
				if(MED)
					return "Medical"
				if(NTO)
					return "NanoTrasen"
				if(COM)
					return "Command"
		if(0)
			switch(department_flag)
				if("Security")
					return SEC
				if("Science")
					return SCI
				if("Engineering")
					return ENG
				if("Logistics")
					return LOG
				if("Service")
					return SRV
				if("Civilian")
					return CIV
				if("Medical")
					return MED
				if("NanoTrasen")
					return NTO
				if("Command")
					return COM