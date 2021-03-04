/client
	var/donator = 0 //Donator status ~ Tiers are 1, 2 and 3
	var/donatorsince
	var/ap_veteran = 0 //Is this player an Apollo Veteran? (custom assigned title)
	var/list/donatoritems = list()
	var/alien_whitelist //Alien whitelists
	var/command_whitelist //Head whitelists
	var/command_coin = 0 //The amount of coins this player has to trade in for a head-unlocked character.
	var/employee_coin = 0
	var/datejoined //The date the player first joined the server
	var/lastseen //The last time since we've seen the player (in days)
	var/enforcingmod //Enforcing moderator status
	var/list/iplogs = list() //List of most recent IPs
	var/list/cidlogs = list() //List of most recent computer IDs
	var/list/relatedaccounts = list() //List of (possible) related accounts
	var/list/achievements = list()
	var/list/warningsys = list() //reason = "", score = 0)
	var/savefile/playerdb //Not called clientDB to make sure I don't have to re-do everything.

/client/proc/saveclientdb(var/key = ckey)
	//Loading list of notes for this key
	if(!playerdb)	playerdb = new("data/player_saves/[copytext(key, 1, 2)]/[key]/clientdb.sav")
	playerdb["ckey"] << key
	playerdb["donator"] << donator
	playerdb["donatorsince"] << donatorsince
	playerdb["ap_veteran"] << ap_veteran
	playerdb["enforcingmod"] << enforcingmod
	playerdb["alien_whitelist"] << alien_whitelist
	playerdb["command_whitelist"] << command_whitelist
	playerdb["employee_coin"] << employee_coin
	playerdb["command_coin"] << command_coin
	playerdb["relatedaccounts"] << relatedaccounts
	playerdb["lastseen"] << lastseen
	playerdb["warningsys"] << warningsys
//	clientdb[""]

	playerdb.Flush() //Sends all final shit to his/her save file.

	return 1

/client/proc/loadclientdb(var/key = ckey)
	//Loading list of notes for this key
	if(!playerdb)	playerdb = new("data/player_saves/[copytext(key, 1, 2)]/[key]/clientdb.sav")
	playerdb["donator"] >> donator
	playerdb["donatorsince"] >> donatorsince
	playerdb["ap_veteran"] >> ap_veteran
	playerdb["alien_whitelist"] >> alien_whitelist
	LAZYINITLIST(alien_whitelist)
	if(!islist(alien_whitelist)) //In case old whitelist meets new.
		alien_whitelist = list()
	for(var/race in whitelisted_species)
		if(!alien_whitelist[race])
			alien_whitelist[race] = 0 //0 for not, 1 for yes

	playerdb["enforcingmod"] >> enforcingmod
	playerdb["command_whitelist"] >> command_whitelist
	playerdb["employee_coin"] >> employee_coin
	playerdb["datejoined"] >> datejoined
	playerdb["command_coin"] >> command_coin
	playerdb["relatedaccounts"] >> relatedaccounts
	if(!datejoined) // No join time set, so we assume he's new.
		datejoined = world.realtime
		playerdb["datejoined"] << datejoined
	playerdb["lastseen"] >> lastseen
	playerdb["warningsys"] >> warningsys
	return 1

/client/proc/refreshclientdb(var/key = ckey) // Refreshes the client DB with recent information.
	if(!playerdb)	playerdb = new("data/player_saves/[copytext(key, 1, 2)]/[key]/clientdb.sav")
	playerdb["iplogs"] >> iplogs
	if(!iplogs)
		iplogs = list()
	if(!iplogs.Find(address))
		iplogs.Add(address)
		if(iplogs.len > 10)
			iplogs.Cut(1, 2) // Remove oldest entry.
	playerdb["iplogs"] << iplogs
	sleep(0)
	playerdb["cidlogs"] >> cidlogs
	if(!cidlogs)
		cidlogs = list()
	if(!cidlogs.Find(computer_id))
		cidlogs.Add(computer_id)
		if(cidlogs.len > 10)
			cidlogs.Cut(1, 2) // Remove oldest entry.
	playerdb["cidlogs"] << cidlogs
	sleep(0)
	for(var/entry in userdb.dir)
		if(entry == src.ckey) //Skip those shits.
			continue
		var/tmp/curkey
		var/tmp/curip
		var/tmp/curcid
		userdb["[entry]"] >> curkey
		userdb["[entry]/cid"] >> curcid
		userdb["[entry]/adr"] >> curip
		if(curip && curcid)
			if(curip == src.address && curcid == src.computer_id)
				if(curkey != src.ckey || src.ckey != curkey) //Anything matches, but not the same username?
					var/message = "Possible match: [curkey] matched with [src.key] -- ([curcid]|[src.computer_id]) ([curip]|[src.address])"

					var/double = 0
					LAZYINITLIST(relatedaccounts)
					if(relatedaccounts.len)
						for(var/N in relatedaccounts)
							if(N == message)
								double = 1
								break
					if(!double)
						relatedaccounts |= message
	playerdb["relatedaccounts"] << relatedaccounts

	lastseen = world.realtime
	playerdb["lastseen"] << lastseen
	//Checking for not-notified warnings, and notifies.
	var/score
	for(var/datum/staffwarning/SW2 in warningsys)
		score += SW2.score
	for(var/datum/staffwarning/SW2 in warningsys)
		if(!SW2.notified)
			to_chat(src, "(Old Notification:)<br><span class='warning'><b>WARNING RECIEVED</b> You have recieved an official warning!\n Reason: [SW2.reason] | Score: [score]/[MAXWARNPOINTS]</span>")
			to_chat(src, "<span class='warning'>Remember that if you reach the maximum, a ban is automatically applied!</span>")
			SW2.notified = 1
/*
/client/proc/get_playerdb(var/key2 = ckey)
	if(!playerdb || isnull(playerdb))
		playerdb = new("data/player_saves/[copytext(key2, 1, 2)]/[key2]/clientdb.sav")
	else
		return playerdb
*/
/client/verb/get_days()
	set name = "Check Age"
	set desc = "Checks the age of your account on the server."
	set category = "OOC"
	usr << "Your account is [get_player_age()] day(s) old."