var/global/paychecks = 0
var/global/datum/controller/subsystem/persistent/PersistentSys

SUBSYSTEM_DEF(persistent)
	name = "Persistent"
	priority = SS_PRIORITY_PERSISTENT
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 60 SECONDS

	var/next_cycle = 0
	var/savetime
	var/obj/machinery/message_server/linkedServer = null
	var/obj/item/device/pda/NTpda


/datum/controller/subsystem/persistent/Initialize(timeofday)
	InitializePDA()
	InitializeServer()
	PersistentSys = src
	next_cycle = world.time + 1 HOUR
	..()

/datum/controller/subsystem/persistent/fire(resumed = 0)
//	var/datum/category_item/player_setup_item/general/persistent/PERSISTENT = new()
	for(var/CL in GLOB.clients)
		var/client/C = CL
		var/mob/living/carbon/human/H = C.mob
		if(!H || !ishuman(H) || !H.CharRecords)	continue
		if(C.inactivity/10 > 180) // 3 minutes AFK or more we begin counting.
			var/timeafk = round(C.inactivity/3, 1) // Take 1/3rd of the total AFK time.
			if(timeafk/10 > 600) // 10 minutes
				continue // Too much AFKing, we quit.
			var/playtimeseconds = round(60-(timeafk/10), 1) // Divide by 10 to get seconds.
			H.CharRecords.department_playtime += round(playtimeseconds/60, 0.01)
			if(!H.client.prefs.promoted && calculate_department_rank(H) <= 3)
				H.CharRecords.department_experience += round(playtimeseconds/60, 0.01)
		else
			H.CharRecords.department_playtime++
			H.CharRecords.department_experience++

		if(H && world.timeofday > savetime) // Calculate once every 2 minutes
			savetime = world.timeofday + 3 MINUTES
			calculate_department_rank(H) //Checks time played and sets rank accordingly.
			if(ticker.current_state != GAME_STATE_FINISHED) //Just in case, make sure we do not corrupt our shit by saving during reboots. Round end handles its own saves.
				H.CharRecords.save_persistent()
				CHECK_TICK
	if(world.time > next_cycle)
		next_cycle = world.time + 1 HOUR
		paychecks++
		command_announcement.Announce("Paychecks have been processed for crew of [station_name()].", "[GLOB.using_map.boss_name]")
		var/tot_incometax = 0 //Pools income taxes to send to NT.
		var/datum/money_account/NTBank = department_accounts["NanoTrasen"]
		for(var/mob/living/carbon/human/M in GLOB.player_list)
			if(M.stat != 2) // Not fucking dead either, and must be working for NT.
				var/paycheck = calculate_paycheck(M)
				if(paycheck)
					var/datum/job/job = job_master.GetJob(M.job)
					var/status = "N/A"
					if(job.intern)
						status = "N/A (Internship)"
					else
						status = get_department_rank_title(job.department, calculate_department_rank(M))
					tot_incometax += get_tax_deduction("income", paycheck) //Adds taxes to total.
					var/message = {"
					<html>
					<body>
					<table><tr>
					<b>!WARNING: CONFIDENTIAL!</b>
					<hr>
					Employee Name: [M.name] <br>Employee Assignment: [M.job]<br>
					Total work time: [round(M.CharRecords.department_playtime/60, 0.1)] Hours<br>
					Current Department Rank: [status]<br>
					Employment Status: [job.intern ? "INTERNSHIP PROGRAM" : "WORK CONTRACT"]<br>
					<hr>
					<b>Gross Paycheck:</b> $[paycheck]<br>
					<b>Taxes:</b><br>
					Income Tax: $-[get_tax_deduction("income", paycheck)] ([INCOME_TAX]%)<br>
					Pension Tax: $-[get_tax_deduction("pension", paycheck, M.client.prefs.permadeath ? 1 : 0)] ([M.client.prefs.permadeath ? PENSION_TAX_PD : PENSION_TAX_REG]%)<br>
					Net Income: $[send_paycheck(M, paycheck)]</tr>
					</table>
					</body>
					</html>
"}
					SendPDAMessage(M, message)
		//Sends income tax to NT.
		var/datum/transaction/T = new("NanoTrasen Finances Account", "Paycheck Income Tax Return", tot_incometax, "[station_name()] Payment Processing")
		NTBank.do_transaction(T)

/datum/controller/subsystem/persistent/proc/InitializePDA()
	NTpda = new(src)
	NTpda.owner = "NanoTrasen"
	NTpda.name = "NanoTrasen Messages"
	NTpda.message_silent = 1
	NTpda.news_silent = 1
	NTpda.hidden = 1
	NTpda.ownjob = "NanoTrasen Administration"

/datum/controller/subsystem/persistent/proc/InitializeServer() //Sets up messaging server
	if(!linkedServer)
		if(GLOB.message_servers.len)
			linkedServer = GLOB.message_servers[1]
			return 1
	if(linkedServer)
		return 1

/datum/controller/subsystem/persistent/proc/SendPDAMessage(var/mob/living/carbon/M, var/message)
	var/obj/item/device/pda/PDARec = null
	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner || P.toff || P.hidden)	continue
		if(P.owner == M.real_name)
			PDARec = P
			//Sender isn't faking as someone who exists
			if(!isnull(PDARec) && InitializeServer())
				linkedServer.send_pda_message("[P.owner]", "[NTpda.owner]","[message]")
//				P.new_message(NTpda, "NanoTrasen Administration.", "NanoTrasen", message)
				NTpda.tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[message]", "target" = "\ref[P]")))
				P.tnote.Add(list(list("sent" = 0, "owner" = "[NTpda.owner]", "job" = "[NTpda.ownjob]", "message" = "[message]", "target" = "\ref[NTpda]")))
			if(!NTpda.conversations.Find("\ref[P]"))
				NTpda.conversations.Add("\ref[P]")
			if(!P.conversations.Find("\ref[NTpda]"))
				P.conversations.Add("\ref[NTpda]")
			P.new_message_from_pda(NTpda, message)
			if (!P.message_silent)
				playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)