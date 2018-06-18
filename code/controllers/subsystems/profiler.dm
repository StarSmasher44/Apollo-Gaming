var/global/enable_machine_update_profiling = 0


var/global/list/machines_profile_info = list()


/proc/addtoprofiler(var/obj/machinery/M, var/time)
	if(M && M in SSmachines.machinery && !QDELETED(M)) //Exsists and is actually processing, and is not being deleted.
		if(M.type in machines_profile_info) //Is it already found?
		else
			machines_profile_info[M.type] =