#define MIN_FUSION_TEMP 100000

#define MAX_FUSION_TEMP 1000000
#define FUSION_TEMP_MODIFIER 750 // = max_core_stability * FUSION_TEMP_MODIFIER, used to calculate when fusion is achieved

/obj/machinery/power/archon_core
	name = "Archon Core"
	desc = "A very dense ball of supercompressed matter, tight."
	density = 0
	anchored = 0
	icon = 'icons/obj/machines/power/archon.dmi'
	icon_state = "archon_core"

	var/list/materials = list(
	/obj/item/stack/material/iron = 0,
	/obj/item/stack/material/uranium = 0,
	/obj/item/stack/material/phoron = 0
	)
	var/min_fusion_temp

	var/fusion = 0 //Have we achieved fusion?
	var/secured = 0 //If secured to the control rod.
	var/core_stability = 0 //Iron raises stability in the core. Stability = stability - heat (1 per 100C/1000C) - 0.5 per radioactive
	var/max_core_stability = 0 //The maximum stability, EG the 'damage' variable of the SM.
	var/core_radioactive = 25 //Uranium Raises radioactivity in the core, lowers stability. radioactive = radioactive output
	var/core_efficiency = 0 //Efficiency is the fuel_to_heat ratio of the core. Efficiency = 1 fuel per 10 seconds - 0.01 per efficiency.
	var/core_energy = 0 //Phoron raises the energy of a core, increasing its power, lowers stability. 1 Energy = 100 Watts
	var/core_fuel = 100 //The fuel percentage that is left in the core. in percentage for easy.
	// Energy>to>Heat>Ratio =
	var/core_temp = 0 //Core temperature.
	var/lastshot = 0

/obj/machinery/power/archon_core/New()
	..()
	max_core_stability = core_stability //Set max.
	min_fusion_temp = max_core_stability * FUSION_TEMP_MODIFIER

/obj/machinery/power/archon_core/Process()
	if(secured && core_temp >= min_fusion_temp && !fusion)
		var/fusionchance = max(90, (core_temp - min_fusion_temp) / (min_fusion_temp/100))
		if(prob(fusionchance))
			fusion = 1
			ADD_ICON_QUEUE(src)

	var/turf/L = loc
	if(isturf(L))
		var/datum/gas_mixture/env = L.return_air()
		if(core_temp != L.temperature)
			if(L.temperature >= core_temp && prob(66))
				core_temp++
			else if(L.temperature <= core_temp)
				if(core_temp - L.temperature > 100)
					var/heat = core_temp - L.temperature * OPEN_HEAT_TRANSFER_COEFFICIENT //Heat Transfer Coefficient
					var/transfer_moles = 0.25 * env.total_moles
					var/datum/gas_mixture/removed = env.remove(transfer_moles)
					if(removed)
						removed.add_thermal_energy(heat)
						env.merge(removed)
//						core_temp -= heat

/obj/machinery/power/archon_core/update_icon()
	if(fusion)
		icon = 'icons/obj/machines/power/archon_fusion.dmi'
		icon_state = "fusion_ball"
		if(core_radioactive)
			src.filters += filter("blur", size=2)
			switch(core_radioactive)
				if(25 to 100)
					src.icon += rgb(0, 25, 0)
				if(100 to 500)
					src.icon += rgb(0, 50, 0)
		for(var/A in materials)
			if(A == /obj/item/stack/material/phoron)
				src.icon += rgb(25, 0, 0)
	else
		icon = 'icons/obj/machines/power/archon.dmi'
		icon_state = "archon_core"
		switch(core_radioactive)
			if(25 to 100)
				src.icon += rgb(0, 25, 0)
			if(100 to 500)
				src.icon += rgb(0, 50, 0)
		for(var/A in materials)
			if(A == /obj/item/stack/material/phoron)
				src.icon += rgb(25, 0, 0)

/obj/machinery/power/archon_core/bullet_act(var/obj/item/projectile/Proj)
	var/proj_damage = Proj.get_structure_damage()
	if(istype(Proj, /obj/item/projectile/beam))
		core_temp += proj_damage * 4
	else
		core_temp += proj_damage * 2
	return 0

/obj/machinery/power/archon_core/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		if(!secured)
			var/obj/structure/archon_rod/control_rod/ROD = locate() in loc.contents
			if(ROD)
				to_chat(user, "You secure the [src] to the [ROD].")
				secured = ROD
				anchored = 1
		else
			to_chat(user, "You unsecure the [src] from the [secured].")
			secured = null
			anchored = 0
