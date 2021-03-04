/*=============EXTRA NOTES=============
- There are 2 variables that save the department; client.prefs.prefs_department and (human)mob.CharRecords.char_department
^ Both mut be set properly, or things break.
=====================================*/
/datum/ntprofile
/*-------DEPARTMENT-RELATED-------*/
#warn MOVED PLAYTIME AND RANK (DEPT) TO PREFS FOR TESTS
	var/tmp/mob/living/carbon/human/owner
	var/employeescore = 5 //Calculated at run-time.
	var/list/employee_records = list()
	var/list/nt_messages = list() //Basically a backlog of anything that happened. EG head request accepted.
/*--------OTHER-RELATED--------*/

/datum/ntprofile/New(var/mob/M, var/client)
	if(M)
		owner = M
		Load_Profile(M)

/datum/ntprofile/proc/Load_Profile() //Init the profile.. Human set as owner.
	if(nt_messages.len) //Returns the backlog of messages.
		for(var/A in nt_messages)
			PersistentSys.SendPDAMessage(owner, A)
			A -= nt_messages

/datum/ntprofile/proc/load_score()
	if(!owner || !owner.client.prefs.employee_records)	return 5
	var/totalscore = 0
	var/counter = 0
	for(var/datum/ntprofile/employeerecord/N in owner.client.prefs.employee_records)
		totalscore += N.recomscore
		counter++
	if(totalscore && counter)
		employeescore = totalscore/counter
	else
		if(!totalscore || !counter)
			employeescore = 5 //Assuming new.
	return employeescore


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

			for(var/datum/ntprofile/employeerecord/R in owner.client.prefs.employee_records)
				if(R.note == record.note) // Assuming it is a double.
					return
			LAZYINITLIST(owner.client.prefs.employee_records)
			owner.client.prefs.employee_records.Add(record)
			load_score() //Re-load the score, reset the average.


/datum/ntprofile/proc/display_employeerecords() //Displays all records.
	. = list()
	for(var/datum/ntprofile/employeerecord/R in owner.client.prefs.employee_records)
		. += "<b>[R.nanotrasen ? "OFFICIAL " : ""]RECORD| </b>[R.maker]: [R.note] ([R.recomscore])"
	return .