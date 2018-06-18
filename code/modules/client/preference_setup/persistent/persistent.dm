//A small panel giving info about the character's persistency info.
//Saves nothing, only loads the clients mobs CharRecords prematurely.
/datum/preferences


/datum/category_item/player_setup_item/persistent
	name = "Character Details (Persistency)"
	sort_order = 1


/datum/category_item/player_setup_item/persistent/content()
	var/datum/ntprofile/NTP = fetch_charrecords(usr.client)
	var/ishead = 0
	if(pref.promoted >= JOB_LEVEL_HEAD)
		ishead = 1
	. = list()
	. += "<b>NT Profile: [pref.real_name]</b><br>"
	var/rank = get_department_rank_title(get_department(pref.char_department, 1), NTP.department_rank, ishead)
	if(!rank)	rank = "No Special Title (Regular)"
	. += {"
	<b>Status:</b> [pref.char_dead ? "Deceased ([round((world.realtime - pref.char_deadsince) / 864000, 0.1)]) Days Ago." : "Active"]
	<b>Age:</b> [pref.age]<br>
	<b>Start date employment:</b> [NTP.employedsince]<br>
	<b>Worked Hours:</b> [round(NTP.department_playtime/60, 0.1)] Hours.<br>
	<b>Department:</b> [get_department(pref.char_department, 1)]<br>
	<b>Rank (Title):</b> [rank] ([NTP.department_rank])<br>
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
	if(NTP.bank_account)
		. += {"
		<hr>
		<b><h3>Financials:</h3></b><br>
		<b>Bank Account:</b> $[NTP.bank_account.bank_balance ? "[NTP.bank_account.bank_balance]" : "0"] | (Open Bonus Credit: [NTP.bonuscredit ? "[NTP.bonuscredit]" : "None"])<br>
		<b>Pension Account:</b> $[NTP.pension_balance ? "[NTP.pension_balance]" : "0"]<br>
		"}
	else
		. += {"
		<hr>
		<b><h3>Financials:</h3></b><br>
		<b>No Financial Information availible right now. (Spawn once first!)</b><br>
		"}
	. = jointext(.,null)

/datum/category_item/player_setup_item/persistent/proc/fetch_charrecords(var/client/C)
	if(C)
		var/datum/ntprofile/NTP = new()
		NTP.owner = usr
		NTP.load_persistent()
		return NTP
/*
/datum/category_item/player_setup_item/persistent/OnTopic(href, href_list, user)
	if(href_list["skillinfo"])
		var/datum/skill/S = locate(href_list["skillinfo"])
		var/HTML = "<h2>[S.name][S.secondary ? "(secondary)" : ""]</h2>"
		HTML += "<b>Generic Description</b>: [S.desc]<br><br><b>Unskilled</b>: [S.desc_unskilled]<br>"
		if(!S.secondary)
			HTML += "<b>Amateur</b>: [S.desc_amateur]<br>"
		HTML += "<b>Trained</b>: [S.desc_trained]<br><b>Professional</b>: [S.desc_professional]"

		user << browse(HTML, "window=\ref[user]skillinfo")
		return TOPIC_HANDLED

	else if(href_list["setskill"])
		var/datum/skill/S = locate(href_list["setskill"])
		var/value = text2num(href_list["newvalue"])
		pref.skills[S.ID] = value
		pref.CalculateSkillPoints()
		return TOPIC_REFRESH

	return ..()
*/