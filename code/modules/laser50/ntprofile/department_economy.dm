var/global/savefile/department_bank = new("data/department_accounts.sav")
var/global/list/department_accounts = list()

/proc/handle_bank_accounts(var/load = 1 /*If load = 0, save shit.*/) //Loads department bank accounts and that shit. Personal accounts go automatic.
	if(department_bank)
		if(load) //Load
			department_bank["dept_bank"] >> department_accounts
			LAZYINITLIST(department_accounts)
			LAZYINITLIST(bank_accounts)
		else
			if(department_accounts.len)
				department_bank["dept_bank"] << department_accounts

				department_bank.Flush()
	else
		world.log << "ERROR: No department_bank found."

/proc/find_double_accounts()
	for(var/datum/money_account/MA1 in department_accounts)
		for(var/datum/money_account/MA2 in department_accounts)
			if(MA1 == MA2)
				del(MA2) //Delete last.

/proc/economy_overview()
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Economy Overview Screen</title></head>"
	for(var/datum/money_account/MA in bank_accounts)
		if(MA.department)
			dat += "<b>DEPT ACC: [MA.owner_name] - $[MA.bank_balance] - SUS: [MA.suspended] - TRANS: [MA.transaction_log.len]</b><br>"
		else
			dat += "<b>USER ACC: [MA.owner_name] - $[MA.bank_balance] - SUS: [MA.suspended] - TRANS: [MA.transaction_log.len]</b><br>"
	for(var/datum/money_account/MA in department_accounts)
		dat += "<b>DEPT2 ACC: [MA.owner_name] - $[MA.bank_balance] - SUS: [MA.suspended] - TRANS: [MA.transaction_log.len]</b><br>"

	dat += "</html>"

	var/datum/browser/popup = new(usr, "Economy Overview","Economy Overview", 480, 600, src)
	popup.set_content(dat)
	popup.add_stylesheet("common", 'html/browser/common.css')
	popup.open()