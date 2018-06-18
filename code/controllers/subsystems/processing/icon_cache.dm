/var/datum/controller/subsystem/icon_cache/SSicon_cache

/datum/controller/subsystem/icon_cache
	name = "Icon Cache"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ICON_CACHE



	var/list/space_dust_cache = list()
	var/list/space_cache = list()
	var/list/mannequins = list()
	var/list/human_regular_hud_cache
	var/list/parallax_icon[(GRID_WIDTH**2)*3]
	var/parallax_initialized = 0

/datum/controller/subsystem/icon_cache/New()
	NEW_SS_GLOBAL(SSicon_cache)

/datum/controller/subsystem/icon_cache/Initialize()
	build_hud_cache()
	build_dust_cache()
	build_space_cache()
	create_global_parallax_icons()
	..()


/datum/controller/subsystem/icon_cache/proc/build_dust_cache()
	for (var/i in 0 to 25)
		var/mutable_appearance/im = mutable_appearance('icons/turf/space_parallax1.dmi',"[i]")
//		var/image/im = image('icons/turf/space_parallax1.dmi',"[i]")
		im.plane = PLANE_SPACE_DUST
		im.alpha = 80
		im.blend_mode = BLEND_ADD
		space_dust_cache["[i]"] = im

/datum/controller/subsystem/icon_cache/proc/build_space_cache()
	for (var/i in 0 to 25)
		var/mutable_appearance/I = new()
//		var/image/I = new()
		I.appearance = /turf/space
		var/istr = "[i]"
		I.icon_state = istr
		I.overlays += space_dust_cache[istr]
		space_cache[istr] = I


/datum/controller/subsystem/icon_cache/proc/get_mannequin(ckey)
	. = mannequins[ckey]
	if (!.)
		. = new /mob/living/carbon/human/dummy/mannequin
		mannequins[ckey] = .

/datum/controller/subsystem/icon_cache/proc/build_hud_cache()
	human_regular_hud_cache = new
	human_regular_hud_cache.len = 4
	human_regular_hud_cache[1] = image("icon" = 'icons/mob/screen1_health.dmi',"icon_state" = "burning")
	human_regular_hud_cache[2] = image("icon" = 'icons/mob/screen1_health.dmi',"icon_state" = "hardcrit")
	human_regular_hud_cache[3] = image("icon" = 'icons/mob/screen1_health.dmi',"icon_state" = "softcrit")
	human_regular_hud_cache[4] = image("icon" = 'icons/mob/screen1_health.dmi',"icon_state" = "fullhealth")