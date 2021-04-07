/obj/machinery/power/archon_compressor
	name = "Dense Matter Compressor"
	desc = "A powerful machine capable of compressing with huge force"
	anchored = 1
	density = 1
	use_power = POWER_USE_IDLE
	idle_power_usage = 40
	active_power_usage = 5000
	icon = 'icons/obj/machines/power/archon.dmi'
	icon_state = "compressor_off"
	light_color = COLOR_BLUE

	var/active = 0 //1 = charging, 2 = compressing
	var/max_capacity = 100000 //100k Watts
	var/capacity = 0
	//The maximum amount of materials for a single core.
	var/max_materials = 200000
	var/creation_timer = 0 //Timer to track time for console.
	// The amount of materials that are in the machine.
	var/list/materials = list(
	/obj/item/stack/material/iron = 0,
	/obj/item/stack/material/uranium = 0,
	/obj/item/stack/material/phoron = 0
	)

/obj/machinery/power/archon_compressor/attackby(var/obj/item/thing, var/mob/user)
	if(isstack(thing))
		var/obj/item/stack/material/stack = thing
		var/total = 0
		for(var/A in materials)
			total += materials[A]
		var/material = stack.stacktype
		var/stack_singular = "[stack.material.use_name] [stack.material.sheet_singular_name]" // eg "steel sheet", "wood plank"
		var/stack_plural = "[stack.material.use_name] [stack.material.sheet_plural_name]" // eg "steel sheets", "wood planks"
		var/amnt = stack.perunit
		world << "material is [material]|[amnt]"
		if(total + amnt < max_materials)
			if(stack?.amount >= 1 && material in materials)
				var/count = 0
				while(total + amnt <= max_materials && stack.amount >= 1)
	//				materials["[stack.type]"] += amnt
//					for(var/A in materials) //Note; turn outcome into var to rid of this loop.
					materials[material] += amnt
					stack.use(1)
					count++
				to_chat(user, "You insert [count] [count==1 ? stack_singular : stack_plural] into the compressor.")// 0 steel sheets, 1 steel sheet, 2 steel sheets, etc
		else
			to_chat(user, "The compressor cannot hold more [stack_plural].")// use the plural form even if the given sheet is singular

/obj/machinery/power/archon_compressor/Process()
	..()
	if(stat & (BROKEN|NOPOWER))	return
	if(active == 1 && capacity < max_capacity) //Charge once per tick.
		update_use_power(POWER_USE_ACTIVE)
		capacity += active_power_usage
		capacity = min(capacity, max_capacity) //No more than 100k always
	else
		active = 0
	if(active == 2 && capacity > 0) //Actively compressing & has juice left
		update_use_power(POWER_USE_ACTIVE)
//	if(in_use)
//		for(var/mob/M in range(1))
//			if(M.machine == src)
//				src.attack_hand(M)

/obj/machinery/power/archon_compressor/update_icon()
	icon_state = "[active ? "compressor_on" : "compressor_off"]"

/obj/machinery/power/archon_compressor/proc/Compress_Matter()
	var/temp_stability = 0
	var/temp_radioactivity = 0
	var/temp_efficiency = 0
	var/temp_energy = 0
	var/temp_hardness = 0 //This is the time it will take to compress the core
	ping("Beginning Matter Compression.")
	for(var/A in materials)
		switch(A)
			if(/obj/item/stack/material/iron)
				var/count=0
				for(count=materials[A]/2000, count!=0)
					temp_energy += rand(0.1, 0.2) //Full iron Core = 50, 100 Energy (= 100*100=10000Watts)
					temp_stability += rand(2,4) // Full Iron Core = 1000-2000 Stability.
					temp_efficiency += rand(0.2, 0.4) //Full Iron Core = 100-200 Efficiency.
					temp_hardness += 0.4 //Full Iron Core = 200 hardness
					materials[A] -= 2000
			if(/obj/item/stack/material/uranium)
				var/count=0
				for(count=materials[A]/2000, count!=0)
					temp_energy += rand(2, 3) //Full Uranium Core = 1000-1500 Energy
					temp_radioactivity += rand(0.6, 1.0) //Full Uranium Core = 300-500 Radiation
					temp_efficiency += rand(0.4, 0.8) //Full Uranium Core = 200-300 (Fuel) Efficiency
					temp_stability -= rand(0.8, 1.2) //Full uranium Core = -400 - -600 Stability
					temp_hardness += 0.8 //Full uranium core = 400 Hardness
				materials[A] -= 2000
			if(/obj/item/stack/material/phoron)
				var/count=0
				for(count=materials[A]/2000, count!=0)
					temp_energy += rand(3, 5) //Full Phoron Core = 1500-2500 Energy (= 2500*100=250000
					temp_efficiency += rand(1.2, 1.5) //Full Phoron Core = 600-750 (Fuel) Efficiency
					temp_stability -= rand(1, 2) //Full Phoron Core = -500 - -1000 Stability
					temp_radioactivity += rand(0.1, 0.15) //Full Phoron Core = 50-75 Radiation
					temp_hardness += 1 // Full Phoron core = 500 Hardness
				materials[A] -= 2000
		CHECK_TICK
