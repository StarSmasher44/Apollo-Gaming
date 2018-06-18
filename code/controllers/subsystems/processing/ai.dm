var/list/datum/list_of_ais = list()

SUBSYSTEM_DEF(ai)
	name = "AI"
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS


/datum/controller/subsystem/ai/fire()
	for(var/datum/ai/AI in list_of_ais)
		if(!QDELETED(AI) && istype(AI))
			try
				if(AI.process() == PROCESS_KILL)
					list_of_ais -= AI
			catch(var/exception/e)
				world.log << "E is bad [e] on [AI]"
			if(MC_TICK_CHECK)
				return
		else
//			catchBadType(AI)
			list_of_ais -= AI