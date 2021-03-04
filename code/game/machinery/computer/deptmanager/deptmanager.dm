/obj/machinery/computer/department_manager
	name = "Department Management Console"
	desc = "Used to view, edit and maintain department-related business."
	icon_keyboard = "security_key"
	icon_screen = "security"
	light_color = "#a91515"
	req_one_access = list(access_heads)
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/department = "NanoTrasen"
	var/screen = 1 //Main screen always
	var/mob/living/carbon/human/profiled
	var/datum/browser/popup
	var/mob/living/carbon/human/idowner
	var/mob/living/carbon/human/DeptHead
	var/employeecount = 0
	var/changedrecord = 0
	var/next_run = 0
	var/obj/item/device/pda/DeptPDA
	var/list/employeephotos = list() //This is quite hacky, but I am unsure how to properly do this otherwise without turning pictures into webcams..
//	var/list/dispatches[5] //A list that keeps the last 5 dispatches

/obj/machinery/computer/department_manager/Initialize()
	. = ..()
	load_requests()
	InitializePDA()
	if(department == "Logistics")
		req_one_access.Add(access_qm)

/obj/machinery/computer/department_manager/proc/InitializePDA()
	DeptPDA = new(src)
	DeptPDA.owner = "[department]"
	DeptPDA.name = "[department] PDA Alert System"
	DeptPDA.message_silent = 1
	DeptPDA.news_silent = 1
	DeptPDA.hidden = 1
	DeptPDA.ownjob = "[department] PDA Alert System"

/obj/machinery/computer/department_manager/proc/send_pda_message(var/globally = 0, var/message as text, var/mob/living/M)
	if(!message)	return
	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner || P.toff || P.hidden)	continue
		if(globally)
			if(department == "NanoTrasen")//Global NT Announcement to all PDAs
				if(!isnull(P))
					GLOB.message_servers[1].send_pda_message("[P.owner]", "[DeptPDA.owner]","[message]")
	//				P.new_message(DeptPDA, "NanoTrasen Administration.", "NanoTrasen", message)
					DeptPDA.tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[message]", "target" = "\ref[P]")))
					P.tnote.Add(list(list("sent" = 0, "owner" = "[DeptPDA.owner]", "job" = "[DeptPDA.ownjob]", "message" = "[message]", "target" = "\ref[DeptPDA]")))
				if(!DeptPDA.conversations.Find("\ref[P]"))
					DeptPDA.conversations.Add("\ref[P]")
				if(!P.conversations.Find("\ref[DeptPDA]"))
					P.conversations.Add("\ref[DeptPDA]")
				P.new_message_from_pda(DeptPDA, message)
				if (!P.message_silent)
					playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
			else
				if(!isnull(P))
					if(P.cartridge && P.cartridge.department == department) //Same department as console..
						GLOB.message_servers[1].send_pda_message("[P.owner]", "[DeptPDA.owner]","[message]")
		//				P.new_message(DeptPDA, "NanoTrasen Administration.", "NanoTrasen", message)
						DeptPDA.tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[message]", "target" = "\ref[P]")))
						P.tnote.Add(list(list("sent" = 0, "owner" = "[DeptPDA.owner]", "job" = "[DeptPDA.ownjob]", "message" = "[message]", "target" = "\ref[DeptPDA]")))
						if(!DeptPDA.conversations.Find("\ref[P]"))
							DeptPDA.conversations.Add("\ref[P]")
						if(!P.conversations.Find("\ref[DeptPDA]"))
							P.conversations.Add("\ref[DeptPDA]")
							P.new_message_from_pda(DeptPDA, message)
						if (!P.message_silent)
							playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
		else if(M && P.owner == M.real_name)
			//Private PDA message through console.
			if(!isnull(P))
				GLOB.message_servers[1].send_pda_message("[P.owner]", "[DeptPDA.owner]","[message]")
//				P.new_message(DeptPDA, "NanoTrasen Administration.", "NanoTrasen", message)
				DeptPDA.tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[message]", "target" = "\ref[P]")))
				P.tnote.Add(list(list("sent" = 0, "owner" = "[DeptPDA.owner]", "job" = "[DeptPDA.ownjob]", "message" = "[message]", "target" = "\ref[DeptPDA]")))
			if(!DeptPDA.conversations.Find("\ref[P]"))
				DeptPDA.conversations.Add("\ref[P]")
			if(!P.conversations.Find("\ref[DeptPDA]"))
				P.conversations.Add("\ref[DeptPDA]")
			P.new_message_from_pda(DeptPDA, message)
			if (!P.message_silent)
				playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)

