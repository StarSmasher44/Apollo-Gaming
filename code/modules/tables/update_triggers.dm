/obj/structure/window/Initialize()
	. = ..()
	for(var/obj/structure/table/T in orange(src, 1))
		T.update_connections()
		ADD_ICON_QUEUE(T)

/obj/structure/window/Destroy()
	var/oldloc = loc
	. = ..()
	for(var/obj/structure/table/T in range(oldloc, 1))
		T.update_connections()
		update_icon()

/obj/structure/window/Move()
	var/oldloc = loc
	. = ..()
	if(loc != oldloc)
		for(var/obj/structure/table/T in range(oldloc, 1) | range(loc, 1))
			T.update_connections()
			ADD_ICON_QUEUE(T)