//		A -= materials
	if(temp_energy && temp_efficiency && temp_stability && temp_radioactivity && temp_hardness)
		ping("Core fusion in progress.. ETA [temp_hardness] Seconds")
		creation_timer = temp_hardness
		if(Create_Core(temp_hardness) == 1)
			var/obj/machinery/power/archon_core/Core = new(src.loc)
			Core.core_stability += temp_stability
			Core.core_radioactive += temp_radioactivity
			Core.core_efficiency += temp_efficiency
			Core.core_energy += temp_energy
			ping("Core compression and fusion complete!")

/obj/machinery/power/archon_compressor/proc/Create_Core(var/time) //A poor attempt at making a timer.
	while(time > 0) //Time left on the bill.
		if(active == 2) //And compressing.
			time -= 2
			sleep(2 SECONDS)
		else
			break
	if(time <= 0)
		return 1

/obj/machinery/computer/compressor_console
	name = "Compressor Control Panel"
	desc = "This is where you control the Archon compressor."
	icon = 'icons/obj/machines/power/archon.dmi'
	icon_state = "panel_off"
	icon_keyboard = "tech_key"
	icon_screen = "turbinecomp"
	light_color = COLOR_BLUE
	var/obj/machinery/power/archon_compressor/Compressor


/obj/machinery/computer/compressor_console/Initialize()
	..()
	for(var/obj/machinery/power/archon_compressor/AC in range(1))
		if(AC)	Compressor = AC


/obj/machinery/computer/compressor_console/Process()
	..()
	updateUsrDialog()

/obj/machinery/computer/compressor_console/attack_hand(var/mob/living/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!isliving(user))
		return
	var/total = 0
	for(var/A in Compressor.materials)
		total += Compressor.materials[A]

	var/dat = "<head><title>Archon Compressor Control Panel</title></head><body>"
	dat += "<b>Compressor:</b> [Compressor ? "[Compressor.name], [total]/[Compressor.max_materials] resources loaded." : "No Compressor found"]<br>"
	switch(Compressor.active)
		if(0) //Off.
			dat += "<b>Compressor Status:</b> Offline "
			dat += "(Status: [100.0*Compressor.capacity/Compressor.max_capacity]%)<br>"
		if(1) //Charging
			dat += "<b>Compressor Status:</b> Charging "
			dat += "(Status: [100.0*Compressor.capacity/Compressor.max_capacity]%)<br>"
		if(2) //Compressing
			dat += "<b>Compressor Status:</b> Compressing "
			dat += "(Status: [Compressor.creation_timer] Seconds left) "
			dat += "([100.0*Compressor.capacity/Compressor.max_capacity]% Power)<br>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];charge=1'>Charge Capacitors</a><A href='?src=\ref[src];compress=1'>Compress Materials</a>"

	var/datum/browser/popup = new(user, "Archon Compressor","Archon Compressor panel", 600, 800, src)
	popup.set_content(dat)
	popup.add_stylesheet("common", 'html/browser/common.css')
	popup.open()
	add_fingerprint(user)
	user.set_machine(src)

/obj/machinery/computer/compressor_console/Topic(href, href_list)
	if((. = ..()))
		return
	if(href_list["charge"])
		Compressor.active = 1
	if (href_list["compress"])
		if(!Compressor.capacity == Compressor.max_capacity)
			ping("Charging incomplete.")
			return
		var/total = 0
		for(var/A in Compressor.materials)
			total += Compressor.materials[A]
		if(!total || total < 50000)
			ping("Insufficient materials")
			return
		Compressor.active = 2
		Compressor.Compress_Matter()
	updateUsrDialog()