/obj/machinery/computer/department_manager/Process()
	if(world.time < next_run + 10 SECONDS)
		return
	next_run = world.time

	employeecount = 0
	for(var/mob/living/carbon/human/M in GLOB.player_list)
		if(M.CharRecords && M.client.prefs.char_department == get_department(department, 0) || M.job && department == "NanoTrasen") //They belong to the manager
			employeecount++
			var/icon/charicon = cached_character_icon(M)
			var/icon/Front = icon(charicon, dir = SOUTH)

			if(Front)
				employeephotos["[M.ckey]"] = Front //Saves the photo per client so we can easily retrieve it.

//	if(!DeptRequests && department == "NanoTrasen")
//		DeptRequests = new("data/ntrequests.sav")
//	load_requests()


/obj/machinery/computer/department_manager/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying)	return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		if(!usr.get_active_hand() && ishuman(usr))
			usr.put_in_hands(scan)
		else
			scan.dropInto(loc)
		scan = null
		idowner = null
		profiled = null
		screen = 1
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/computer/department_manager/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.forceMove(src)
		scan = O
		to_chat(user, "You insert [O].")
	else
		..()

/obj/machinery/computer/department_manager/attack_ai(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/department_manager/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact(user)
	user.set_machine(src)

/obj/machinery/computer/department_manager/ui_interact(user)
	..()
	var/dat
	if(authenticated)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.client.prefs.char_department == department)
				DeptHead = H
		switch(screen)
			if(1)
				var/datum/money_account/DACC = department_accounts[department]
				dat = {"
						<html>
						<head>
						<title>[department] Management Console</title>
						</head>
						<body>
						<b>Department:</b> [department]<br>
						<b>Employee Count:</b> [employeecount] Employees<br>
						<hr>
						<h3>Financial Information (Current Shift)</h3>
						<b>Current Balance: $[DACC.bank_balance] Credits</b><br>
						<b>Total Earnings: $[DACC.round_earns] Credits</b><br>
						<b>Total Loss: $[DACC.round_loss] Credits</b><hr><br>
						<div font-size="medium">
						<a href='?src=\ref[src];choice=employeedb'>Employee Database</a>|
						<a href='?src=\ref[src];choice=finances'>Financial Manager <i>(Coming Soon!)</i></a>|
						<a href='?src=\ref[src];choice=alertsys'>PDA Alert System</a>|
						"}
// <a href='?src=\ref[src];choice=dispatch'>Dispatch</a>
				if(department == "NanoTrasen") //NT console
					dat += "<a href='?src=\ref[src];choice=ntpanel'>Administrative Requests ([pendingdeptrequests.len ? pendingdeptrequests.len : "N/A"])</a>"
				dat += "</div>"
			if(2)
				dat = "<ul>"
				for(var/mob/living/carbon/human/M in GLOB.player_list)
					if(M.client.prefs.char_department == get_department(department, 0) || department == "NanoTrasen")
						var/photo = employeephotos["[M.ckey]"]
						dat += {"<li><b>Name:</b> [M.real_name]<body><div class='right' style='float: right;'>Photo:<br><img src=[photo] height=64 width=64 border=4></div></body><br>
						<b>Age:</b> [M.age]<br>
						<b>Occupation:</b> [M.job]<br>
						<b>Occupation Experience: [get_department_rank_title(M, M.client.prefs.department_rank)]<br>
						<b>Clocked Hours:</b> [round(M.client.prefs.department_playtime/3600, 0.1)]<br>
						<b>Employee Grade:</b> [round(M.CharRecords.employeescore, 0.01)]<hr>
						"}
						if(M == user)
							dat += "<a href='?src=\ref[src];choice=Profile;profiled=\ref[M]'>No Editing Rights</a></li>"
						else
							dat += "<a href='?src=\ref[src];choice=Profile;profiled=\ref[M]'>Profile</a></li>"
				dat += "</ul></body></html>"
			if(2.1) //Character Employee Profile
				var/photo = employeephotos["[profiled.ckey]"]
				dat = {"
						<html>
						<head>
							<title>[department] Management Console</title>
						</head>
						<body>
						"}
				dat += {"
						<b>Name:</b> [profiled.real_name]<body><div class='right' style='float: right;'>Photo:<br><img src=[photo] height=64 width=64 border=4></div></body><br>
						<b>Age:</b> [profiled.age]<br>
						<b>Occupation:</b> [profiled.job]<br>
						<b>Occupation Rank: [get_department_rank_title(profiled, profiled.client.prefs.department_rank)]<br>
						<b>Clocked Hours:</b> [round(profiled.client.prefs.department_playtime/3600, 0.1)]<br>
						<b>Employee Grade:</b> [round(profiled.CharRecords.employeescore, 0.01)]<hr>
						<A href='?src=\ref[src];choice=records'>Employee Records</A><A href='?src=\ref[src];choice=promote'>Promote</A><A href='?src=\ref[src];choice=demote'>Demote</A><br>"}
				dat += "</body></html>"
			if(2.2) //Character Employee Records
				dat = {"
				<html>
				<body>
				<b>[profiled.real_name] Character records:</b>
				"}
				dat += "<table>"
				dat += {"<tr><th>Time</th>
				<th>Official</th>
				<th>Record Creator</th>
				<th>Record</th>
				<th>Record Score</th>
				</tr>"}
				for(var/datum/ntprofile/employeerecord/R in profiled.CharRecords.employee_records)
					dat += "<tr><td>[R.time]</td>"
					dat += "<td>[R.nanotrasen ? "OFFICIAL " : ""]</td>"
					dat += "<td>[R.maker]</td>"
					dat += "<td>[R.note]</td>"
					dat += "<td>[R.recomscore ? R.recomscore : "None"]</td></tr>"
				dat += "</table>"
				dat += "<A href='?src=\ref[src];choice=addrecord'>Add Record</A>"
				dat += {"
				</html>
				</body>
				"}
			if(3)
				dat += "ERROR: Server undergoing routine maintenance, check back later. ((WIP))"
				dat += "<A href='?src=\ref[src];choice=return'>Return</A>"
				return //Nothin yet son!
			if(4)
				if(department == "NanoTrasen")
					dat = {"
					<html>
					<body>
					<h3>Administrative Section</h3><br>
					<i>(Beware, changes are permanent, only authorized personnel allowed!)</i>
					<hr>
					"}
					dat += "<ul>"
					dat += "<br><b>Availible Requests</b><hr>"
					for(var/datum/ntrequest/N in pendingdeptrequests)
						var/buttons = "<br><a href='?src=\ref[src];choice=reqaccept;requested=\ref[N]'>Accept</a><a href='?src=\ref[src];choice=reqdeny;requested=\ref[N]'>Deny</a><a href='?src=\ref[src];choice=reqdel;requested=\ref[N]'>Del</a>"
						dat += "<li><font color='green'>REQUEST-#[N.requestinfo["requestid"]]<b></font>|[N.requestinfo["time"]]|</b>[N.requestinfo["requesttype"]], FROM [N.requestinfo["fromchar"]] TO [N.requestinfo["tochar"]] FOR [N.requestinfo["requesttext"]]. [buttons]</li><br>"
					dat += {"
					</ul>
					</html>
					</body>
					"}
			if(5)
				dat = {"
				<html>
				<body>
				<h3>Department Alert System</h3>
				<hr><br>
				"}
				dat += {"
				<b>Communication Options:</b><br>
				<A href='?src=\ref[src];choice=pdamsg'>Send PDA Message (Directly/Globally)</A>
				<hr>
				"}
//	<A href='?src=\ref[src];choice=dispatch'>Send Dispatch (To department)</A>
/*				dat += {"
				<table><tr><th>Last Dispatches Recieved</th></tr>
				<tr><td>[dispatches.len ? dd_list2text(dispatches) : "No recent dispatches."]</td></tr>
				</table>
				</html>
				</body>
				"}
*/
				dat += {"
				</html>
				</body>
				"}

		dat += "<A href='?src=\ref[src];choice=return'>Return</A> <A href='?src=\ref[src];choice=Log Out'>Log Out</A>"
	else
		dat += "<b>Department:</b> [department]<br><b>Employee Count:</b> [employeecount]<br><hr><center><i>"
		if(scan && authenticated)
			dat += "Authenticated: [scan.assignment] [scan.registered_name]"
		else
			dat += "Authentication Required: Insert ID<br> <A href='?src=\ref[src];choice=Log In'>Log In</A></center>"
		dat += "</center></i>"
	popup = new(user, "dept_console", "[department] Management Console", 480, 520)
	popup.add_stylesheet("dept_console", 'html/browser/department_management_console.css')
	popup.set_content(jointext(dat, null))
	popup.open()
	return


/obj/machinery/computer/department_manager/proc/Save_Changes()
	if(profiled && changedrecord)
		if(profiled.client.prefs.save_character()) //If succeeded..
			changedrecord = 0
		else
			world.log << "ERROR: We couldn't save persistent info for [profiled] ([profiled.CharRecords]"

//PS; H(uman) is optional.
/obj/machinery/computer/department_manager/proc/Ping(var/text, var/globping, var/mob/living/carbon/human/H) //Pings the console, pings the PDA. Global to 0 is head gets notified.
	if(text)
		if(globping) //Globally Ping everyone
			send_pda_message(1, text)
		else
			if(!H && DeptHead)
				send_pda_message(0, text, DeptHead)
			else
				send_pda_message(0, text, H)
		ping(text)