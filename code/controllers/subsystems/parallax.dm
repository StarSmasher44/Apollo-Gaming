#define GRID_WIDTH 3

SUBSYSTEM_DEF(parallax)
	name = "Space Parallax"
	init_order = INIT_ORDER_PARALLAX
	flags = SS_NO_FIRE
	priority = 30

	var/list/parallax_icon[(GRID_WIDTH**2)*3]
	var/parallax_initialized = 0

/datum/controller/subsystem/parallax/New()
	NEW_SS_GLOBAL(SSparallax)

/datum/controller/subsystem/parallax/Initialize(timeofday)
	create_global_parallax_icons()
	..(timeofday, TRUE)

#undef GRID_WIDTH