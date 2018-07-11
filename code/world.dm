#define WORLD_ICON_SIZE 32
//This file is just for the necessary /world definition
//Try looking in game/world.dm

#warn World Turf edited FROM space. Make sure not to forget.

/world
	mob = /mob/new_player
	turf = /turf/unsimulated/desert
	area = /area/exoplanet/desert
	view = "15x15"
	cache_lifespan = 0
	hub = "Exadv1.spacestation13"
	icon_size = WORLD_ICON_SIZE
#ifdef GC_FAILURE_HARD_LOOKUP
	loop_checks = FALSE
#endif
