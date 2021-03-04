var/global/datum/ResearchProcess/XRP

var/difficulty = 512
var/mhashes = 0
var/MaxDif = mhashes*512 //Difficulty can only go *512
var/MinDif = mhashes*128

#define MHPercentMod = 0.50 // 1 MH = 0.5% time taken off.

var/timetotake = 600 //10 Minutes to seconds. (1 minute to 60 for test)
						// world.timeofday = 1/10th of a second to *10 to fix it again.
var/difficultypercentage = 100 //100% of timetotake, of course.

/datum/ResearchProcess
	var/active = 0 //Starts off.
	var/starttime
	var/endtime
	var/blockfound = 0
	var/blocksfound = 0
	var/averagetime
	var/num

//Calculates the difficulty modification factor.
/datum/ResearchProcess/proc/CalcDiff(var/endtimer = endtime)
	if(endtimer)
		var/diffmod = (timetotake / endtimer)
		if(diffmod < 0.85)
			diffmod = 0.85
		if(diffmod > 1.40)
			world << "Ok"
			diffmod = 1.40

		difficulty = max(MinDif, round(difficulty*diffmod, 1))
//		difficulty = min(difficulty, MaxDif)
		world << "Diffmod = [diffmod]"

/datum/ResearchProcess/proc/BlockFound()
	if(blockfound == 1)
		blocksfound++
		var/diffmod = (timetotake / endtimer) //We keep the modifier to adjust the percentage to deal with large server addition spams.
		if(diffmod < 0.75)
			diffmod = 0.75
		if(diffmod > 1.25)
			diffmod = 1.25
		timetotake = max(round(timetotake*diffmod, 1))

/datum/ResearchProcess/proc/BeginPointGen()
	starttime = world.timeofday //Begin first iteration counter.
	num = rand(0, difficulty)
	while(src && active)
		src.GeneratePoints()
		sleep(world.tick_lag * 16)

/datum/ResearchProcess/proc/GeneratePoints()
	if(mhashes > 0)
		var/runtime = mhashes
		if(blockfound)
			starttime = world.timeofday
			num = rand(0, difficulty)
			blockfound = 0
		while(runtime > 0)
			if(rand(0, difficulty) == num)
				//Block Found!
				endtime = (world.timeofday - starttime)/10
				if(endtime < (timetotake/4)) // But it was really fast, contain the randomness factor!
					break //No rewards for cheap randomization.
				endtime = (world.timeofday - starttime)/10
				blockfound = 1
				BlockFound
				break
			else
				var/curtime = (world.timeofday - starttime)/10
				if(curtime > timetotake*4) //Seems to be severely late?
					blockfound = 1
					CalcDiff()
			sleep(-1)
	else
		//Servers are offline or we have no CPU power.. Sleep it off bro!
		sleep(300)