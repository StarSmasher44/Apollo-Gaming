/obj/machinery/computer/department_manager/Topic(href, href_list)
//	..()
	if ((usr.contents.Find(src) || (in_range(src, usr) && isturf(loc))) || (issilicon(usr)))
		usr.set_machine(src)

		switch(href_list["choice"])
			if("Log Out")
				authenticated = null
				if(!usr.get_active_hand() && ishuman(usr))
					usr.put_in_hands(scan)
				else
					scan.dropInto(loc)
				scan = null
				idowner = null
				profiled = null
				screen = 1
			if("Log In")
				if (istype(scan, /obj/item/weapon/card/id))
					if(check_access(scan))
						authenticated = scan.registered_name
						if(ishuman(usr))
							src.idowner = usr
							screen = 1
			if("employeedb")
				screen = 2
			if("finances")
				screen = 3
			if("ntpanel")
				screen = 4
			if("alertsys")
				screen = 5
			if("promdemote")
				screen = 2.4
			if("return")
				switch(screen)
					if(2)
						screen = 1
					if(2.1)
						screen = 2
					if(2.2 || 2.3 || 2.4)
						screen = 2.1
					if(3)
						screen = 1
					if(4)
						screen = 1
					if(5)
						screen = 1
			if("pdamsg")
				switch(alert("Send Global(department) or direct message?", "Department PDA Messaging System", "Global","Direct","Cancel"))
					if("Global")
						var/Message = input("Please enter message to send", "Department PDA Messaging System")
						if(Message)
							send_pda_message(1, Message)
							ping("Global PDA Message sent.")
					if("Direct")
						var/list/canmessage = list()
						for(var/mob/living/carbon/human/M in GLOB.player_list)
							if(get_department(M.client.prefs.char_department) == department)
								canmessage.Add(M)
						if(canmessage)
							var/mob/living/carbon/human/Target = input("Select Employee to message", "Department PDA Messaging System") in canmessage
							var/Message = input("Please enter message to send", "Department PDA Messaging System")
							if(Target && Message)
								send_pda_message(0, Target, Message)
								ping("PDA Message sent to [Target].")
/*
			if("dispatch")
				var/dept = input("Please select department", "Dispatch Request") in list("Command", "Security", "Engineering", "Medical", "Science")
				var/message = input("Please state reason for dispatch", "Dispatch Request") as text
				if(dept && message)
					for(var/obj/machinery/computer/department_manager/DM in SSmachines)
						if(DM.department == dept && src != DM)
							DM.dispatches.Add("DISPATCH: [src.department]([idowner.job] [idowner.real_name]) requesting [DM.department] for [message]")
							Ping("DISPATCH: [src.department]([idowner.job] [idowner.real_name]) requesting [DM.department] for [message]", 1)
					ping("Dispatch request send.")
*/
			if("Profile")
				profiled = locate(href_list["profiled"])
				if(!profiled)	return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
				screen = 2.1
				popup.update()
/*--------------PROFILE BUTTONS--------------*/
			if("records")
				if(!profiled)	return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
				screen = 2.2
			if("addrecord")
				if(!profiled)	return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
				if(profiled.client.prefs.char_department != "Command" || profiled.job == "Captain" || profiled.client.prefs.promoted == JOB_LEVEL_HEAD) //Can't see your bosses, Captain or Heads.
					to_chat(usr, "Leave blank to cancel.")
					var/record = input("Insert Record:", "Record Management - Department Management")
					var/score = input("Insert record score (1-10) for the employee rating.", "Record Management - Department Management") as num
					if(!record)	return
					if(!score || score > 10 || score < 0)	score = 0
					var/datum/ntrequest/NR = new()
					NR.make_request(src, "record", idowner, profiled, record, score)
					ping("Request has been submitted to NT Administration.")
				changedrecord = 1
			if("promote")
				if(!profiled)	return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
				switch(alert("Promote [profiled.real_name] to a Senior- or Head Position?", "Promotion Screen", "Senior Position", "Head Position"))
					if("Head Position")
						if(department == "Command" && idowner.job == "Captain" || department == "NanoTrasen") //Captain can promote to head.
							if(calculate_department_rank(profiled) < 3 && department != "NanoTrasen")
								to_chat(usr, "[profiled.real_name]'s rank is insufficient to allow for a promotion.")
								return
							var/record = input("Insert Reason/Record:", "Promotion Management - Department Management")
							var/datum/ntrequest/NR = new()
							NR.make_request(src, "promote",idowner, profiled, record)
							to_chat(usr, "Request has been sent to NanoTrasen for review.")
					if("Senior Position")
						if(calculate_department_rank(profiled) < 3)
							to_chat(usr, "[profiled.real_name]'s rank is insufficient to allow for a promotion.")
							return
						else if(profiled.CharRecords.employeescore < 7)
							to_chat(usr, "[profiled.real_name]'s employee score is insufficient to allow for a promotion. (Minimum of 7 required)")
							return
						else if(profiled.client.prefs.promoted == JOB_LEVEL_SENIOR)
							to_chat(usr, "[profiled.real_name] is already promoted!")
							return
						else
							var/record = input("Insert Reason/Record:", "Promotion Management - Department Management")
