
/client/verb/GetSaves()
	set name = "Get savefiles"

	if(!holder)	return 0
	var/list/savefiles = list()

	for(var/savefile/SAVE)
		if(SAVE)
			savefiles += SAVE
		CHECK_TICK
	world << "Reported [savefiles.len] save files in world."
	world << "List: [dd_list2text(savefiles, "\n")]"
	switch(alert("Flush all saves? (Forces write of all pending changes)",,"Yes","No"))
		if("Yes")
			if(!savefiles.len)	return 0
			for(var/savefile/Save in savefiles)
				if(Save)
					Save.Flush()
		if("No")
			return 0