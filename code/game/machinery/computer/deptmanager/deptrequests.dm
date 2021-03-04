var/global/savefile/DeptRequests = new("data/ntrequests.sav")
var/global/list/pendingdeptrequests = list()

/datum/ntrequest
	var/list/requestinfo = list(
		"requestid" = "",
		"requesttype" = "",
		"requesttext" = "",
		"fromchar" = "",
		"tochar" = "",
		"tocharkey" = "",
		"score" = 0,
		"time" = ""
	)
//	var/requestid
//	var/requesttype = "" //Demotion, Promotion, Raise pay, Cut pay, bonus and Record.
//	var/requesttext = ""
//	var/fromchar
//	var/tochar
//	var/ckey
//	var/real_name
//	var/score = 0 //Added to make sure score is saved.
//	var/time = ""


/datum/ntrequest/New()
	requestinfo["requestid"] = rand(0, 1000) //Basically 1000 requests per time.

/datum/ntrequest/proc/make_request(var/obj/machinery/computer/department_manager/DM, var/requesttype2, var/mob/living/carbon/human/fchar, var/mob/living/carbon/human/tchar, var/requesttext2, var/score2)
	if(!DM)	return 0 //No can do.
	for(var/datum/ntrequest/Request in pendingdeptrequests)
		if(Request.requestinfo["requesttype"] == requestinfo["requesttype"] && requestinfo["requesttype"] == "promotion" || requestinfo["requesttype"] == "demotion" || requestinfo["requesttype"] == "bonus")
			return to_chat(usr, "Similar request already found in database, please await answer.")
		if(Request.requestinfo["requestid"] == requestinfo["requestid"]) //Also no duplicate IDs, just to be safe.
			requestinfo["requestid"] = rand(0, 1000) //So we reset and hope.
	requestinfo["requesttype"] = requesttype2
	requestinfo["requesttext"] = requesttext2
	requestinfo["fromchar"] = "[get_department_rank_title(fchar, fchar.client.prefs.department_rank)] [fchar.job] [fchar.real_name]"
	requestinfo["tochar"] = "[get_department_rank_title(tchar, tchar.client.prefs.department_rank)] [tchar.job] [tchar.real_name]"
	requestinfo["tocharkey"] = tchar.ckey
	requestinfo["score"] = score2
	requestinfo["time"] = "[stationdate2text()]-[time2text()]"


	pendingdeptrequests.Add(src) // "REQUEST|[requesttype], Sent by [fromchar:job] [fromchar:real_name], Sent to [tochar:job] [tochar:real_name] For [requesttext]"
	DM.save_requests()

/obj/machinery/computer/department_manager/proc/save_requests()
	LAZYINITLIST(pendingdeptrequests)
	DeptRequests["pendinglist"] << pendingdeptrequests
	return 1

/obj/machinery/computer/department_manager/proc/load_requests()
	var/list/newrequests = list()
	DeptRequests["pendinglist"] >> newrequests
	LAZYDISTINCTADD(pendingdeptrequests, newrequests)
	return 1