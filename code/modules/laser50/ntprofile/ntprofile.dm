/*=============EXTRA NOTES=============
- There are 2 variables that save the department; client.prefs.prefs_department and (human)mob.CharRecords.char_department
^ Both mut be set properly, or things break.
=====================================*/
/datum/ntprofile
	var/tmp/mob/owner
/*-------DEPARTMENT-RELATED-------*/
	var/char_department = SRV
	var/department_playtime = 0
	var/department_experience = 0
	var/department_rank = 0
/*-------CHARACTER-RELATED-------*/
	var/pension_balance = 0
	var/mentorship = 0 //Is this character a mentor for interns?
	var/tmp/mentoring = "" //Name of character we are mentoring.
	var/bonuscredit = 0
	var/employeescore = 5 //Calculated at run-time.
	var/employedsince
	var/list/employee_records = list()
	var/list/nt_messages = list() //Basically a backlog of anything that happened. EG head request accepted.
	var/neurallaces = 0
	var/newcharinit = 0
	//BANKING/ATM
	var/datum/money_account/bank_account
/*--------OTHER-RELATED--------*/

/datum/ntprofile/proc/Reset_Profile()
	for(var/a in src.vars)
		a = initial(a)
/*	char_department = initial(char_department)
	department_playtime = initial(department_playtime)
	department_experience = initial(department_experience)
	department_rank = initial(department_rank)
/*-------CHARACTER-RELATED-------*/
	bank_balance = initial(bank_balance)
	pension_balance = initial(pension_balance)
	bonuscredit = initial(bonuscredit)
	employeescore = initial(employeescore)
	employee_records = list()
	nt_messages = list()
	neurallaces = initial(neurallaces)
	promoted = initial(promoted)
	owner.client.prefs.permadeath = 0
*/
	sleep(10)
	save_persistent()

/datum/ntprofile/New(var/mob/M)
	if(M)
		owner = M
		Load_Profile(M)

/datum/ntprofile/proc/Load_Profile() //Init the profile.. Human set as owner.
	var/newchar = 0
	newchar = new_character_setup()
	load_persistent() //Load persistent info.
//	assign_flag()
	Fix_Nulls()
	if(ishuman(owner))
		calculate_department_rank(owner)
		load_score()
		check_bank_account()
		bank_account.check_savings()
		if(newchar)
			add_employeerecord("NanoTrasen", "Beginning of Employment in [get_department(char_department, 1)] Dept.", 5, 0, 0, 250, 1)
			employeescore = 5 //Default.
			to_chat(owner, "{*} First time character detected, enjoy your department! (Initializations complete.)")
			bank_account.bank_balance = 500
			pension_balance = rand(100, 500)
			employedsince = "[stationdate2text()]-[time2text()]"

	if(nt_messages.len) //Returns the backlog of messages.
		for(var/A in nt_messages)
			PersistentSys.SendPDAMessage(owner, A)
			A -= nt_messages

/datum/ntprofile/proc/check_bank_account()
	if(!isnull(bank_account))
		if(!bank_account.owner_mob)
			bank_account.owner_mob = owner
		for(var/datum/money_account/MA in bank_accounts) //Quickfix for trying to make shit work.
			if(!MA.owner_mob || !MA.owner_name || MA.owner_name == bank_account.owner_name)
				del(MA)
		var/datum/transaction/T = bank_account.transaction_log[1]
		if(!T || isnull(T))
			T = new()
			T.target_name = owner.real_name
			T.purpose = "Account creation"
			//set a random date, time and location some time over the past few decades
			T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
			T.time = "[rand(0,24)]:[rand(11,59)]"
			T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"
		if(!isnull(bank_account.account_number))
			return 1 //All is good.
	else
		var/datum/money_account/M = new()
		M.owner_name = owner.real_name
		M.owner_mob = owner
		M.account_pin = rand(1111, 111111)
		M.account_number = random_id("station_account_number", 111111, 999999)
		M.bank_balance = rand(10, 350)

		var/datum/transaction/T
		//create an entry in the account transaction log for when it was created
		LAZYINITLIST(M.transaction_log)
		if(M.transaction_log.len)
			T = M.transaction_log[1]
		else
			T = new()
			T.target_name = owner.real_name
			T.purpose = "Account creation"
			//set a random date, time and location some time over the past few decades
			T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
			T.time = "[rand(0,24)]:[rand(11,59)]"
			T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		//add the account
		M.transaction_log.Add(T)
		bank_account = M


/datum/ntprofile/proc/Fix_Nulls() //Loading nonexsistent items turns them into null. This should fix them all.
	for(var/V in src.vars)
		if(V && isnull(V) && V != 0) //Checks for null, but 0 is not always null soo..
			V = initial(V)

/datum/ntprofile/proc/load_persistent()
	if(owner) //Must be valid.
		if(!owner.client.prefs.loaded_character)	return 0 //ERROR Fuck this shit
		var/savefile/S = new /savefile("data/player_saves/[copytext(owner.client.ckey,1,2)]/[owner.client.ckey]/preferences.sav")
		if(!S)					return 0
		S.cd = GLOB.using_map.character_save_path(owner.client.prefs.default_slot)
		S["char_department"]		>> char_department
		S["department_playtime"]	>> department_playtime
		S["dept_experience"]		>> department_experience
		S["department_rank"]		>> department_rank
		S["pension_balance"]		>> pension_balance
		S["neurallaces"]			>> neurallaces
		S["employee_records"]		>> employee_records
		S["bonuscredit"]			>> bonuscredit
		S["employedsince"]			>> employedsince
		S["newcharinit"]			>> newcharinit
		S["mentorship"]				>> mentorship
		S["bank_account"]			>> bank_account
		bank_accounts |= bank_account

		if(!employee_records || !employee_records.len)
			employee_records = list()
		return 1

