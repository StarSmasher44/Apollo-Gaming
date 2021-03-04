#define WATT_PER_MHASH     35

#define INSTR_MHASH1       1 //Boosts Mhash by 25%, heat_per_mhash by 20%, Adds power use 20%
#define INSTR_MHASH2       2 //Boosts Mhash by 50%, heat per mhash by 40%, Adds power use 40%
#define INSTR_POWER1       4 //Reduces power usage by 25% (heat_per_mhash by 10%), Mhash -1
#define INSTR_POWER2       8 //Reduces Power usage by 50% (heat_per_mhash by 20%), Mhash -2
#define INSTR_HYPERTHR     16 //Doubles amount of cores, reduces Mhash by 1*core
#define INSTR_PROCCACHE    32 //Reduces time to find block by 5%

/obj/item/server_component
	var/power_use = 0 //Power use in WATTS
	icon = 'icons/obj/modular_components.dmi'
/*
/obj/item/server_component/motherboard
	name = "Motherboard"
	desc = "This is a Motherboard"
	var/cpuslots = 1 //Amount of CPUs that fit on here
	var/hddslots = 1 //Amount of HDDs that fit on here.
	var/networkslots = 1 // Amount of Network Transmitters, usually 1.
	var/obj/item/server_component/power_supply
	//List of components is kept server-side to ease the use of variables.
*/
/obj/item/server_component/processor
	//Base power use
	power_use = 50
	name = "Processor (CPU)"
	icon_state = "cpu_normal"
	//CPU Power usage = (30*processor_mhash)*processor_cores
	var/cpu_pow_use
	var/processor_cores = 1
	var/processor_mhash = 2 //Per core. Total = processor_cores * processor_mhash
	var/heat_per_mhash = 5
	var/instruction_set = 0 //Instruction sets add bonuses to the CPU, or their overall speed

/obj/item/server_component/processor/Initialize()
	. = ..()

	cpu_pow_use = (WATT_PER_MHASH*processor_mhash)*processor_cores

	//Set up CPU according to base values and instruction sets included.
	if(instruction_set)
		if(instruction_set & INSTR_HYPERTHR)
			processor_cores *= 2
			processor_mhash *= 2 //Exponential growth amirite
			cpu_pow_use *= 2 //Yeee rite

		if(instruction_set & INSTR_MHASH1)
			var/old = processor_mhash
			processor_mhash *= 1.25
			heat_per_mhash *= 1.20
			cpu_pow_use *= 1.20
			cpu_pow_use += WATT_PER_MHASH*(processor_mhash-old)

		else if(instruction_set & INSTR_MHASH2)
			var/old = processor_mhash
			processor_mhash *= 1.50
			heat_per_mhash *= 1.40
			cpu_pow_use *= 1.40
			cpu_pow_use += WATT_PER_MHASH*(processor_mhash-old)

		if(instruction_set & INSTR_POWER1)
			cpu_pow_use *= 0.75
			heat_per_mhash *= 0.90
			processor_mhash--
			cpu_pow_use -= WATT_PER_MHASH

		else if(instruction_set & INSTR_POWER2)
			cpu_pow_use *= 0.50
			heat_per_mhash *= 0.80
			processor_mhash -= 2
			cpu_pow_use -= WATT_PER_MHASH*2

	power_use += cpu_pow_use
//		INSTR_PROCCACHE is handled by the XRP loop.

//Currently only stores XRP
/obj/item/server_component/harddrive
	name = "X1 Research Data Storage Unit (DSU)"
	icon_state = "hdd_normal"
	power_use = 15
	var/max_size = 128
	var/stored_research = 0

/obj/item/server_component/harddrive/medium
	name = "X2 Research Data Storage Unit (DSU)"
	icon_state = "hdd_normal"
	power_use = 25
	max_size = 256

/obj/item/server_component/harddrive/large
	name = "X3 Research Data Storage Unit (DSU)"
	icon_state = "hdd_normal"
	power_use = 35
	max_size = 512

/obj/item/server_component/harddrive/super
	name = "X4 Research Data Storage Unit (DSU)"
	icon_state = "hdd_normal"
	power_use = 40
	max_size = 1024
	stored_research = 0

/obj/item/server_component/harddrive/proc/AdjustStorage(var/amount)
	if((stored_research+amount) > max_size)
		return 0
	else if(stored_research+amount < 0) //Can't borrow this shit yo!
		return 0
	else
		stored_research += amount
		return 1


/obj/item/server_component/network_transmitter
	name = "Network Transmitter (NTR)"
	power_use = 30
	var/xrp_per_time = 1

/obj/item/server_component/network_transmitter/medium
	name = "Network Transmitter (NTR)"
	power_use = 60
	xrp_per_time = 2

/obj/item/server_component/network_transmitter/large
	name = "Network Transmitter (NTR)"
	power_use = 80
	xrp_per_time = 3

/obj/item/server_component/power_supply
	name = "Small Power Supply (PSU)"
	icon_state = "battery_ultra"
	var/max_power = 125

/obj/item/server_component/power_supply/medium
	name = "Medium Power Supply (PSU)"
	icon_state = "battery_ultra"
	max_power = 250

/obj/item/server_component/power_supply/large
	name = "Power Supply (PSU)"
	icon_state = "battery_ultra"
	max_power = 500

/obj/item/server_component/power_supply/super
	name = "Power Supply (PSU)"
	icon_state = "battery_ultra"
	max_power = 1000



/*TMP (Tesla MultiProcessors) PROCESSORS GO HERE*/
/obj/item/server_component/processor/tesla/basic
	power_use = 30 //Watts PER MHASH!
	name = "TMP X1 Processor (CPU)"
	desc = "Tesla is efficiency, just like our products! The X1 is our first CPU we are proud of!"
	icon_state = "cpu_normal"
	processor_cores = 1
	processor_mhash = 4 //Per core. Total = processor_cores * processor_mhash
	heat_per_mhash = 3

/obj/item/server_component/processor/arc/basic
	power_use = 45 //Watts PER MHASH!
	name = "ARC Raisin 1 Processor (CPU)"
	desc = "ARC presents Raisin, the first multi-processing CPU built for reliability!"
	icon_state = "cpu_normal"
	processor_cores = 2
	processor_mhash = 2 //Per core. Total = processor_cores * processor_mhash
	heat_per_mhash = 6 //processor_mhash * heat_per_mhash = total heat by component.