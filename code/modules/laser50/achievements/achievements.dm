// Already defined in playerinfo.dm
// /client
//	 var/list/achievements

/*Achievement layout:
ac_name-ac_desc-ac_icon in text form
*/

/datum/achievements
	var/ac_name = "" //Achievement Name
	var/ac_desc = "" //Achievement Desc
	var/icon/ac_icon = null //Achievement icon, WIP.

/datum/achievements/proc/passed_achievement(var/client/C)
	if(locate(src.type) in C.achievements)
		return 0 //Already have it bro.
	if(!..()) //If returns 0, they didn't get it.
		return 0
	else
		return 1 //If returns 1, they passed!

/client/proc/set_achievement(var/datum/achievements/AC)
	if(AC.passed_achievement())
		achievements.Add(AC)
		to_chat(usr, "<b>Achievement Unlocked:</b> [AC.ac_name]!")

/client/proc/ListAchievements() //Note; Turn into HTML screen.
	var/list/achiefs = list()
	for(var/datum/achievements/AC in achievements)
		achiefs.Add("[AC.ac_icon ? "\icon[AC.ac_icon]" : "*"] <b>[AC.ac_name]</b> -- <i>[AC.ac_desc]</i>")
	if(achiefs.len)
		return achiefs

/datum/achievements/firsttime
	ac_name = "Welcome Aboard Apollo!"
	ac_desc = "First time joining the server!"

/datum/achievements/firsttime/passed_achievement(var/client/C)
	if(C.get_player_age() < 0.1)
		return 1

/datum/achievements/firstdeath
	ac_name = "'Work Hazard'"
	ac_desc = "Dying for the first time"

/datum/achievements/firstdeath/passed_achievement(var/mob/M)
	if(M.stat == 2)
		return 1

/datum/achievements/airlockshock
	ac_name = "A shocking discovery!"
	ac_desc = "Getting electrocuted by an airlock.. Ouch"