/datum/ntprofile/proc/save_persistent()
	if(owner) //Must be valid.
		if(!owner.client.prefs.loaded_character)	return 0 //ERROR Fuck this shit
		var/savefile/S = new /savefile("data/player_saves/[copytext(owner.client.ckey,1,2)]/[owner.client.ckey]/preferences.sav")
		if(!S)					return 0
		S.cd = GLOB.using_map.character_save_path(owner.client.prefs.default_slot)
		if(!employee_records.len)
			employee_records = list()
		S["char_department"]		<< char_department
		S["department_playtime"]	<< department_playtime
		S["dept_experience"]		<< department_experience
		S["department_rank"]		<< department_rank
		S["pension_balance"]		<< pension_balance
		S["neurallaces"]			<< neurallaces
		S["employee_records"]		<< employee_records
		S["bonuscredit"]			<< bonuscredit
		S["newcharinit"]			<< newcharinit
		S["employedsince"]			<< employedsince
		S["mentorship"]				<< mentorship
		S["bank_account"]			<< bank_account
		return 1

/datum/ntprofile/proc/new_character_setup()
	if(owner) //Must be valid.
		if(!owner.client.prefs.loaded_character)	return 0 //ERROR Fuck this shit
		var/savefile/S = new /savefile("data/player_saves/[copytext(owner.client.ckey,1,2)]/[owner.client.ckey]/preferences.sav")
		if(!S)					return 0
		S.cd = GLOB.using_map.character_save_path(owner.client.prefs.default_slot)
		var/isnew = 0
		S["newcharinit"] >> isnew
		if(isnew) //Character seems new?
			Reset_Profile() //Turns all info to default and saves, prevents blank entries.
			newcharinit = 1
			S["newcharinit"]	<< newcharinit //And make sure to save this.
			return 1 //Returns 1 for new character.
		else
			return 0

/datum/ntprofile/proc/load_score()
	if(!owner || !employee_records)	return 5
	var/totalscore = 0
	var/counter = 0
	if(newcharinit)
		for(var/datum/ntprofile/employeerecord/N in employee_records)
			totalscore += N.recomscore
			counter++
		if(totalscore && counter)
			employeescore = totalscore/counter
	else
		if(!totalscore || !counter)
			employeescore = 5 //Assuming new.
	return employeescore
/*
/datum/ntprofile/proc/assign_flag() //Updates the character department and sets the proper flags.
	if(!isnum(char_department)) //Text, apparently bugged out or broken from previous testing..
		char_department = get_department(char_department, 0)
		switch(owner.client.prefs.prefs_department)
			if("Security")
				char_department |= SEC
			if("Medical")
				char_department |= MED
			if("Science")
				char_department |= SCI
			if("Engineering")
				char_department |= ENG
			if("Logistics")
				char_department |= LOG
			if("Service")
				char_department |= SRV
			if("NanoTrasen")
				char_department |= NTO
*/
/datum/ntprofile/employeerecord
	var/maker = "" //The maker of this record.
	var/note = "" //The note to add.
	var/time = ""
	var/recomscore = 0        // The score (1-10) we apply to the overall NT score 0 = no change.
	var/warrantspromotion = 0 //If this is enough to warrant a promotion, EG from regular to senior roles.
	var/paybonuspercent = 0   //The percentage of extra hourly pay this will give the reciever
	var/paybonuscredit = 0    //The amount of credits recieved on the next paycheck.
	var/nanotrasen = 0        //Is this an official NanoTrasen Recommendation? (Adds a little checkmark?)
	/*Recommendations are checked every paycheck, bonus credit that is outstanding (not 0) will be paid out*/

/datum/ntprofile/proc/add_employeerecord(var/recommaker, var/note, var/recomscore, var/warrantspromotion, var/paybonuspercent, var/paybonuscredit, var/nanotrasen)
	if(recommaker && note) //The 2 main dawgs
//		var/mob/living/carbon/human/Maker = recommaker
		var/datum/ntprofile/employeerecord/record = new() //Initialize the record.
		if(record)
			record.maker = recommaker
			record.note = note
			record.recomscore = recomscore
			record.warrantspromotion = warrantspromotion
			record.paybonuspercent = paybonuspercent
			record.paybonuscredit = paybonuscredit
			record.nanotrasen = nanotrasen
			record.time = "[stationdate2text()]-[time2text()]"

			for(var/datum/ntprofile/employeerecord/R in employee_records)
				if(R.note == record.note) // Assuming it is a double.
					return
			LAZYINITLIST(employee_records)
			employee_records.Add(record)
			load_score() //Re-load the score, reset the average.

/datum/ntprofile/proc/display_employeerecords() //Displays all records.
	. = list()
	for(var/datum/ntprofile/employeerecord/R in employee_records)
		. += "<b>[R.nanotrasen ? "OFFICIAL " : ""]RECORD| </b>[R.maker]: [R.note] ([R.recomscore])"
	return .
/*		if(nanotrasen)
			employee_records.Add("NOTE: NanoTrasen (OFFICIAL) -- [note] (S: [recomscore]")
			calculate_bonus_credit(owner, paybonuscredit, paybonuspercent)
		else
			employee_records.Add("NOTE: [Maker] ([Maker.job]) -- [note] (S: [recomscore]")
			calculate_bonus_credit(owner, paybonuscredit, paybonuspercent)
*/
/*
/datum/ntprofile/proc/add_recommendation(var/maker, var/reason)
	if(!maker || !reason)	return
	if(!recommendations)
		recommendations = list()
	recommendations.Add(name = "[maker]", reason = "[reason]")
*/