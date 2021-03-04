/*
GLOBAL_LIST_EMPTY(savefile_tracker)

/savefile/New()
	if(!locate(src) in savefile_tracker))
		savefile_tracker.Add(src)
	else
		src.Flush()
		del(src)
*/