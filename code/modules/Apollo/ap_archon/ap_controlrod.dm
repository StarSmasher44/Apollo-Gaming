/obj/structure/archon_rod/control_rod
	name = "Archon Control Rod"
	desc = "A control rod creating a very powerful EM field, may suck the iron out of your blood."
	icon = 'icons/obj/machines/power/archon.dmi'
	icon_state = "control_rod"

	var/obj/machinery/power/archon_control_rod/CONTROL

	var/power_setting = 0 //0 = off, 3 = 50Kw usage.
	var/strength = 0 //0-100, if the strength is 0 the fusion may get out of control.

/obj/structure/archon_rod/control_rod/New()
	..()
	var/turf/T = get_step(src, SOUTH) //Console is attached 'behind' the rod.
	CONTROL = locate(CONTROL) in T.contents
	CONTROL.ROD = src

/obj/structure/archon_rod/control_rod/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.set_dir(turn(src.dir, 270))
	return 1

/obj/structure/archon_rod/control_rod/verb/rotateccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.set_dir(turn(src.dir, 90))
	return 1

/obj/machinery/power/archon_control_rod //Control rod console
	name = "Control rod Console"
	desc = "This is where the magic happens"
	var/obj/structure/archon_rod/control_rod/ROD

/obj/machinery/power/archon_control_rod