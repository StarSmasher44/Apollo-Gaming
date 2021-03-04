#define BASE_POWER_USE 300 //Wattage of power it uses as a base.
var/list/allowed_perf_settings = list("25", "50", "75", "100")

/obj/machinery/sci_server
	name = "Server"
	desc = "This is a server."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	anchored = 1
	density = 1

	var/active = 0 // 1 == On, 0 == Off.
	var/performance_setting = 0 // 0 == No work done. Idle State. 100 = Maximum Power, changes CPU speed.
//	var/finished = 0 // 1 == All required components are in.
	var/locked = 0 //1 = Locked for non-science crew, 2 = Locked for all crew except RD
	var/min_sec = access_research //Access for Locked = 1
	var/max_sec = access_rd //Access for Locked = 2
	var/obj/item/weapon/card/id/scan = null
	var/list/server_components = list(
	"processor" = null,
	"harddrive" = null,
	"network" = null,
	"powsup" = null) //List of components in the server
	//SERVER TASKS EXPLANATION:
	//Server_Tasks must always be entried as "/Taskdatum/ = CpuShare"
//	var/list/server_tasks = list() // List of tasks assigned to server.
	var/datum/ResearchProcess/CurProcess
	var/ParticipationTime = 0 //Time participated in the generation process.
	var/ParticipatedCycles = 0

	//HTML-related vars
	var/sci_panel = 1

	use_power = 1
	idle_power_usage = BASE_POWER_USE

/obj/machinery/sci_server/Initialize()
	. = ..()
	install_basic_components()
	if(!XRP)
		spawn(0)
			XRP = new()
			CurProcess = XRP
			XRP.BeginPointGen()
	sleep(10)
	XRP.AddServer(src)

/obj/machinery/sci_server/Destroy()
	. = ..()
	if(locate(src) in XRP.science_servers)
		ParticipationTime = 0 //Reset it, no bonus/payout for destroyed shit right.
		XRP.RemoveServer(src) //And gtfo bro.
	QDEL_NULL(server_components)

/obj/machinery/sci_server/Process()
	if(active)
		if(XRP && !CurProcess)
			CurProcess = XRP
		var/power_usage = BASE_POWER_USE
		for(var/obj/item/server_component/SC in server_components)
			power_usage += SC.power_use
		idle_power_usage = power_usage

/obj/machinery/sci_server/power_change()
	..()
	if (stat & NOPOWER)
		XRP.RemoveServer(src)
		active = 0

/obj/machinery/sci_server/proc/install_basic_components()
	if(!server_components["processor"])
		server_components["processor"] = new/obj/item/server_component/processor(src)
	if(!server_components["harddrive"])
		server_components["harddrive"] = new/obj/item/server_component/harddrive(src)
	if(!server_components["network"])
		server_components["network"] = new/obj/item/server_component/network_transmitter(src)
	if(!server_components["powsup"])
		server_components["powsup"] = new/obj/item/server_component/power_supply(src)

/obj/machinery/sci_server/proc/HasComponent(var/obj/item/server_component/SC as obj)
	if(!istype(SC, /obj/item/server_component))
		return 0
	for(var/obj/item/server_component/SC2 in server_components)
		if(ispath(SC, SC2.type))
			return SC2
	return 0

/obj/machinery/sci_server/verb/eject_id()
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
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/sci_server/proc/Has_Component(var/obj/item/server_component/O as obj, var/mob/user as mob)
	if(O && istype(O))
		if(istype(O, /obj/item/server_component/processor))
			return server_components["processor"]
		else if(istype(O, /obj/item/server_component/harddrive))
			return server_components["harddrive"]
		else if(istype(O, /obj/item/server_component/network_transmitter))
			return server_components["network"]
		else if(istype(O, /obj/item/server_component/power_supply))
			return server_components["powsup"]

/obj/machinery/sci_server/proc/Add_Component(var/obj/item/server_component/O as obj, var/mob/user as mob)
	if(O && istype(O))
		if(istype(O, /obj/item/server_component/processor))
			server_components["processor"] = O
		else if(istype(O, /obj/item/server_component/harddrive))
			server_components["harddrive"] = O
		else if(istype(O, /obj/item/server_component/network_transmitter))
			server_components["network"] = O
		else if(istype(O, /obj/item/server_component/power_supply))
			server_components["powsup"] = O

/obj/machinery/sci_server/proc/Remove_Component(var/obj/item/server_component/O as obj, var/mob/user as mob)
	if(O && istype(O))
		if(istype(O, /obj/item/server_component/processor))
			server_components["processor"] = null
		else if(istype(O, /obj/item/server_component/harddrive))
			server_components["harddrive"] = null
		else if(istype(O, /obj/item/server_component/network_transmitter))
			server_components["network"] = null
		else if(istype(O, /obj/item/server_component/power_supply))
			server_components["powsup"] = null

