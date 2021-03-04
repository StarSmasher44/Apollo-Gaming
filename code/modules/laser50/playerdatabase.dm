#define MAXWARNPOINTS 15

var/global/savefile/userdb = new("data/userdatabase.db")
var/global/datum/offlinedb/ODB

/datum/offlinedb
	var/screen = 0 // 0 = list, 1 = account screen
	var/selection //The name of the selected user.
	var/client/selectionclient //The client of the selected user if he is actually logged in
	var/global/list/userdblist = list()
	var/list/userwatchlist = list()

/proc/AddToDB(var/client/C)
	if(userdb && C)
		if(userdb["[C.ckey]"])
			//We gotta update their IP and CID with most recent info.
			userdb["[C.ckey]/cid"] << C.computer_id
			userdb["[C.ckey]/adr"] << C.address
			return 0 // Already in the DB, no action required.
		else
			userdb["[C.ckey]"] << C.ckey
			//Save IP and CID, only newest will remain.
			userdb["[C.ckey]/cid"] << C.computer_id
			userdb["[C.ckey]/adr"] << C.address

/proc/open_playerdb()
	if(!ODB)
		ODB = new()
	ODB.offline_player_database()

/datum/offlinedb/proc/save_watchlist()
	LAZYINITLIST(ODB.userwatchlist)
	userdb["watchlist"] << ODB.userwatchlist

/datum/offlinedb/proc/load_watchlist()
	userdb["watchlist"] >> ODB.userwatchlist
	LAZYINITLIST(ODB.userwatchlist)

/datum/offlinedb/proc/offline_player_database()//The new one
	if (!usr.client.holder)
		return
	if(!ODB)
		ODB = new(src)
	src = ODB
	var/dat = "<html><head><title>Admin Player Database</title></head>"
//	dat += "<a href='?src=\ref[ODB];choice=exit'><b>(EXIT)</b></a><hr>"
//	if(!ODB.userwatchlist.len) //Populate watch list upon entry.
//		ODB.load_watchlist()
	switch(screen)
		if(0)
			dat += "<h2>Watchlist & Notifications</h2><br>"
			dat += "<hr>"
//			if(!ODB.userdblist.len) //If no cache, create one now.
			LAZYINITLIST(ODB.userdblist)
			dat += "<div class='RowDisplay'><ul>"
			for(var/entry in userdb.dir)
				userdblist |= entry
				dat += "<li><a href='?src=\ref[ODB];choice=userdb;player=[entry]'><b>[entry]</b></a></li><br>"
			dat += "</ul></div>"
			dat += "</html>"
