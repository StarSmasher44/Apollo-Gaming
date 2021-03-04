//Mainly for things like ping, AFK kicking code and all that jazz.
var/datum/controller/subsystem/gamesys/gamesys

/datum/controller/subsystem/gamesys
	name = "Game System"
	priority = 10
	wait = 40
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVEL_INIT | RUNLEVELS_DEFAULT

	var/cpustate  = "Unknown"
	var/cur_ticks = 0 //Amount of ticks we've done. ticks var itself is trash?

/datum/controller/subsystem/gamesys/New()
	NEW_SS_GLOBAL(gamesys)

/datum/controller/subsystem/gamesys/fire()
	if(state == SS_RUNNING)

		for(var/client/C in GLOB.clients)
			winset(C, null, "command=.update_ping+[world.time+world.tick_lag*TICK_USAGE_REAL/100]")



			if(config.kick_inactive && cur_ticks % 150)
				if(!C.holder && C.is_afk(config.kick_inactive MINUTES))
					if(!isobserver(C.mob))
						log_access("AFK: [key_name(C)]")
						to_chat(C, "<SPAN CLASS='warning'>You have been inactive for more than [config.kick_inactive] minute\s and have been disconnected.</SPAN>")
						qdel(C)
//		if(cur_ticks % 75)
//			CleanLists()

		switch(world.cpu)
			if(0 to 20)
				cpustate = "Optimal performance ([TICK_USAGE]%)"
			if(21 to 40)
				cpustate = "Good Performance ([TICK_USAGE]%)"
			if(41 to 60)
				cpustate = "Ok Performance ([TICK_USAGE]%)"
			if(61 to 79)
				cpustate = "Bad Performance ([TICK_USAGE]%)"
			if(80 to 99)
				cpustate = "Terrible Performance ([TICK_USAGE]%)"
			if(100 to 1000)
				cpustate = "Server Overloaded ([TICK_USAGE]%)"
		cur_ticks++
/*
//A loop that periodically (Roughly every 10-15 minutes) cleans out lists, basic maintenance I suppose.
/datum/controller/subsystem/gamesys/proc/CleanLists()
	var/list/liststoclean = list(
	SSmachines.machinery,
	SSmachines.pipenets,
	SSmobs.mob_list,
	SSobj.processing)

	for(var/list/L in liststoclean)
		listclearnulls(L)
		liststoclean.Remove(L)
	for(var/L in SSmachines.machinery)
		if(!ismachine(L))
			SSmachines.machinery.Remove(L)
*/