/*
var/const/ENG               =(1<<0)
var/const/SEC               =(1<<1)
var/const/MED               =(1<<2)
var/const/SCI               =(1<<3)
var/const/CIV               =(1<<4)
var/const/COM               =(1<<5)
var/const/MSC               =(1<<6)
var/const/SRV               =(1<<7)
var/const/SUP               =(1<<8)
var/const/SPT               =(1<<9)
var/const/EXP               =(1<<10)

*/
GLOBAL_LIST_EMPTY(assistant_occupations)

GLOBAL_LIST_EMPTY(command_positions)

GLOBAL_LIST_EMPTY(engineering_positions)

GLOBAL_LIST_EMPTY(medical_positions)

GLOBAL_LIST_EMPTY(science_positions)

GLOBAL_LIST_EMPTY(civilian_positions)

GLOBAL_LIST_EMPTY(security_positions)

GLOBAL_LIST_INIT(nonhuman_positions, list("pAI"))

GLOBAL_LIST_EMPTY(service_positions)

GLOBAL_LIST_EMPTY(supply_positions)

GLOBAL_LIST_EMPTY(support_positions)

GLOBAL_LIST_EMPTY(nanotrasen_positions)

GLOBAL_LIST_EMPTY(exploration_positions)

GLOBAL_LIST_EMPTY(unsorted_positions) // for nano manifest


/proc/guest_jobbans(var/job)
	return (job in GLOB.command_positions)

/proc/get_job_datums()
	. = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		. += job

	return .

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	. = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			. = J.alt_titles

	return .

/proc/calculate_department_rank(var/mob/living/carbon/human/M)
	if(ishuman(M))
		if(M && M.client && M.CharRecords && M.job)
			var/oldrank = M.CharRecords.department_rank
			var/playtime = round(M.CharRecords.department_experience/60, 0.1) // In hours.
			if(M.client.prefs.promoted == JOB_LEVEL_INTERN)
				if(playtime >= 4.0) // Intern level is upgraded after 4 hours of playtime
					if(!oldrank) //No old rank
						M.client.prefs.promoted = JOB_LEVEL_REGULAR
						M.CharRecords.department_rank = 1
				else
					if(playtime < 4.0 && !oldrank)
						M.CharRecords.department_rank = 0
					return 0 //Interns don't get ranks.
			switch(playtime)
				if(0 to 4)
					M.CharRecords.department_rank = 0
				if(4.1 to 7.9)
					M.CharRecords.department_rank = 1 //Intern--Lvl 1
				if(8 to 16.9)
					M.CharRecords.department_rank = 2 //Junior
				if(17 to 25.9)
					M.CharRecords.department_rank = 3 //Regular
				if(26 to 39.9)
					if(M.client.prefs.promoted == JOB_LEVEL_SENIOR) //Promoted from Regular to Senior-capable.
						M.CharRecords.department_rank = 4 //Senior
				if(40 to 60.9) // Yeah it stops here.
					if(M.client.prefs.promoted == JOB_LEVEL_SENIOR)
						M.CharRecords.department_rank = 5 //Expert
				if(61 to 100000)
					if(M.client.prefs.promoted == JOB_LEVEL_SENIOR)
						M.CharRecords.department_rank = 6 //Lead

			if(M.CharRecords.department_rank != oldrank) //Ranks changed)
				M.client.prefs.save_character()
				if(M.CharRecords.department_rank > oldrank)
					if(!oldrank && M.CharRecords.department_rank == 1) //Was intern and now 'intern'
						PersistentSys.SendPDAMessage(M, "Congratulations, your first internship period has been successful! Full career selection is now possible.")
						M.CharRecords.add_employeerecord("NanoTrasen", "Reaching Seniority Status within the company", rand(5, 7), 0, 0, 100, 1)
					else
						PersistentSys.SendPDAMessage(M, "You have recieved a promotion. You are now a [get_department_rank_title(get_department(M.CharRecords.char_department, 1), M.CharRecords.department_rank)] [M.job].")
					for(var/obj/item/weapon/card/id/id_card in M.contents)
						if(id_card.registered_name == M.real_name) //Extra verification
							M:set_id_info(id_card)
					if(oldrank == 3 && M.CharRecords.department_rank == 4 && M.client.prefs.promoted == JOB_LEVEL_SENIOR) //If they became Senior (and were allowed to)
						M.CharRecords.add_employeerecord("NanoTrasen", "Reaching Seniority Status within the company", 7, 0, 0, 500, 1)
			return M.CharRecords.department_rank
	return 1


/proc/get_department_rank_title(var/department, var/rank, var/ishead = 0)
	if(department && rank)
		if(department == "Command" || ishead)
			if(rank == 4)
				return "Senior"
			else
				return null
		if(department != "Command")
			switch(rank)
				if(null || 0 to 1) //Intern
					switch(department)
						if("Civilian")
							return "Assistant"
						if("Security")
							return "Cadet"
						if("Medical")
							return "Assistant"
						if("Engineering")
							return "Assistant"
						else
							return "Intern"
				if(2) //Junior
					return "Junior"
				if(3) //Regular
					return null // No rank.
				if(4) //Senior
					return "Senior"
				if(5) //Lead
					switch(department)
						if("Civilian")
							return "Expert" //Different name because Lead is weird for civvies.
						else return "Lead"