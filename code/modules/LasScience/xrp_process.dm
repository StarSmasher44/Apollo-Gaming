var/global/datum/ResearchProcess/XRP

#define XRP_PER_BLOCK 15
#define MHPercentMod 0.5 // 1 MH = 0.5% time taken off, basically the modifier.
//It should be noted that per 10 Mhashes 1% of total time is removed.
#define TimePerBlock 1.5 //Amount in PERCENTAGE it will take extra for every block found.
#define TimeToTake 600 // 10 minutes to seconds, the "Default" time.

						// world.timeofday = 1/10th of a second to *10 to fix it again.

/datum/ResearchProcess
	var/global/list/science_servers = list()
	var/starttime
	var/endtime
	var/blockfound = 0
	var/blocksfound = 0
	var/cur_xrp_per_block = XRP_PER_BLOCK
	var/averagetime
	var/looping = 0
	var/timer = 0
	var/timetotake = TimeToTake //10 Minutes to seconds. (1 minute to 60 for test)
//	var/total_timetotake = timetotake

//Calculates the difficulty modification factor.
//And by chance also the blocks found.
/datum/ResearchProcess/proc/BlockFound()
	blocksfound++
//	var/active_servers = 0
//	for(var/obj/machinery/sci_server/SC in science_servers)
//		if(SC.active)
//			active_servers++

	var/totalMhash = GetMhashes() //Get total MHash in the 'round'
	totalMhash = totalMhash
	for(var/obj/machinery/sci_server/SC in science_servers)
		var/participationshare = SC.ParticipationTime/timetotake //Percentage of this round's participation.

		if(participationshare < 0.33) //You must participate at least 33% of the way to even recieve anything.
			return
		else
			var/togive = round(cur_xrp_per_block*participationshare, 0.10) //Amount of XRP Recieved by participation time.

//			var/obj/item/server_component/processor/CPU = SC.server_components["processor"]
//			var/togivetotal = cur_xrp_per_block

//			var/share = max(((CPU.processor_cores * CPU.processor_mhash)/totalMhash), 0) //Percentage of 'power', more powerful servers get more XRP.

//			world << "XRP: Share of [SC.name] = [share]"
//			var/togivetotal = round(togive+(cur_xrp_per_block*share), 0.25)/2 //Divide by 2 since its 2 modifiers, I guess this could actually work.
//			togivetotal -= togive
			world << "XRP: Total Given to [SC.name] = [togive]"
			var/obj/item/server_component/harddrive/HDD = SC.server_components["harddrive"]
			HDD.AdjustStorage(togive)
			SC.ParticipatedCycles++
			SC.ping("\The [src] pings, \"Cycle [SC.ParticipatedCycles] complete! Share: [participationshare], Research Data: [togive] XRP\"")


//	var/diffmod = (timetotake / endtime) //We keep the modifier to adjust the percentage to deal with large server addition spams.
//	if(diffmod < 0.75)
//		diffmod = 0.75
//	if(diffmod > 2)
//		diffmod = 2
//	world << "Extra Time: [max(round(timetotake*diffmod, 1))]"
//	timetotake = max(round(timetotake*diffmod, 1))

/datum/ResearchProcess/proc/AddServer(var/obj/machinery/sci_server/SC as obj)
	if(istype(SC))
		science_servers.Add(SC)
		SC.name = "Server Machine #[XRP.science_servers.len]"
//		var/timeadjustment = (GetMhashes(SC)*MHPercentMod)
		var/ToRemove = (TimeToTake/100) * (GetMhashes(SC)*MHPercentMod)
		world << "Time Adjustment: -[ToRemove]"
		timer -= ToRemove


/datum/ResearchProcess/proc/RemoveServer(var/obj/machinery/sci_server/SC as obj)
	if(istype(SC))
		science_servers.Remove(SC)
//		var/timeadjustment = (GetMhashes(SC)*MHPercentMod)
		var/ToAdd = (TimeToTake/100) * (GetMhashes(SC)*MHPercentMod)
		world << "Time Adjustment: +[ToAdd]"
		timer += ToAdd

	//If they have the 'SPECIAL' ability to get paid for their work when the server crashes/shuts off mid-generation.
		var/totalMhash = GetMhashes() //Get total MHash in the 'round'
		var/participationshare = SC.ParticipationTime/timetotake //Percentage of this round's participation.
		if(participationshare < 0.33) //You must participate at least 33% of the way to even recieve anything.
			return
		else
			var/togive = round(cur_xrp_per_block*participationshare, 0.25) //Amount of XRP Recieved by participation time.

			var/obj/item/server_component/processor/CPU = SC.server_components["processor"]
			var/share = max(((CPU.processor_cores * CPU.processor_mhash)/totalMhash)-0.30, 0) //Percentage of 'power', more powerful servers get more XRP.

			var/togivetotal = round(togive+(cur_xrp_per_block*share), 0.25)/2 //Divide by 2 since its 2 modifiers, I guess this could actually work.
			cur_xrp_per_block -= togivetotal //Otherwise Im too high for this any way

			var/obj/item/server_component/harddrive/HDD = SC.server_components["harddrive"]
			HDD.AdjustStorage(togivetotal)


/datum/ResearchProcess/proc/GetMhashes(var/obj/machinery/sci_server/SC as obj)
	var/mhashes = 0
	if(SC)
		var/obj/item/server_component/processor/CPU = SC.server_components["processor"]
		mhashes += (CPU.processor_cores * CPU.processor_mhash)
		return mhashes
	else
		for(var/obj/machinery/sci_server/SC1 in science_servers)
			if(SC1.active)
				var/obj/item/server_component/processor/CPU = SC1.server_components["processor"]
				mhashes += (CPU.processor_cores * CPU.processor_mhash)
	return mhashes

/datum/ResearchProcess/proc/GetTime()
//	var/PartRuntime = timetotake-(GetMhashes()*MHPercentMod) //Runtime is total time minus modifier for MHash.
	var/ToRemove = TimeToTake/100 * (GetMhashes()*MHPercentMod)
	var/AddTimePerBlock = TimeToTake/100 * (blocksfound*TimePerBlock)
	var/totalremoved = ToRemove+AddTimePerBlock
	return (timetotake-totalremoved)

/datum/ResearchProcess/proc/BeginPointGen()
	starttime = world.timeofday //Begin first iteration counter.
	timer = GetTime()
	while(src) //Make sure it doesn't lag us to shit, or add to it.
		src.GeneratePoints()
		sleep(3 SECOND)

/datum/ResearchProcess/proc/GeneratePoints()
	if(GetMhashes() > 0)
		if(!looping) //Loop just begins, so we set timer once.
			timer = GetTime()
			looping = 1

//		world << "Runtime: [timer]"

		if(blockfound)
			starttime = world.timeofday
			timetotake = TimeToTake
			cur_xrp_per_block = XRP_PER_BLOCK
			looping = 0
			blockfound = 0

		if(looping && timer <= 0)
			endtime = (world.timeofday - starttime)/10
//			world << "Endtime: [endtime]"
			blockfound = 1
			BlockFound()
		if(looping && timer > 0)
			timer -= 3
			for(var/obj/machinery/sci_server/SC in science_servers)
				if(SC.active && SC.performance_setting > 0)
					SC.ParticipationTime += 2
	else
		//Servers are offline or we have no CPU power.. Sleep it off bro!
		sleep(300)