//							var/score = input("Insert record score (1-10) for the employee rating.", "Record Management - Department Management") as num
							profiled.CharRecords.add_employeerecord(idowner.real_name, record, 0, 0, 0, 0)
							profiled.client.prefs.promoted = JOB_LEVEL_SENIOR
							calculate_department_rank(profiled) //Re-calculate to set proper rank.
							to_chat(usr, "Promotion complete.")
				changedrecord = 1
			if("demote")
				if(!profiled)	return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
				switch(alert("demote [profiled.real_name] from Senior- or Head Position?", "Promotion Screen", "Senior Position", "Head Position"))
					if("Head Position")
						if(department == "Command" && idowner.job == "Captain" || department == "NanoTrasen") //Captain can demote from head.
							var/record = input("Insert Reason/Record:", "Promotion Management - Department Management")
							if(!record)	return
							var/datum/ntrequest/NR = new()
							NR.make_request(src, "demote", idowner, profiled, record)
							profiled.CharRecords.add_employeerecord(idowner.real_name, record, 0, 0, 0, 0)
							to_chat(usr, "Request has been sent to NanoTrasen for review.")
					if("Senior Position")
						if(profiled.client.prefs.promoted == 0)
							to_chat(usr, "[profiled.real_name] is not a senior employee!")
							return
						else
							var/record = input("Insert Reason/Record:", "Demotion Management - Department Management")
							profiled.CharRecords.add_employeerecord(idowner.real_name, record, 0, 0, 0, 0)
							profiled.client.prefs.promoted = 0
							calculate_department_rank(profiled) //Re-calculate to set proper rank.
							to_chat(usr, "Demotion complete.")
				changedrecord = 1
			if("reqaccept")
				var/datum/ntrequest/N = locate(href_list["requested"])
				if(!N || !istype(N))
					world.log << "No NT request found, or wrong type."
					return 0
				var/rckey = N.requestinfo["tocharkey"]
				var/savefile/S = new /savefile("data/player_saves/[copytext(rckey,1,2)]/[rckey]/preferences.sav")
				if(!S)					return 0
				var/default_slot = S["default_slot"]
				S.cd = GLOB.using_map.character_save_path(default_slot)
				var/client/CUser //IF the client is online though, we best use that.
				for(var/client/C in GLOB.clients)
					if(C.ckey == rckey)
						CUser = C
				switch(alert("Are you sure you wish to accept?", "Pending requests", "Cancel", "Accept Request"))
					if("Cancel")
						return
					if("Accept Request")
						var/promoted = S["promotion"] //Fetched promoted variable from save.
						switch(N.requestinfo["requesttype"])
							if("record")
								if(CUser && CUser.mob && ishuman(CUser.mob))
									var/mob/living/carbon/human/H = CUser.mob
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (ACCEPTED)", N.requestinfo["score"], 0, 0, 0, 0)
									S["employee_records"] << records
									changedrecord = 1
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (ACCEPTED)"
									ER.recomscore = N.requestinfo["score"]
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								del(N)
							if("promote")
								if(!promoted) //No can do..?
									pendingdeptrequests.Remove(N) //Remove from system after all is applied.
									del(N)
									return
								else if(promoted == JOB_LEVEL_SENIOR)
									if(CUser && CUser.mob && ishuman(CUser.mob))
										var/mob/living/carbon/human/H = CUser.mob
										H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (ACCEPTED)", N.requestinfo["score"], 0, 10, 0, 0)
										S["promotion"] << JOB_LEVEL_HEAD
										changedrecord = 1
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (ACCEPTED)"
									ER.recomscore = N.requestinfo["score"]
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
									S["promotion"] << JOB_LEVEL_HEAD
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								del(N)
							if("demote")
								if(!promoted) //No can do..?
									pendingdeptrequests.Remove(N) //Remove from system after all is applied.
									del(N)
									return
								if(CUser && CUser.mob && ishuman(CUser.mob))
									var/mob/living/carbon/human/H = CUser.mob
									H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (ACCEPTED)", N.requestinfo["score"], 0, 0, 0, 0)
									switch(promoted)
										if(JOB_LEVEL_SENIOR) //Promoted to Senior
											S["promotion"] << JOB_LEVEL_REGULAR //Back down yee!
										if(JOB_LEVEL_HEAD) //Promoted to Head.
											S["promotion"] << JOB_LEVEL_SENIOR //Back down yee!
									changedrecord = 1
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (ACCEPTED)"
									ER.recomscore = N.requestinfo["score"]
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
								switch(promoted)
									if(JOB_LEVEL_SENIOR) //Promoted to Senior
										S["promotion"] << JOB_LEVEL_REGULAR //Back down yee!
									if(JOB_LEVEL_HEAD) //Promoted to Head.
										S["promotion"] << JOB_LEVEL_SENIOR //Back down yee!
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								del(N)
								save_requests()
								updateUsrDialog()
								return
			if("reqdeny")
				var/datum/ntrequest/N = locate(href_list["requested"])
				if(!N || !istype(N))
					world.log << "No NT request found, or wrong type."
					return 0
				var/rckey = N.requestinfo["tocharkey"]
				var/savefile/S = new /savefile("data/player_saves/[copytext(rckey,1,2)]/[rckey]/preferences.sav")
				if(!S)					return 0
				var/default_slot = S["default_slot"]
				S.cd = GLOB.using_map.character_save_path(default_slot)
				var/client/CUser //IF the client is online though, we best use that.
				for(var/client/C in GLOB.clients)
					if(C.ckey == N.requestinfo["tocharckey"])
						CUser = C
				switch(alert("Are you sure you wish to deny?", "Pending requests", "Cancel", "Deny Request"))
					if("Cancel")
						return
					if("Deny Request")
						switch(N.requestinfo["requesttype"])
							if("record")
								if(CUser && CUser.mob && ishuman(CUser.mob))
									var/mob/living/carbon/human/H = CUser.mob
									H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (DENIED)", N.requestinfo["score"], 0, 0, 0, 0)
									changedrecord = 1
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (DENIED)"
									ER.recomscore = N.requestinfo["score"]
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								qdel(N)
							if("promote")
								if(CUser && CUser.mob && ishuman(CUser.mob))
									var/mob/living/carbon/human/H = CUser.mob
									H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (DENIED)", N.requestinfo["score"], 0, 0, 0, 0)
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (DENIED)"
									ER.recomscore = N.requestinfo["score"]
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								qdel(N)
							if("demote")
								var/promoted = S["promotion"]
								if(!promoted) //No can do..?
									pendingdeptrequests.Remove(N) //Remove from system after all is applied.
									qdel(N)
									return
								if(CUser && CUser.mob && ishuman(CUser.mob))
									var/mob/living/carbon/human/H = CUser.mob
									H.CharRecords.add_employeerecord(N.requestinfo["fromchar"],"[N.requestinfo["requesttext"]] (DENIED)", N.requestinfo["score"], 0, -10, 0, 0)
									changedrecord = 1
								else
									var/list/records = S["employee_records"]
									LAZYINITLIST(records)
									var/datum/ntprofile/employeerecord/ER = new
									ER.maker = N.requestinfo["fromchar"]
									ER.note = "[N.requestinfo["requesttext"]] (DENIED)"
									ER.recomscore = N.requestinfo["score"]
									ER.paybonuspercent = -10
									ER.time = "[stationdate2text()]-[time2text()]"
									records.Add(ER)
									S["employee_records"] << records
								switch(promoted)
									if(JOB_LEVEL_SENIOR) //Promoted to Senior
										promoted = JOB_LEVEL_REGULAR //Back down yee!
									if(JOB_LEVEL_HEAD) //Promoted to Head.
										promoted = JOB_LEVEL_SENIOR //Back down yee!
								S["promotion"] << promoted
								pendingdeptrequests.Remove(N) //Remove from system after all is applied.
								qdel(N)
								save_requests()
								updateUsrDialog()
			if("reqdel")
				var/datum/ntrequest/N = locate(href_list["requested"])
				switch(alert("Are you sure you wish to delete?", "Pending requests", "Cancel", "Delete Request"))
					if("Cancel")
						return
					if("Delete Request")
						pendingdeptrequests.Remove(N) //Remove from system after all is applied.
						qdel(N)
						save_requests()

		Save_Changes()
	add_fingerprint(usr)
//	popup.update()
	updateUsrDialog()
	return