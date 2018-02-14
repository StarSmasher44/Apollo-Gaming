/proc/create_all_lighting_overlays()
	for(var/zlevel = 1 to world.maxz)
		create_lighting_overlays_zlevel(zlevel)

/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for(var/TA in Z_TURFS(zlevel))
		var/turf/T = TA
		if(T.dynamic_lighting)
			T.lighting_build_overlay()
		CHECK_TICK
