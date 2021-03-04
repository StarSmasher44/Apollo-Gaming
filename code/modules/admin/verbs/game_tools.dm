/client/proc/generate_cpu_graph()
	set category = "Debug"
	set name = "CPU Graph"
	set desc = "Generates a graph of CPU and Tick Usage."

	if(!check_rights(R_SERVER))    return
	var/iterations = input("How many iterations do you want?", "iterations:") as num
	message_admins("[src.ckey] is generating a CPU/Tick Usage graph.")
	usr << "<b>Creating file and starting log.."
	var/f_name = "[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-[GLOB.clients.len]"
	var/csv = file("data/graphs/csv/[f_name].csv")
	csv << "Time,CPU,TICK"

	var/c = iterations/10				//Stores a cached version so we don't calculate x/10 every loop
	for(var/i = 1, i<=iterations; i++)
		csv << "[world.time],[world.cpu],[world.tick_usage]"
		if(!(i % c))		usr << "<b>\[GEN-LOG\] Collected [i]/[iterations] entries."
		sleep(world.tick_lag)

	usr << "<b>\[GEN-LOG\] Logs have been gathered - generating graph.</b>"

	if(!shell("python scripts/graph.py '[f_name]'"))			//returns 0 if run without error
		usr << "<span class='notice'>Graph generated and saved on server as data/graph/[f_name].png</span>"
		var/new_filename="data/graphs/[f_name].png"
		usr << ftp(new_filename,"[f_name].png")					//would be nicer in a window but I'd prefer to save it localy
		usr << file2text("data/graphs/data.txt")
	else
		usr << "<span class='warning'>An error occurred generating the graph, please contract a developer</span>"

// sends ahelps from the server to discord
/proc/send_discord(var/source, var/target = "1", var/message)
	shell("python scripts/discord_bot.py [source] [target] '[message]'") //For windows testing
//	shell("python scripts/discord_bot.py [source] [target] '[sanitize(message)]'")

/proc/command_discord(var/channel, var/author, var/message, var/prefix = "command")
	shell("python scripts/discord_bot.py [prefix] [channel] [author] '[sanitize(message)]'")	//Sent a message to a discord channel

/proc/discord_admin(var/client/C, var/admin, var/message, var/dir)
	if (copytext(message, 1, 6) == "angry")
		message = copytext(message, 6) // prune the angry part.
		C << 'sound/effects/adminhelp.ogg' //BOINK!
	C << "<span class='pm'><span class='in'>" + create_text_tag("pm_[dir ? "out" : "in"]", "", C) + " <b>\[DISCORD ADMIN PM\]</b> <span class='name'><b><a href='?priv_msg=\ref[C];discord=[admin]'>[admin]</a></b></span>: <span class='message'>[message]</span></span></span>"
	//STUI stuff
	log_admin("PM: [admin]->[key_name(C)]: [message]")
	//now send it back to slack
//	send_discord(admin, C.ckey, message)
	send_discord_message(1, message)

	//We can blindly send this to all admins cause it is from slack
	for(var/client/X in GLOB.admins)
		X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[admin]:</span> to <span class='name'>[key_name(C, X, 0)]</span>: <span class='message'>[message]</span></span></span>"