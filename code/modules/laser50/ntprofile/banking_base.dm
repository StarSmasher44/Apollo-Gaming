#define SavMult 3000 //Interest = 2+(Amount/3000) = multiplier

var/global/list/bank_accounts = list()
var/global/interest_rate = 2 //Interest rate in percentage


/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/account_pin = 0
	var/bank_balance = 0





	var/saved_till //world.time of how long it will be stuck.
	var/savings_balance = 0 //Savings is locked-away money in return for interest rates.
	var/savings_level = 1 //Multiplier of interest rate.
	var/department = 0 //Is this a department account or a personal account?
	var/list/transaction_log = list()
	var/suspended = 0
	var/security_level = 1	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

	var/tmp/round_earns = 0 //The earnings and losses of this round. Are saved in a transaction type log.
	var/tmp/round_loss = 0

/datum/money_account/New()
	..()
	bank_accounts |= src
	all_money_accounts |= src


/datum/money_account/proc/set_savings(var/amount) //Sets up the savings account when someone tries to enter money to their savings account.
	if(amount && !department && !savings_balance) //Must have something to put in, and no department account.
		if(bank_balance < amount)
			to_chat(usr, "Unable to proceed, no availible funds.")
			return
		else
			bank_balance -= amount
			savings_balance = amount //Reduct from account and lock it up.
			saved_till = world.realtime + 7 DAYS

/datum/money_account/proc/check_savings()
	if(saved_till && savings_balance)
		if(saved_till < world.realtime) //X days have passed ,see above for X
			var/int_mult = 1 //Multiplier for interest rates, based on amount.
			int_mult = interest_rate*(savings_balance/SavMult)
			bank_balance += (savings_balance*(100+(interest_rate*int_mult)))

/datum/money_account/proc/do_transaction(var/datum/transaction/T)
	bank_balance = max(0, bank_balance + T.amount)
	transaction_log += T
	if(T.amount < 0) //Negative value, thus probably a loss.
		round_loss += T.amount
	else if(T.amount > 0)
		round_earns += T.amount

/datum/money_account/proc/get_balance()
	return bank_balance

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/datum/transaction/New(_target, _purpose, _amount, _source)
	..()
	date = stationdate2text()
	time = stationtime2text()
	target_name = _target
	purpose = _purpose
	amount = _amount
	source_terminal = _source

/datum/transaction/proc/sanitize_amount() //some place still uses (number) for negative amounts and I can't find it
	if(!istext(amount))
		return

	// Check if the text is numeric.
	var/text = amount
	amount = text2num(text)

	// Otherwise, the (digits) thing is going on.
	if(!amount)
		var/regex/R = regex("\\d+")
		R.Find(text)
		amount = -text2num(R.match)

/proc/charge_to_account(var/attempt_account_number, var/source_name, var/purpose, var/terminal_id, var/amount)
	var/datum/money_account/D = get_account(attempt_account_number)
	if(!D || D.suspended)
		return 0
	D.bank_balance = max(0, D.bank_balance + amount)

	//create a transaction log entry
	var/datum/transaction/T = new(source_name, purpose, amount, terminal_id)
	D.transaction_log.Add(T)

	return 1

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0)
	var/datum/money_account/D = get_account(attempt_account_number)
	if(D && D.security_level <= security_level_passed && (!D.security_level || D.account_pin == attempt_pin_number) )
		return D

/proc/get_account(var/account_number)
	for(var/datum/money_account/D in bank_accounts)
		if(D.account_number == account_number)
			return D

//ONLY USED BY DEPARTMENTS.
/proc/create_account(var/new_owner_name = "Default user", var/mob/living/carbon/human/owner, var/department = "")
	if(department)
		var/datum/money_account/MA = department_accounts[department]
		if(!MA)
			//create a new account
			var/datum/money_account/M = new()
			M.owner_name = new_owner_name
			M.account_pin = rand(1111, 111111)
			if(department)
				M.bank_balance = rand(1000, 2500)
			else
				M.bank_balance = rand(10, 400)
			if(department)
				M.department = department

			//create an entry in the account transaction log for when it was created
			var/datum/transaction/T = new()
			T.target_name = new_owner_name
			T.purpose = "Account creation"
			//set a random date, time and location some time over the past few decades
			T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
			T.time = "[rand(0,24)]:[rand(11,59)]"
			T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

			M.account_number = random_id("station_account_number", 111111, 999999)
			//add the account
			M.transaction_log.Add(T)
			return M