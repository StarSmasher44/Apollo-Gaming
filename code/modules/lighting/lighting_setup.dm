/proc/create_all_lighting_overlays()
	for(var/area/A in world)
		if(!A.dynamic_lighting)
			continue
		for(var/turf/T in A)
			if(!T.dynamic_lighting)
				continue
			T.lighting_build_overlay()
		CHECK_TICK
/*
	for(var/zlevel = 1 to world.maxz)
		create_lighting_overlays_zlevel(zlevel)
*/
/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for(var/TA in Z_TURFS(zlevel))
		var/turf/T = TA
		if(T.dynamic_lighting)
			T.lighting_build_overlay()
		CHECK_TICK
