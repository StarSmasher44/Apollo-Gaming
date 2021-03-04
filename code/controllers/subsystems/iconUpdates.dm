var/datum/controller/subsystem/icon_updater/iconupdater

/datum/controller/subsystem/icon_updater
	name = "Icon Updating"
	priority = 30
	wait = 15
	flags = SS_KEEP_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVEL_INIT | RUNLEVELS_DEFAULT

	var/iconslasttick = 0
	var/list/icon_updates = list()
	var/backlogspeed = 0

/datum/controller/subsystem/icon_updater/New()
	NEW_SS_GLOBAL(iconupdater)
	spawn(700) //After 70 seconds, so when everything has pretty much initialized..
		report_progress("Completing icon refresh.")
		Instant_Queue() //We do the entire queue now so we won't have to catch up.

/datum/controller/subsystem/icon_updater/stat_entry(msg)
	msg += "ICONS:[icon_updates.len]|LAST: [iconslasttick]"
	..(msg)

/datum/controller/subsystem/icon_updater/fire()
	if(state == SS_RUNNING)
		iconslasttick = 0
		var/list/icon_updates = src.icon_updates

		for(var/A in icon_updates)
			var/atom/AM = A
			icon_updates -= AM
			if(!QDELETED(AM))
				AM.update_icon()
			iconslasttick++

			if (MC_TICK_CHECK)
				return
		CheckBacklog()
//Since this controller is a bit wonky when it comes to lag, it is possible for it to become backlogged in icon update requests.
//The way they are added, every icon is still only updated once.
//Once the backlog is too great, we give it a faster processing speed and priority to catch up until it restores to normal levels.
/datum/controller/subsystem/icon_updater/proc/CheckBacklog()
	set waitfor = FALSE

	switch(icon_updates.len)
		if(0 to 1000 && backlogspeed)
			priority = 25
			wait = 20
			backlogspeed = 0
		if(1500 to 3000)
			if(iconslasttick < 50) //Large backlog, or not processing enough icons per tick
				wait = 15
			priority = 30
			backlogspeed = 1
		if(3001 to 6000)
			if(iconslasttick < 50)
				wait = 15
			priority = 35
			backlogspeed = 1
			message_admins("Something went bad with the Icon Updater and its running behind a lot.. Let Laser know.")
		if(6001 to 10000)//We fucking done did it now boys.
			message_admins("Flushing Icon Updates..")
			Instant_Queue()
			backlogspeed = 1

/datum/controller/subsystem/icon_updater/proc/Instant_Queue()
	set waitfor = 0
	var/iconscomplete
	for(var/A in icon_updates)
		var/tmp/atom/AT = A
		if(!QDELETED(AT))
			AT.update_icon()
			iconscomplete++
		icon_updates -= AT
		CHECK_TICK2(80)
	report_progress("Icon refresh completed. [iconscomplete] icons refreshed.")

#define ADD_ICON_QUEUE(THING)           \
	if(!QDELETED(THING))                \
		iconupdater.icon_updates |= THING;