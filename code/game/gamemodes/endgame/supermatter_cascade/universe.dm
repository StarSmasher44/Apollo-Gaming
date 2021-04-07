var/global/universe_has_ended = 0


/datum/universal_state/supermatter_cascade
 	name = "Supermatter Cascade"
 	desc = "Unknown harmonance affecting universal substructure, converting nearby matter to supermatter."

 	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

/datum/universal_state/supermatter_cascade/OnShuttleCall(var/mob/user)
	if(user)
		to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0

/datum/universal_state/supermatter_cascade/OnTurfChange(var/turf/T)
	var/turf/space/S = T
	if(isspace(S))
		S.color = "#0066ff"
	else
		S.color = initial(S.color)

/datum/universal_state/supermatter_cascade/DecayTurf(var/turf/T)
	if(issimwall(T))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(issimfloor(T))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			if(!istype(F,/turf/simulated/floor/plating))
				F.break_tile_to_plating()
		return

// Apply changes when entering state
/datum/universal_state/supermatter_cascade/OnEnter()
	to_world("<span class='sinister' style='font-size:22pt'>You are blinded by a brilliant flash of energy.</span>")
	sound_to(world, sound('sound/effects/cascade.ogg'))

	for(var/mob/M in GLOB.player_list)
		M.flash_eyes()

	if(evacuation_controller.cancel_evacuation())
		priority_announcement.Announce("The evacuation has been aborted due to bluespace distortion.")

	AreaSet()
	MiscSet()
	APCSet()
	OverlayAndAmbientSet()

	// Disable Nar-Sie.
	cult.allow_narsie = 0

	PlayerSet()
	new /obj/singularity/narsie/large/exit(pick(endgame_exits))
	spawn(rand(30,60) SECONDS)
		var/txt = {"
A galaxy-wide electromagnetic pulse has been detected. All systems across space are heavily damaged and many personnel have died or are dying. We are currently detecting increasing indications that the universe itself is beginning to unravel.

[station_name()], the largest source of disturbances has been pinpointed directly to you. We estimate you have five minutes until a bluespace rift opens within your facilities.

There is no known way to stop the formation of the rift, nor any way to escape it. You are entirely alone.

God help your s\[\[###!!!-

AUTOMATED ALERT: Link to [command_name()] lost.

"}
		priority_announcement.Announce(txt,"SUPERMATTER CASCADE DETECTED")

		spawn(5 MINUTES)
			ticker.station_explosion_cinematic(0,null) // TODO: Custom cinematic
			universe_has_ended = 1
		return

/datum/universal_state/supermatter_cascade/proc/AreaSet()
	for(var/area/A in all_areas)
		if(!isarea(A) || isspacearea(A) || istype(A,/area/beach))
			continue
		ADD_ICON_QUEUE(A)

		CHECK_TICK

/datum/universal_state/supermatter_cascade/OverlayAndAmbientSet()
//		convert_all_parallax()
	for(var/datum/lighting_corner/L in world)
		if(L.z in GLOB.using_map.admin_levels)
			L.update_lumcount(1,1,1)
		else
			L.update_lumcount(0.0, 0.4, 1)
		CHECK_TICK

	for(var/turf/space/T in turfs)
		OnTurfChange(T)
		CHECK_TICK
/*
/datum/universal_state/supermatter_cascade/proc/convert_all_parallax()
	for(var/client/C in GLOB.clients)
		var/obj/screen/plane_master/parallax_spacemaster/PS = locate() in C.screen
		if(PS)
			convert_parallax(PS)
		CHECK_TICK
*/

/datum/universal_state/supermatter_cascade/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in SSmachines.machinery)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
			CHECK_TICK

/datum/universal_state/supermatter_cascade/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in SSmachines.machinery)
		if (!(APC.stat & BROKEN) && !APC.is_critical)
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
			CHECK_TICK

/datum/universal_state/supermatter_cascade/proc/PlayerSet()
	for(var/datum/mind/M in GLOB.player_list)
		if(!isliving(M.current))
			continue
		if(M.current.stat!=2)
			M.current.Weaken(10)
			M.current.flash_eyes()

		clear_antag_roles(M)
