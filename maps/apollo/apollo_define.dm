/*------------------MAP SETUP-----------------
THIS IS A SIMPLE OUTLOOK OVER THE Z LAYER CONSTRUCTION OF THE NEO APOLLO.

Apollo Z-1 = Underground, below Z-2.
Apollo Z-2 = Above ground, above Z-1, Below Z-3
Apollo Z-3 = In Space, Above Z-2.
*/
/datum/map/apollo
	name = "Apollo"
	full_name = "NEO Apollo"
	path = "exodus" //Leaving this to maintain saves.

	lobby_icon = 'icons/misc/fullscreen.dmi'

	load_legacy_saves = TRUE
	use_overmap = 0
	overmap_z = 4
	overmap_size = 75		//Dimensions of overmap zlevel if overmap is used.
	overmap_event_areas = 6 //How many event "clouds" will be generated

	station_levels = list(1, 2)
	admin_levels = list(3)
	contact_levels = list(1,2,3)
	player_levels = list(1,2)
	sealed_levels = list(1, 3)
	empty_levels = list(1, 4)
//	accessible_z_levels = list("1" = 5, "2" = 5, "4" = 10, "5" = 15, "7" = 60)
//	base_turf_by_z = list("6" = /turf/simulated/floor/asteroid) // Moonbase
	overmap_size = 60
	overmap_event_areas = 60

	station_name  = "NEO Apollo"
	station_short = "Apollo"
	dock_name     = "NAS Baguette"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name = "-REDACTED-"

	shuttle_docked_message = "The scheduled Crew Transfer Shuttle to %Dock_name% has docked with the station. It will depart in approximately %ETD%"
	shuttle_leaving_dock = "The Crew Transfer Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	shuttle_called_message = "A crew transfer to %Dock_name% has been scheduled. The shuttle has been called. It will arrive in approximately %ETA%"
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."

	evac_controller_type = /datum/evacuation_controller/shuttle

//Takes the station time and returns the maximum lighting level outside. Set on init.
/proc/get_lighting_level()
	var/time = time2text(station_time_in_ticks, "hh")
	world << "Time = [time]"
	switch(time)
		if(0 to 5)
			return 1
		if(6 to 8)
			return 3
		if(9 to 20)
			return 4
		if(21 to 23)
			return 2

/client/verb/SetLightingS(var/light as num)
	set name = "Set Lighting"
	set category = "Debug"
	set waitfor = 0

	if(!holder)	return
	get_lighting_level()

	var/lightlevel = light
	if(!lightlevel)
		lightlevel = input("Set num") as num
	if(lightlevel == -1)
		return

	for(var/turf/unsimulated/desert/D in GLOB.outside_turfs)
		D.set_light(lightlevel)
		CHECK_TICK

/datum/map/apollo/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 255, 255) // Create the mining Z-level.

	new /datum/random_map/automata/cave_system(null, 1, 1, 2, 255, 255) // Create the mining Z-level.

	new /datum/random_map/noise/ore(null, 1, 1, 1, 255, 255)         // Create the mining ore distribution map.
	new /datum/random_map/noise/exoplanet/desert(md5(world.time + rand(-100,1000)),1,1,2,255,255,0,1,1)

	var/lightlevel = get_lighting_level()
	for(var/turf/unsimulated/desert/D in GLOB.outside_turfs)
		D.set_light(lightlevel)
		CHECK_TICK
	return 1