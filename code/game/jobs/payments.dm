proc/calculate_paycheck(var/mob/living/carbon/human/M, var/roundend = 0, var/tax = 1) //Tax = if we should calculate taxes, add if we want to add the cash.
	if(M && ishuman(M) && M.client && M.CharRecords && M.client.prefs.char_department && M.job) //SO MANY CHECKS JEZUS ah well
		var/paycheck = round(get_base_pay(M) * 4, 0.5)
		if(evacuation_controller.emergency_evacuation)
			paycheck = (paycheck*0.80) //80 percent of the paycheck.
		if(roundend)
			var/mins = round((round_duration_in_ticks % 36000) / 600)
			var/deduct = (paycheck/60)*(60 % mins)
			paycheck -= deduct
		if(tax)
			get_tax_deduction("pension", paycheck, M.client.prefs.permadeath ? 1 : 0)
			get_tax_deduction("income", paycheck)
		if(M.client.prefs.bonuscredit)
			paycheck += M.client.prefs.bonuscredit
			M.client.prefs.bonuscredit = 0
		paycheck = round(paycheck, 0.5)
		return paycheck

proc/send_paycheck(var/mob/living/carbon/human/M, var/paycheck)
	if(M && paycheck)
		var/bank = 0
		var/pension = 0
		var/datum/job/job = job_master.GetJob(M.job)
		if(job.intern == 1)
			pension = 0
		else
			pension = get_tax_deduction("pension", paycheck, M.client.prefs.permadeath ? 1 : 0)
		bank = get_tax_deduction("income", paycheck)

		M.client.prefs.pension_balance += round(pension, 0.5)
		paycheck -= (bank+pension)
//		M.client.prefs.bank_account.bank_balance += round(paycheck, 0.5)
		var/datum/transaction/T = new(M.client.prefs.bank_account.account_number, "Employee Paycheck", round(paycheck, 0.5), "NT Financial")
		M.client.prefs.bank_account.do_transaction(T)
		if(M.client)
			M.client.prefs.save_character()

		return round(paycheck, 0.5)

proc/get_tax_deduction(var/taxtype, var/paycheck, var/permadeath)
	if(taxtype && paycheck)
		switch(taxtype)
			if("income")
				var/incometax = (paycheck / 100) * INCOME_TAX
				return round(incometax, 0.5)
			if("pension")
				var/pensiontax
				if(permadeath)
					pensiontax = (paycheck / 100) * PENSION_TAX_PD
				else
					pensiontax = (paycheck / 100) * PENSION_TAX_REG
				return round(pensiontax, 0.5)

proc/calculate_bonus_credit(var/mob/living/carbon/human/M, var/bonuscredit, var/bonuspercentage)
	if(M?.job)
		if(bonuscredit) //Applied in direct cashes.
			M.client.prefs.bonuscredit += bonuscredit
		else if(bonuspercentage) //Applies to base pay percentage.
			M.client.prefs.bonuscredit += calculate_paycheck(M, 0, 0)/100*bonuspercentage
		if(M.client)
			M.client.prefs.save_character()

proc/get_base_pay(var/mob/living/carbon/human/M)
	if(M?.job)
		var/datum/job/job = job_master.GetJob(M.job)
		var/base_pay = job.base_pay //Base pay from job
		var/efficiencybonus = min(4*paychecks, 20) //Efficiencybonus = +4% per paycheck (hour).
		var/rankbonus = calculate_department_rank(M) * 5 // Rank bonus = rank number * 5%
		var/speciesmodifier = get_species_modifier(M)
		var/scoremodifier = (M.CharRecords.employeescore-5) * 2
		var/end_base_pay = (base_pay/100) * (100+efficiencybonus+rankbonus+speciesmodifier+scoremodifier) // Turns 1% into more %
		return end_base_pay


/*=============================
==Species modifiers give small pay bonuses in specific departments
==based on how much NT likes them, how much they want the species to work there
==for example, Unathi is a combat-based species, so NT may prefer them in security
==since they can take a beating more.
=============================*/
proc/get_species_modifier(var/mob/living/carbon/human/M)
	if(M?.species && M.CharRecords)
		var/bonuspercentage = 0
		switch(M.species.name)
			if("Vat-Grown Human")
				bonuspercentage -= 20
			if(SPECIES_HUMAN)
				if(M.client.prefs.char_department & COM)
					bonuspercentage += 10
			if(SPECIES_RESOMI)
				bonuspercentage -= 10
				if(M.client.prefs.char_department & ENG)
					bonuspercentage += 10
				if(M.client.prefs.char_department & SCI)
					bonuspercentage += 5
				if(M.client.prefs.char_department & SEC)
					bonuspercentage -= 10
			if(SPECIES_TAJARA)
				bonuspercentage -= 10
				if(M.client.prefs.char_department & ENG)
					bonuspercentage += 10
				if(M.client.prefs.char_department & SCI)
					bonuspercentage += 5
				if(M.client.prefs.char_department & COM)
					bonuspercentage -= 10
				if(M.client.prefs.char_department & MED)
					bonuspercentage -= 5
			if(SPECIES_DIONA)
				bonuspercentage -= 95
				if(M.client.prefs.char_department & SCI)
					bonuspercentage += 5
				if(M.client.prefs.char_department & SRV|CIV)
					bonuspercentage -= 10
			if(SPECIES_VOX)
				bonuspercentage -= 20
				if(M.client.prefs.char_department & ENG)
					bonuspercentage += 10
				if(M.client.prefs.char_department & SEC)
					bonuspercentage += 5
				if(M.client.prefs.char_department & COM)
					bonuspercentage -= 10
				if(M.client.prefs.char_department & MED)
					bonuspercentage -= 10
			if(SPECIES_IPC)
				bonuspercentage -= 15
			if(SPECIES_UNATHI)
				if(M.client.prefs.char_department & SEC)
					bonuspercentage += 10
				if(M.client.prefs.char_department & MED)
					bonuspercentage -= 5
				if(M.client.prefs.char_department & SCI)
					bonuspercentage -= 5
			if(SPECIES_SKRELL)
				bonuspercentage += 5
				if(M.client.prefs.char_department & SCI)
					bonuspercentage += 10
				if(M.client.prefs.char_department & MED)
					bonuspercentage += 5
				if(M.client.prefs.char_department & SEC)
					bonuspercentage -= 5
			if(SPECIES_WRYN)
				bonuspercentage -= 40
				if(M.client.prefs.char_department & SRV|CIV)
					bonuspercentage += 10
				if(M.client.prefs.char_department & LOG)
					bonuspercentage += 5
				if(M.client.prefs.char_department & SCI)
					bonuspercentage -= 10
		return bonuspercentage