/obj/machinery/sci_server/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.forceMove(src)
		scan = O
		to_chat(user, "You insert [O].")

	if(!istype(O, /obj/item/server_component))
		return
	if(active)
		to_chat(src, "<span class='warning'>Server is still active, please shut down first!</span>")
		return
	var/obj/item/server_component/component = Has_Component(O)

	if(!O)
		O.loc = src
		Add_Component(O, user)
	else
		if(active)
			to_chat(src, "<span class='warning'>Server is still active, please shut down first!</span>")
			return
		switch(alert("Replace component with the [O.name]?","Replace Component", "Replace", "Cancel"))
			if("Replace")
				Remove_Component(component)
				component.dropInto(loc)

				user.drop_item()
				O.forceMove(src)
				src.contents.Add(O)
				O.loc = src
				Add_Component(O)

/obj/machinery/sci_server/attack_hand(var/mob/user)
	if(..())
		return

	var/css={"<style>
.sidenav {
    height: 100%;
    width: 140px;
    position: fixed;
    float:left;
    z-index: 1;
    top: 0;
    left: 0;
    background-color: #111;
    overflow-x: hidden;
}

.main {
    margin-left: 140px; /* Same as the width of the sidenav */
    padding: 0px 10px;
    float:right;
}

.sidenav a {
    padding: 6px 8px 6px 16px;
    text-decoration: none;
    font-size: 21px;
    color: #818181;
    display: block;
}

.sidenav a:hover {
    color: #f1f1f1;
}
</style>"}

	user.set_machine(src)
	var/obj/item/server_component/processor/CPU = server_components["processor"]
	var/obj/item/server_component/harddrive/HDD = server_components["harddrive"]
	var/obj/item/server_component/network_transmitter/NETW = server_components["network"]
	var/obj/item/server_component/power_supply/PSU = server_components["powsup"]
	var/dat

	dat += {"<body><div class='sidenav'>
	<a href='?src=\ref[src];scipanel=1'>Control Panel</a>
	<a href='?src=\ref[src];scipanel=2'>Components</a>
	<a href='?src=\ref[src];scipanel=3'>Data Network Status</a>
	<a href='?src=\ref[src];scipanel=4'>Contact</a>
	</div>"}
	dat += "<div class='main'>"
	dat += "<h3>SerbPanel 0.1</h3><hr>[css]"
	dat += "<h4>Server Information:</h4><br>"
	if(locked && !scan)
		dat += "<h4>SERVER LOCKED DOWN!</h4><br>"
		dat += "This server has been locked down, only authorized personnel are allowed to access this console."
	else
		if(locked && scan)
			switch(locked)
				if(1)
					if(min_sec in scan.access)
						//Passed.
					else
						return
				if(2)
					if(max_sec in scan.access)
						//Passed.
					else
						return
	switch(sci_panel)
		if(1) //Main Panel/Control Panel
			dat += {"
			Server Name: [name]<br>
			Network Status: [active ? "Active" : "Inactive"]<br>
			Power Usage: [idle_power_usage] Watts<br>
			Performance Setting: [performance_setting]% of total capacity
			<hr>
			"}

		if(2)
			if(CPU)
				dat += {"Processor: [CPU.name]<br>
					Cores: [CPU.processor_cores], [CPU.processor_mhash]MH<br>
					<i>(Total Power: [CPU.processor_cores*CPU.processor_mhash] MH)</i><br>
					Power Usage: [CPU.power_use]W<br>"}
			else
				dat += "<b>ERR: Processor not found!</b>"

			if(HDD)
				dat += {"Storage: [HDD.name]<br>
					Space: [HDD.stored_research]/[HDD.max_size] ([100*HDD.stored_research/HDD.max_size]% full)<br>
					Power Usage: [HDD.power_use]W<br>"}
			else
				dat += "<b>ERR: Storage Medium not found!</b>"

			if(NETW)
				dat += {"Network: [NETW.name]<br>
					Power Usage: [NETW.power_use]W<br>"}
			else
				dat += "<b>ERR: Network Card not found!</b>"

			if(PSU)
				dat += {"Power Supply: [PSU.name]<br>
					Maximum Power: [PSU.max_power]W<br>"}
			else
				dat += "<b>ERR: Power Supply not found!</b>"
		if(3)
			return
		if(4)
			return
	dat += "</div></body>"
	user << browse(dat, "window=sci_serb;size=800x600")
	onclose(user, "sci_serb")

/obj/machinery/sci_server/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["scipanel"])
		if(1)
			sci_panel = 1
		if(2)
			sci_panel = 2
		if(3)
			sci_panel = 3
		if(4)
			sci_panel = 4
		else
			return
/*
	if (href_list["mode"])
		mode = text2num(href_list["mode"])
		. = 1
	if (href_list["choice"])
		switch(href_list["choice"])
			if ("opendoors")
				world << "CALLED"
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					A.open()
			if ("closedoors")
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					A.close()
			if ("switchlock")
				for(var/obj/machinery/door/airlock/A in connectedairlocks)
					A.lock()
			if("announce")
				announcement = input("Please insert announcement", "Panel Announcement")
*/