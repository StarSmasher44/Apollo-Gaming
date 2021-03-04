#define DONATOR_PERIOD 120 //Days, so approx. 4 months..

/proc/is_donator(client/C)
	if(!C)
		return 0
	return C.donator

/client/proc/Donator_Status()
	if(donator && donator < 4)
		var/expirationtime = donatorsince + (DONATOR_PERIOD DAYS) //Should mean 90 days.
		var/expirationtimeHalf = donatorsince + ((DONATOR_PERIOD/2) DAYS) //Should mean 90 days.
		if(world.realtime > expirationtime)
			to_chat(src, "<b><span class='donator[src.donator]'>Alert: Your donator period has ended. We thank you for your support, and hope you may support us again!</span></b>")
			message_admins("[src.key]'s donator status has ended. Please remove donator status from discord!")
			log_admin("[src.key]'s donator status has ended. Please remove donator status from discord!")
			src.donator = 0
			return 0
		else if(world.realtime > expirationtimeHalf) //90 Days / 2 = 45 days.
			src << "<b><span class='donator[src.donator]'>Alert: Your donator period is half-way through!</span></b>"
			return 1
	else
		if(donatorsince && !donator)
			donatorsince = null
	saveclientdb()


/client/verb/CheckDonator()
	set name = "Check Donator"
	set desc = "Checks your donation status"
	set category = "OOC"

	if(donator)		//swippity swoppity
		src << "You are registered as a Tier [donator] donator, thanks a lot!"
		src << "Donator Days Let: [((DONATOR_PERIOD DAYS) - donatorsince)]" //Should mean 90 days.
	else
		src << "You are not a registered donator. If you have donated please contact a member of staff to enquire."

/client/verb/cmd_don_say(msg as text)
	set category = "OOC"
	set name = "Donsay"
	set hidden = 1

	if(!msg)
		return

	if(!donator)
		if(!check_rights(R_ADMIN|R_MOD, 0))
			usr << "Only donators and staff can use this command."
			return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	log_admin("DON: [key_name(src)] : [msg]")
	for(var/client/C in GLOB.clients)
		if((C.holder && (C.holder.rights & R_ADMIN || C.holder.rights & R_MOD)) || C.donator)
			C << "<span class='donator[C.donator]'>" + create_text_tag("don", "DON:", C) + " <b>[src]: </b><span class='message'>[msg]</span></span>"
