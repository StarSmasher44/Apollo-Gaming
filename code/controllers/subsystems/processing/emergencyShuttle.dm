SUBSYSTEM_DEF(evacuation)
	name = "evacuation"
	wait = 2 SECONDS // every 2 seconds

/datum/controller/subsystem/evacuation/Initialize(timeofday)
	if(!evacuation_controller)
		evacuation_controller = new GLOB.using_map.evac_controller_type ()
		evacuation_controller.set_up()

/datum/controller/subsystem/evacuation/fire(resumed = FALSE)
	evacuation_controller.process()