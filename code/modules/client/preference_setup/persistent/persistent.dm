//A small panel giving info about the character's persistency info.
//Saves nothing, only loads the clients mobs CharRecords prematurely.
/datum/preferences
	var/char_department = SRV
	var/department_playtime = 0
	var/department_rank = 0
/*-------CHARACTER-RELATED-------*/
	var/pension_balance = 0
	var/mentorship = 0 //Is this character a mentor for interns?
	var/bonuscredit = 0
	var/employeescore = 5 //Calculated at run-time.
	var/employedsince
	var/list/employee_records = list()
	var/list/nt_messages = list() //Basically a backlog of anything that happened. EG head request accepted.
	var/neurallaces = 0
	var/newcharinit = 0
	//BANKING/ATM
	var/datum/money_account/bank_account


/datum/category_item/player_setup_item/persistent
	name = "Character Details (Persistency)"
	sort_order = 1

/datum/category_item/player_setup_item/persistent/save_character(var/savefile/S)
	S["department_playtime"] << pref.department_playtime
	S["department_rank"] << pref.department_rank
	S["employedsince"] << pref.employedsince
	S["newcharinit"] << pref.newcharinit
	S["mentorship"] << pref.mentorship
	S["neurallaces"] << pref.neurallaces
	S["bank_account"] << pref.bank_account
	S["employee_records"] << pref.employee_records
	S["bonuscredit"] << pref.bonuscredit
	S["char_department"] << pref.char_department

/datum/category_item/player_setup_item/persistent/load_character(var/savefile/S)
	S["department_playtime"] >> pref.department_playtime
	S["department_rank"] >> pref.department_rank
	S["employedsince"] >> pref.employedsince
	S["newcharinit"] >> pref.newcharinit
	S["mentorship"] >> pref.mentorship
	S["neurallaces"] >> pref.neurallaces
	S["bank_account"] >> pref.bank_account
	S["employee_records"] >> pref.employee_records
	S["bonuscredit"] >> pref.bonuscredit
	S["char_department"] >> pref.char_department

	if(isnull(pref.char_department))
		pref.char_department = initial(pref.char_department)
		to_chat(pref.client, "<span class='warning'>ERR: Something went wrong with fetching department, please contact a Administrator!</span>")
		to_chat(pref.client, "<span class='warning'>^ Unlocked your character to allow reselection of proper department.</span>")
		pref.char_lock = 0

	if(pref.bank_account)
		var/datum/transaction/T = pref.bank_account.transaction_log[1]
		if(!T || isnull(T))
			T = new()
			T.target_name = pref.real_name
			T.purpose = "Account creation"
			//set a random date, time and location some time over the past few decades
			T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
			T.time = "[rand(0,24)]:[rand(11,59)]"
			T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"
		if(!isnull(pref.bank_account.account_number))
			pref.bank_account.owner_name = pref.real_name
			return 1 //All is good.
	else
		var/datum/money_account/M = new(pref.bank_account)
		M.owner_name = pref.real_name
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
			T.target_name = pref.real_name
			T.purpose = "Account creation"
			//set a random date, time and location some time over the past few decades
			T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
			T.time = "[rand(0,24)]:[rand(11,59)]"
			T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		//add the account
		M.transaction_log.Add(T)
		if(M != pref.bank_account)
			pref.bank_account = M

	S["bank_account"] << pref.bank_account //Save new bank account for future use.
	for(var/datum/money_account/MA in bank_accounts)
		if(MA.account_number == pref.bank_account.account_number)
			if(MA != pref.bank_account)
				del(MA)

	pref.bank_account.check_savings()

	if(pref.isnewchar())
//		usr.CharRecords.add_employeerecord("NanoTrasen", "Beginning of Employment in [get_department(pref.char_department, 1)] Dept.", 5, 0, 0, 250, 1)
//		pref.employeescore = 5 //Default.
		pref.char_department = initial(pref.char_department)
		pref.bank_account.bank_balance = rand(50, 250)
		pref.pension_balance = rand(50, 500)
		if(!pref.employedsince)	pref.employedsince = "[stationdate2text()]"
		to_chat(usr, "{*} First time character detected, enjoy your department! (Initializations complete.)")
		S["newcharinit"] << 1
		S["employedsince"] << pref.employedsince

	S.Flush() //Make sure bank account is carried over.

/datum/category_item/player_setup_item/persistent/content()
	. = list()
	. += "<b>NT Profile: [pref.real_name]</b><br>"
//	var/rank = get_department_rank_title(get_department(pref.char_department, 1), NTP.department_rank, ishead)
//	if(!rank)	rank = "No Special Title (Regular)"
	. += {"
	<b>Status:</b> [pref.char_dead ? "Deceased ([round((world.realtime - pref.char_deadsince) / 864000, 0.1)]) Days Ago." : "Active"]
	<b>Age:</b> [pref.age]<br>
	<b>Start date employment:</b> [pref.employedsince]<br>
	<b>Worked Hours:</b> [round(pref.department_playtime/60, 0.1)] Hours.<br>
	<b>Department:</b> [get_department(pref.char_department, 1)]<br>
	<b>Rank (Title):</b> (Can't Locate Rank yet!) ([pref.department_rank])<br>
	"}
	. += "<b>Employment Standing:</b> "
	switch(pref.promoted)
		if(JOB_LEVEL_INTERN)
			. += "Internship Program"
		if(JOB_LEVEL_REGULAR)
			. += "Regular Work Contract"
		if(JOB_LEVEL_SENIOR)
			. += "Senior Employee"
		if(JOB_LEVEL_HEAD)
			. += "Commanding Officer"
	if(pref.permadeath)
		. += " (External Insurance)|<i>(Perma-death enabled)</i><br>"
	else
		. += " (Employee Insurance)|<i>(Perma-death disabled)</i><br>"

	. += "<br>"
	if(pref.bank_account)
		. += {"
		<hr>
		<b><h3>Financials:</h3></b><br>
		<b>Bank Account:</b> $[pref.bank_account.bank_balance ? "[pref.bank_account.bank_balance]" : "0"] | (Open Bonus Credit: $[pref.bonuscredit ? "[pref.bonuscredit]" : "0"])<br>
		<b>Pension Account:</b> $[pref.pension_balance ? "[pref.pension_balance]" : "0"]<br>
		"}
	else
		. += {"
		<hr>
		<b><h3>Financials:</h3></b><br>
		<b>No Financial Information availible right now. (Spawn once first!)</b><br>
		"}
	. = jointext(.,null)