/*			else
				dat += "<div class='RowDisplay'><ul>"
				for(var/entry in ODB.userdblist) //Cached entries if any
					for(var/N in ODB.userwatchlist)
						if(findtext(N, entry)) //Found this man in the watch list?
							dat += "<li><a href='?src=\ref[ODB];choice=userdb;player=[entry]'><b><span class='warning'>[entry] (WATCH)</span></b></a></li><br>"
						else
							dat += "<li><a href='?src=\ref[ODB];choice=userdb;player=[entry]'><b>[entry]</b></a></li><br>"
				dat += "</ul></div>"
*/
//			dat += "</html>"
		if(1)
			if(ODB.selection) //Player has been chosen.
				ODB.setuser(ODB.selection)
				if(!ODB.selection)	return
				var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")
				var/lastseen = round((world.realtime - clientdb["lastseen"]) / 864000, 0.1)
				var/watched = 0
				for(var/N in ODB.userwatchlist)
					if(findtext(N, selection)) //Found this man in the watch list?
						watched = 1
				var/banned = ""
				var/baninfo = CheckBan(selection, userdb["[ODB.selection]/cid"], userdb["[ODB.selection]/adr"])
				if(baninfo)
					banned = baninfo["desc"]
				dat += {"
					<body>
					<h2>[watched ? "<span class='warning'>[ODB.selection] User DB (WATCH)</span>" : "<h2>9[ODB.selection] User DB</h2>"]
					<hr>
					<h3>Account Info:</h3><br>
					<b>Ban Status:</b> [banned ? "<span class='warning'>Player Banned ([banned])</span>" : "Not banned currently"]<br>
					<b>Watch Status:</b> [watched ? "<span class='warning'>ON WATCH</span>" : "<b>OFF WATCH</b>"]
					<h3><b>General Info:</b></h3><br>
					"}

				if(ODB.selectionclient)
					dat += "<b>Last Seen:</b> <font color='green'>Online</font><br>"
				else
					dat += "<b>Last Seen:</b> [lastseen > 6725 ? "Unknown": "[lastseen]"] Days Ago"
				dat += {"
					<b>Join Date:</b> [time2text(clientdb["datejoined"])] ([round((world.realtime - clientdb["datejoined"]) / 864000, 0.1)] Days Old)<br>
					<b>Whitelists:</b> Species: [clientdb["alien_whitelist"]]<br>
					<b>Donator Info:</b> [clientdb["donator"] ? "Donator Tier [clientdb["donator"]] Since [time2text(clientdb["donatorsince"])]" : "N/A"]
					<b>Apollo Veteran:</b> [clientdb["ap_veteran"] ? "Yes" : "No"]<br>
					<b>Coins:</b> COM:[clientdb["command_coin"] ? "[clientdb["command_coin"]]" : "0"] EMPLOY:[clientdb["employee_coin"] ? "[clientdb["employee_coin"]]" : "0"]
					<hr>
					<h3>Account Security:<h3>
					"}
				var/list/Related = clientdb["relatedaccounts"]
				LAZYINITLIST(Related)
				if(Related.len)
					dat += "<b>Related accounts:</b><br>"
					for(var/ENT in Related)
						dat += "[ENT]  (<a href='?src=\ref[ODB];selected=removerelate;text=\ref[ENT]'>(X)</a>)<br>"
				dat += {"
				<b>Administrative Options:</b><br>
				<a href='?src=\ref[ODB];selected=ban'>Ban Player</a><br>
				<a href='?src=\ref[ODB];selected=jobban'>jobban Player</a><br>
				<a href='?src=\ref[ODB];selected=whitelist'>Set Whitelist/Donator/Veteran/Coins</a><br>
				<a href='?src=\ref[ODB];selected=warning'>Warnings Menu</a><br>
				<a href='?src=\ref[ODB];selected=watchlist'>Add/Remove Watch List</a><br>
				</body>
				"}
			dat += "<b><a href='?src=\ref[ODB];choice=return'>Return</a></b><br>"
			dat += "</html>"
//				usr << browse(dat, "window=playerdb;size=600x480")

	var/datum/browser/popup = new(usr, "Player Database","Player Database", 620, 740, src)
	popup.set_content(dat)
	popup.add_stylesheet("common", 'html/browser/common.css')
	popup.set_window_options("focus=0;can_close=1;can_minimize=0;can_maximize=0;can_resize=1;titlebar=1;")
	popup.open()


/datum/staffwarning
	var/reason = ""
	var/score = 0
	var/maker = ""
	var/notified = 0 //If person is notified of his/her warning.

/datum/offlinedb/proc/setuser(var/selected) //selected = client key
	if(selected)
		for(var/client/C in GLOB.clients)
			if(C.ckey == selected)
				ODB.selection = C.ckey
				ODB.selectionclient = C

/datum/offlinedb/proc/WarningSystem(var/selected)
	if (!usr.client.holder)
		return
	if(!ODB.selection)
		return
	var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")
	var/dat = "<html><head><title>Warning System [ODB.selection]</title></head><hr>"
	var/list/Warns = clientdb["warningsys"]
	LAZYINITLIST(Warns)
	var/points = 0
	if(Warns.len)
		for(var/datum/staffwarning/warn in Warns)
			points += warn.score
	dat += {"
	<style>
	table {
		font-family: arial, sans-serif;
		border-collapse: collapse;
		width: 100%;
	}

	td, th {
		border: 1px solid #dddddd;
		text-align: left;
		padding: 8px;
	}
</style>
"}
	dat += {"
	<b>Total Warnings:</b> [Warns.len]<br>
	<b>Warning Points:</b> [points < 10 ? "[points] out of [MAXWARNPOINTS]" : "<span class='warning'>[points] out of [MAXWARNPOINTS]</span>"]<br>
	<hr>
	<b><a href='?src=\ref[src];warnpage=setwarn'>Set Warning</a></b> | <b><a href='?src=\ref[src];warnpage=removewarn'>Return</a></b>
	<hr>
	<table>
	<tr>
	<th>Warning</th>
	<th>Warning Points</th>
	<th>Warned by</th>
	</tr>
	"}
	if(Warns.len)
		for(var/datum/staffwarning/SW in Warns)
			dat += {"
			<tr>
			<td>[SW.reason]</td>
			<td>[SW.score]</td>
			<td>[SW.maker]</td>
			</tr>
			"}
	usr << browse(dat, "window=playerdb_warns;size=600x480")


/datum/offlinedb/Topic(href, href_list[])
	. = ..()
	switch(href_list["choice"])
		if("userdb")
			for(var/client/C in GLOB.clients)
				if(C.ckey == ODB.selection)
					ODB.selection = C.ckey
					ODB.selectionclient = C
			if(!ODB.selection)
				ODB.selection = href_list["player"]
			if(!ODB.selection)
				return to_chat(usr, "Unknown system error occurred, could not retrieve profile.")
			else
				screen = 1
			. = TOPIC_REFRESH
		if("return")
			ODB.selection = null
			ODB.selectionclient = null
			screen = 0
			. = TOPIC_REFRESH
	switch(href_list["warnpage"])
		if("setwarn")
			if(ODB.selection)
				var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")
				var/reason = input("Reason for warning?", "Give Warning") as text
				if(!reason)	return to_chat(usr, "No reason specified, aborting.")
				var/points = input("What is the weight of this warning? (0-5)", "Warning Score") as num
				if(!points) points = 0
				var/list/L = clientdb["warningsys"]
				LAZYINITLIST(L)
				var/totalscore = 0
				if(L.len)
					for(var/datum/staffwarning/SW2 in L)
						totalscore += SW2.score
				var/ban
				if((totalscore+points) >= 15) //Hits or goes above the ban limit
					ban = alert("This will set [ODB.selection]'s score to [totalscore+points]/[MAXWARNPOINTS]. Set to 14 or (permanently) Ban?", "Max Points Reached!", "Ban", "Reduce")
				switch(ban)
					if("Ban")
						var/ip = userdb["[ODB.selection]/adr"]
						var/cid = userdb["[ODB.selection]/cid"]
						var/uckey = ckey(ODB.selection)
						AddBan(uckey, cid, "AUTOBAN: Due to too high warning score ([totalscore+points]/[MAXWARNPOINTS])", usr.ckey, 0, 0, ip)
						ban_unban_log_save("[usr.client.ckey] has banned [uckey]. - Reason: [reason] - This is a permanent ban.")
						notes_add(uckey,"[usr.client.ckey] has banned [uckey]. - Reason: [reason] - This is a permanent ban.",usr)
						if(ODB.selectionclient)
							to_chat(ODB.selectionclient, "<span class='danger'>You have been banned by [usr.client.ckey].\nReason: [reason].</span>")
							to_chat(ODB.selectionclient, "<span class='warning'>This is a permanent ban.</span>")
						if(ODB.selectionclient)
							if(config.banappeals)
								to_chat(ODB.selectionclient, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
							else
								to_chat(ODB.selectionclient, "<span class='warning'>No ban appeals URL has been set.</span>")
						log_and_message_admins("has banned [uckey].\nReason: [reason]\nThis is a permanent ban.")
						if(ODB.selectionclient)
							qdel(ODB.selectionclient)

					if("Reduce")
						points = (15-totalscore) //Unsure?

				totalscore += points
				notes_add(ckey(ODB.selection),"[usr.client.ckey] had applied a warning to [ODB.selection]. - Reason: [reason]",usr)

				var/datum/staffwarning/SW = new
				SW.reason = reason
				SW.score = points
				SW.maker = usr.client.ckey
				if(ODB.selectionclient)
					SW.notified = 1
				L.Add(SW)


				clientdb["warningsys"] << L
				to_chat(usr, "Warning has been given to [ODB.selection]")
				message_admins("[key_name_admin(usr)] has given a warning to [ODB.selection]. (+[points] = [totalscore]/[MAXWARNPOINTS])")
				if(ODB.selectionclient)
					to_chat(ODB.selectionclient, "<span class='warning'><b>WARNING RECIEVED</b> You have recieved an official warning!\n Reason: [reason] | Score: [totalscore]/[MAXWARNPOINTS]</span>")
					to_chat(ODB.selectionclient, "<span class='warning'>Remember that if you reach the maximum, a ban is automatically applied!</span>")

		if("removewarn")
			return
	switch(href_list["selected"])
		if("ban")
			if(!check_rights(R_MOD,0) && !check_rights(R_BAN, 0))
				to_chat(usr, "<span class='warning'>You do not have the appropriate permissions to add bans!</span>")
				return

			if(check_rights(R_MOD,0) && !check_rights(R_ADMIN, 0) && !config.mods_can_job_tempban) // If mod and tempban disabled
				to_chat(usr, "<span class='warning'>Mod jobbanning is disabled!</span>")
				return
			var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")
			var/ckey = ckey(ODB.selection)

			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					if(check_rights(R_MOD, 0) && !check_rights(R_BAN, 0) && mins > config.mod_tempban_max)
						to_chat(usr, "<span class='warning'>Moderators can only job tempban up to [config.mod_tempban_max] minutes!</span>")
						return
					if(mins >= 525600) mins = 525599
					var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
					if(!reason)
						return
					var/ip = clientdb["[ODB.selection]/adr"]
					var/cid = clientdb["[ODB.selection]/cid"]

					AddBan(ckey, cid, reason, usr.ckey, 1, mins, ip)
					ban_unban_log_save("[usr.client.ckey] has banned [ODB.selection]. - Reason: [reason] - This will be removed in [mins] minutes.")
					notes_add(ckey,"[usr.client.ckey] has banned [ODB.selection]. - Reason: [reason] - This will be removed in [mins] minutes.",usr)
					feedback_inc("ban_tmp",1)
					log_and_message_admins("has banned [ODB.selection].\nReason: [reason]\nThis will be removed in [mins] minutes.")

				if("No")
					if(!check_rights(R_BAN))   return
					var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
					if(!reason)
						return
					var/ip = userdb["[ODB.selection]/adr"]
					var/cid = userdb["[ODB.selection]/cid"]
					AddBan(ckey, cid, reason, usr.ckey, 0, 0, ip)
					ban_unban_log_save("[usr.client.ckey] has permabanned [ODB.selection]. - Reason: [reason] - This is a ban until appeal.")
					notes_add(ckey,"[usr.client.ckey] has permabanned [ODB.selection]. - Reason: [reason] - This is a ban until appeal.",usr)
					log_and_message_admins("has banned [ODB.selection].\nReason: [reason]\nThis is a ban until appeal.")
					feedback_inc("ban_perma",1)
				if("Cancel")
					return
		if("jobban")
			return
		if("whitelist")
			var/type = input("Select what type of whitelist", "Add User to Whitelist") in list("Coins", "Alien Whitelist", "Donators", "Veterans")
			var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")

			var/aor = alert("Add or Remove from list?", "Whitelist editing", "Add", "Remove", "Abort")
			if(!aor && type != "Coins")	return 0
			if(aor == "Abort")	return 0
			switch(type)
				if("Coins")
					var/cointype = input("Select what type coin", "Grant Admin Coins") in list("Command Coin", "Employee Coin")
					switch(cointype)
						if("Command Coin")
							var/coins = input("Amount of coins?", "Give Employee Coins") as num
							clientdb["command_coin"] >> coins
							coins = coins+ODB.selectionclient.command_coin
							coins += 1
							clientdb["command_coin"] << coins
							ODB.selectionclient.command_coin = coins
							message_admins("[key_name_admin(usr)] has awarded [ODB.selection] a [cointype].")
							to_chat(ODB.selectionclient, "You have been awarded a [cointype]!")
						if("Employee Coin")
							var/coins = input("Amount of coins?", "Give Employee Coins") as num
							clientdb["employee_coin"] >> coins
							coins = coins+ODB.selectionclient.employee_coin
							coins += 1
							clientdb["employee_coin"] << coins
							ODB.selectionclient.employee_coin = coins
							message_admins("[key_name_admin(usr)] has awarded [ODB.selection] a [cointype].")
							to_chat(ODB.selectionclient, "You have been awarded a [cointype]!")
				if("Alien Whitelist")
					var/datum/species/race = input("Which species?") as null|anything in whitelisted_species
					if(!race)
						return 0
					var/alienlist = clientdb["alien_whitelist"]
					LAZYINITLIST(alienlist)
					if(aor == "Remove" && alienlist)
						var/reason = input("Reason for removal?", "Alien whitelist removal") as text
						if(!reason)	return to_chat(usr, "No reason specified, aborting.")
						alienlist["[race.name]"] = 0
						clientdb["alien_whitelist"] << alienlist
						notes_add(ckey(ODB.selection),"[usr.client.ckey] removed alien whitelist ([race.name]) from [ODB.selection]. - Reason: [reason]",usr)
						to_chat(usr, "whitelist for [race.name] removed from [ODB.selection]")
						message_admins("[key_name_admin(usr)] has de-whitelisted [ODB.selection] for species [race.name]")
					else
						alienlist["[race.name]"] = 1
						message_admins("[key_name_admin(usr)] has whitelisted [ODB.selection] for [race].")
						to_chat(ODB.selectionclient, "You are now whitelisted for [race]! Remember to read their lore! (List: [alienlist])")
						clientdb["alien_whitelist"] << alienlist
				if("Donators")
					var/donator = clientdb["donator"]
					if(aor == "remove" && donator)
						var/reason = input("Reason for removal?", "donator status removal") as text
						if(!reason)	return to_chat(usr, "No reason specified, aborting.")
						notes_add(ckey(ODB.selection),"[usr.client.ckey] removed donator status from [ODB.selection]. - Reason: [reason]",usr)
						to_chat(usr, "Donator status removed from [ODB.selection]")
						message_admins("[key_name_admin(usr)] has removed donator status from [ODB.selection].")
					else
						if(donator)
							usr << "<span class='warning'>Could not add [ODB.selection] to donators. Already a donator.</span>"
							return 0
						var/tier = input("What Donator Tier? (Tier 1-3)", "Donator tier") as num
						if(tier && tier <= 4 && tier >= 0)
							donator = tier
							message_admins("[key_name_admin(usr)] has added [ODB.selection] (Tier [tier]) as a donator.")
							to_chat(ODB.selectionclient, "You are now a donator! Thank you for donating! (Tier [tier])")
							clientdb["donatorsince"] << world.realtime
					if(donator && donator <= 4)
						clientdb["donator"] << donator
						ODB.selectionclient.donator = donator
				if("Veterans")
					var/veteran = clientdb["ap_veteran"]
					if(aor == "remove" && veteran)
						var/reason = input("Reason for removal?", "veteran status removal") as text
						if(!reason)	return to_chat(usr, "No reason specified, aborting.")
						notes_add(ckey(ODB.selection),"[usr.client.ckey] removed veteran status from [ODB.selection]. - Reason: [reason]",usr)
						to_chat(usr, "Veteran status removed from [ODB.selection]")
						message_admins("[key_name_admin(usr)] has removed veteran status from [ODB.selection].")
						clientdb["ap_veteran"] << veteran
					else
						if(veteran)
							usr << "<span class='warning'>Could not add [ODB.selection] to veterans. Already a veteran.</span>"
							return 0
						veteran = 1
						ODB.selectionclient.ap_veteran = 1
						message_admins("[key_name_admin(usr)] has added [ODB.selection] as a veteran.")
						to_chat(ODB.selectionclient, "You are now a Apollo Veteran!")
						clientdb["ap_veteran"] << veteran
		if("warning")
			WarningSystem(ODB.selection)
		if("removerelate")
			var/toremove = locate(href_list["text"])
//			world << "Toremove is [toremove]"
			var/savefile/clientdb = new("data/player_saves/[copytext(ODB.selection, 1, 2)]/[ODB.selection]/clientdb.sav")
			if(toremove && ODB.selection)
				switch(alert("Are you sure you wish to delete this entry?","Remove Entry","Yes","No"))
					if("Yes")
						var/list/Related = clientdb["relatedaccounts"]
						LAZYINITLIST(Related)
						if(Related.len)
							for(var/N in Related)
								if(N == toremove)
									Related.Remove(N)
							clientdb["relatedaccounts"] << Related
					else
						to_chat(usr, "Cancelled.")
						return
		if("watchlist")
			to_chat(usr, "Coming soon, notify laser he forgot if you see this.")
			return
	if(. == TOPIC_REFRESH)
		ODB.offline_player_database()
//	offline_player_database() //Refreshes the panel, hopefully.