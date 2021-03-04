
var/global/list/department_contracts = list()

/datum/deptcontracts
	var/list/contracts
	var/KWPrice

/datum/deptcontracts/New()
	KWPrice = rand(5, 30) //0.05 and 0.30 cents basically.

/datum/deptcontracts/contract
	var/contractor_name //Name of company.
	var/contractor_size //Size of company, roughly. defines in job.dm
	var/contract_type //defines in job.dm
	var/contract_amount
	var/price_setting // 1 = One sum, 2 = Per resource
	var/contract_price


datum/deptcontracts/contract/proc/get_amount()
	switch(contract_type)
		if(CONTRACT_SCI)
			switch(contractor_size)
				if(COMPANY_SMALL)
					contract_amount = round(rand(20, 60), 1) //Placeholder, but XRP is hard to get.
				if(COMPANY_MEDIUM)
					contract_amount = round(rand(75, 120), 1) //Placeholder, but XRP is hard to get.
				if(COMPANY_LARGE)
					contract_amount = round(rand(150, 500), 1) //Placeholder, but XRP is hard to get.
		if(CONTRACT_ENGI)
			switch(contractor_size)
				if(COMPANY_SMALL)
					contract_amount = round(rand(2000, 5000), 10) //Measured in KiloWatts (KW)
				if(COMPANY_MEDIUM)
					contract_amount = round(rand(6000, 9000), 10) //Measured in KiloWatts (KW)
				if(COMPANY_LARGE)
					contract_amount = round(rand(10000, 15000), 10) //Measured in KiloWatts (KW)

			var/Upper_KWP = KWPrice+rand(0.01, 0.10)
			var/Lower_KWP = KWPrice-rand(0.01, 0.10)
			var/P_KWPrice = rand(KWPrice-Lower_KWP, KWPrice+Upper_KWP) //Personal Price per KW for this company, which is somewhere around that days exchange rate.
			switch(price_setting)
				if(1)
					contract_price = (contract_amount*P_KWPrice)+rand(-5000, 2500) //Large bit backwards, small bit forward, who cares exploiting happens?
				if(2)
					contract_price = P_KWPrice
		if(CONTRACT_LOGI)
			switch(contractor_size)
				if(COMPANY_SMALL)
					contract_amount = round(rand(250, 500), 10) //Sheets in total
				if(COMPANY_MEDIUM)
					contract_amount = round(rand(500, 750), 10) //Sheets in total
				if(COMPANY_LARGE)
					contract_amount = round(rand(800, 1000), 10) //Sheets in total

/datum/deptcontracts/contract/New(var/ct = contract_type)
	contractor_name = "NanoTrasen" //Placeholder.
	if(ct)
		contract_type = ct
	else
		contract_type = pick(CONTRACT_SCI, CONTRACT_ENGI, CONTRACT_LOGI)
	price_setting = rand(1, 2)
	get_amount() // Gets contract_amount


/client/verb/GenerateContracts()
	set name = "Generate Contracts"
	set desc = "Generates Department Contracts"
	new /datum/deptcontracts()

	var/i //10 for now
	for(i=10, i>0, i--)
		var/datum/deptcontracts/contract/CON = new(department_contracts)
