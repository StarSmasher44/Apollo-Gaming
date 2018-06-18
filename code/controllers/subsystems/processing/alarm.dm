// We manually initialize the alarm handlers instead of looping over all existing types
// to make it possible to write: camera.triggerAlarm() rather than alarm_manager.managers[datum/alarm_handler/camera].triggerAlarm() or a variant thereof.
/var/global/datum/alarm_handler/atmosphere/atmosphere_alarm	= new()
/var/global/datum/alarm_handler/camera/camera_alarm			= new()
/var/global/datum/alarm_handler/fire/fire_alarm				= new()
/var/global/datum/alarm_handler/motion/motion_alarm			= new()
/var/global/datum/alarm_handler/power/power_alarm			= new()

// Alarm Manager, the manager for alarms.
var/datum/controller/subsystem/alarm/alarm_manager

SUBSYSTEM_DEF(alarm)
	name = "alarm"
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/datum/alarm/all_handlers

/datum/controller/subsystem/alarm/Initialize(timeofday)
	all_handlers = list(atmosphere_alarm, camera_alarm, fire_alarm, motion_alarm, power_alarm)
	alarm_manager = src

/datum/controller/subsystem/alarm/fire(resumed = FALSE)
	for(var/datum/alarm_handler/AH in all_handlers)
		AH.process()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/alarm/proc/active_alarms()
	. = list()
	for(var/datum/alarm_handler/AH in all_handlers)
		var/list/alarms = AH.alarms
		. += alarms
	return .

/datum/controller/subsystem/alarm/proc/number_of_active_alarms()
	var/list/alarms = active_alarms()
	return alarms.len