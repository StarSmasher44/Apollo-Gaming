/proc/send_discord_message(var/channel, var/message)
//	if(discord_token == "nodiscord")
//		return
	var/json_message = "{ \"content\" : \"[message]\" }"
	switch(channel)
		if(0) //Round announcements
			send_post_request("https://ptb.discordapp.com/api/webhooks/608760801142112382/V2Z2ZQ-koJ4ezRrZ5XdcRm6_jGUVUO5ZEUZJ-BbbMmpJ9LxmIYNVc99HuJUyqQ5HnSBF", json_message, "Content-Type: application/json")
		if(1) // Admin channel
			send_post_request("https://ptb.discordapp.com/api/webhooks/608759673125994528/JImzZl13CtmnAaCTcFm_e6neJleK5oJjGclSpol7A4rm6qn4GkWR8sku8BOm2ax3ITru", json_message, "Content-Type: application/json")

//		https://ptb.discordapp.com/api/webhooks/528606644687339562/rPZAo_DoAYBgkH1siXZ3szCHfl1hBiQS3-xbVXnZh3tFmmJQZBjOyWyx-G6fqUYtfDmA
//https://ptb.discordapp.com/api/webhooks/608759673125994528/JImzZl13CtmnAaCTcFm_e6neJleK5oJjGclSpol7A4rm6qn4GkWR8sku8BOm2ax3ITru
//	call("ByondPOST.dll", "send_post_request")("https://ptb.discordapp.com/api/webhooks/608759673125994528/JImzZl13CtmnAaCTcFm_e6neJleK5oJjGclSpol7A4rm6qn4GkWR8sku8BOm2ax3ITru", json_message, "Content-Type: application/json")
//	call("ByondPOST.dll", "send_post_request")("https://discordapp.com/api/channels/[discord_channels[channel]]/messages", json_message, "Authorization: [discord_token]", "Content-Type: application/json")