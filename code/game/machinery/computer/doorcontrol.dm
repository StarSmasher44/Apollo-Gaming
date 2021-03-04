/obj/machinery/computer/doorcontrol
	name = "Door Control Panel"
	icon_state = "guest"
	icon_keyboard = null
	icon_screen = "pass"
	density = 0
	req_one_access = list() //List of ID accesses that can use this

	var/obj/item/weapon/card/id/controlid
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/announcement = "" //An announcement that can be set from the console.

	var/list/internal_log = list()
	var/list/connectedairlocks = list() //List of airlocks connected to this console.
	var/list/low_sec = list(access_security) //Low-sec functions like opening the door.
	var/list/high_sec = list(access_heads, access_armory) //Higher level functions like bolting and setting announcements
	var/obj/machinery/door/airlock/Selected = null //Empty reference.
	// To circumvent GC issues, we only save the \ref ID of the airlocks.
	var/mode = 0  // 0 - making pass, 1 - viewing logs
	var/locked = 1 // Is the console locked or not?

/obj/machinery/computer/doorcontrol/Initialize()
	. = ..()
	for(var/obj/machinery/door/airlock/AL in range(1))
		if(AL)
			connectedairlocks += AL
		for(var/obj/machinery/door/airlock/AL2 in range(AL, 4))
			if(AL2 != AL)
				if(AL.name == AL2.name)
					connectedairlocks += AL2
//			for(var/direction in GLOB.cardinal)
//				var/obj/machinery/door/airlock/AL2 = get_step(get_turf(AL), direction)
//				if(AL2 && AL2 != AL && AL.name == AL2.name) //Assuming its a double airlock?
//					connectedairlocks += AL2

/obj/machinery/computer/doorcontrol/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/card/id))
		if(!controlid && user.unEquip(O))
			O.forceMove(src)
			controlid = O
			if(check_access(controlid))
				locked = 0
			updateUsrDialog()
		else if(controlid)
			to_chat(user, "<span class='warning'>There is already ID card inside.</span>")
		return
	..()

/obj/machinery/computer/doorcontrol/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/doorcontrol/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_machine(src)
	var/dat
	if(locked)
		dat += "<h3>Door Control Panel</h3><br>"
		dat += "Airlocks Controlled: [connectedairlocks.len]<br>"
		if(controlid)
			dat += "<hr>Insufficient Access.<br>"
	else
		if (mode == 1) //Logs
			dat += "<h3>Activity log</h3><br>"
			for (var/entry in internal_log)
				dat += "[entry]<br><hr>"
			dat += "<a href='?src=\ref[src];action=print'>Print</a><br>"
			dat += "<a href='?src=\ref[src];mode=0'>Back</a><br>"
		else
			dat += "<h3>Door Control Panel</h3><br>"
			if(announcement)
				dat += "<b>Announcement:</b> [announcement]"
			dat += "<a href='?src=\ref[src];mode=1'>View activity log</a><br><br>"
			dat += "<b>Door Control Options:</b><br>"
	//		dat += "Control Single Door: <a href='?src=\ref[src];choice=singledoor'>[Selected ? "[Selected.name]" : "(Select)"</a><br>"
			if(controlid.access == low_sec)
				dat += "Airlock Functions: <a href='?src=\ref[src];choice=opendoors'>Open</a>|<a href='?src=\ref[src];choice=closedoors'>Close</a>"
				if(controlid.access == high_sec)
					dat += "Airlock Functions: <a href='?src=\ref[src];choice=lockdoors'>Bolt</a>|<a href='?src=\ref[src];choice=opendoors'>Unbolt<br>"
					dat += "Panel Functions: <a href='?src=\ref[src];choice=announce'>Set Announcement</a><br>"
//			dat += "Reason:  <a href='?src=\ref[src];choice=reason'>[reason]</a><br>"
//			dat += "Duration (minutes):  <a href='?src=\ref[src];choice=duration'>[duration] m</a><br>"

	user << browse(dat, "window=doorcontrol;size=400x480")
	onclose(user, "doorcontrol")

// var/entry = "\[[stationtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Granted access to following areas: "

/obj/machinery/computer/doorcontrol/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["mode"])
		mode = text2num(href_list["mode"])
		. = 1
	if (href_list["choice"])
		switch(href_list["choice"])
			if ("opendoors")
				world << "CALLED"
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					sleep(rand(10, 25))
					A.open()
			if ("closedoors")
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					A.close()
					sleep(rand(10, 25))
			if ("switchlock")
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					A.lock()
					sleep(rand(10, 25))
			if("announce")
				announcement = input("Please insert announcement", "Panel Announcement")