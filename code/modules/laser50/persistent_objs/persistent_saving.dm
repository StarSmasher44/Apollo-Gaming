/*----------------INNER WORKINGS PERSISTENCY MODULE------------------*/
// Basically, we split our objects into 2 categories:
// 1. Persistent Objects: These are simply persistent objects that are frozen in their place, anchored usually. Unless their location changes.
// 2. Dynamic Persistent Objects: These are objects that aren't stuck, and can be moved anywhere.

// var/global/savefile/persistent_objs = new("data/persistent_objs.sav") //Savefile for objects, may use .txt instead.
var/global/datum/persistentsave/persistent_save

/datum/persistentobj
	//Location of Object
	var/x
	var/y
	var/z
	//Usually object.name
	var/name
	// If the object is dynamic or not, dynamic objects (Must be round-created, not map-spawned!!!!) move position from time to time.
	var/dynamic = 0
	var/newobj = 1 //If it is a new saved type.
	//The full path of the object
	var/objtype
	var/tmp/obj/SelectedObj
	//The variables we want to save extra.
	var/list/extravars
	var/list/changedvars

/datum/persistentsave
	var/list/tosave //List of objects to save (At the end of the round)
	var/list/objectstorage //List of all persistent object datums.
	var/list/toload //List of objects to load
	var/pers_file = "data/persistent_objs.txt"
	var/savefile/pers_db = new("data/persistent_db.sav")

/datum/persistentsave/New()
	persistent_save = src
	LAZYINITLIST(persistent_save.tosave)
	LAZYINITLIST(persistent_save.toload)
	LAZYINITLIST(persistent_save.objectstorage)
	if(!pers_db)
		pers_db = new("data/persistent_db.sav")

/* List of to-make-persistent shit
	- Vending machine contents
	- Medical 'vending machine' contents
	- Science servers (En alle componenten)
*/


/*
STAPPENPLAN:
1. HAAL ONNODIGE STANDAARD VARS UIT DE LIJST.
2. ZET OBJ.VARS OVER NAAR PARAMS (TEXT) MET LIST2PARAMS
3. ZET OBJ PARAMS IN NIEUWE LIST.
4. COMBINEER OUDE EN NIEUWE LIST.
*/

/client/verb/AddToList(var/M as obj in range())
	set name = "Add to list"
	if(M)
		persistent_save.tosave += M

/client/verb/SaveAll()
	set name = "Save list"
	persistent_save.Convert_Objs()
	sleep(-1)
	persistent_save.Save_Objs()

/client/verb/LoadAll()
	set name = "Load list"
	persistent_save.Load_Objs()

#warn Dynamic variable in saving isn't set or changed anywhere.

/hook/shutdown/proc/SavePersistentObjs()
	persistent_save.Convert_Objs()
	sleep(-1)
	persistent_save.Save_Objs()
/*
1. Obj is added to tosave list for saving.
2. tosave is saved via save_objs()
2. Object is saved, and removed from tosave.
2A. How do we save objects after the happening EG round end?
^^ Call saveObjs() on round end, fuck destroyed objects.
*/

//Function to save all objects that exsist, dynamics get their status updated.
/datum/persistentsave/proc/Save_Objs()
	for(var/datum/persistentobj/PO in persistent_save.objectstorage)
		if(PO.SelectedObj)
			if(PO.dynamic)
				if(PO.x != PO.SelectedObj.x)
					PO.x = PO.SelectedObj.x
				if(PO.y != PO.SelectedObj.y)
					PO.y = PO.SelectedObj.y
				if(PO.z != PO.SelectedObj.z)
					PO.z = PO.SelectedObj.z
	if(persistent_save.objectstorage && persistent_save.objectstorage.len)
		pers_db["Objects"] << persistent_save.objectstorage

//Function to convert everything in tosave to object storage datums.
/datum/persistentsave/proc/Convert_Objs()
//	if(!objectstorage || !objectstorage.len)
//		pers_db["Objects"] >> objectstorage
	if(persistent_save.tosave && persistent_save.tosave.len)
		for(var/atom/movable/OBJ in persistent_save.tosave)
			if(OBJ)
				var/datum/persistentobj/PO = new()
				PO.x = OBJ.x
				PO.y = OBJ.y
				PO.z = OBJ.z
				PO.SelectedObj= OBJ
				if(OBJ.anchored)
					PO.dynamic = 1
//				if(locate(OBJ) in
				SpecialVarCheck(OBJ, PO)
				for(var/datum/persistentobj/POJ in persistent_save.objectstorage)
					if(POJ.x == PO.x && POJ.y == PO.y && POJ.z == PO.z)
						if(PO.name == POJ.name && PO.objtype == POJ.objtype)
							//PROBABLY MATCHES, DOUBLE ENTRY?
							del(POJ) //Remove oldest entry, I guess?
				PO.name = OBJ.name
				PO.objtype = OBJ.type
				persistent_save.objectstorage.Add(PO)
				persistent_save.tosave.Remove(OBJ)


/datum/persistentsave/proc/Load_Objs()
	pers_db["Objects"] >> persistent_save.toload
	LAZYINITLIST(persistent_save.toload)
	world << "LEN: [persistent_save.toload.len]"
	if(persistent_save.toload && persistent_save.toload.len)
		world << "1"
		persistent_save.objectstorage = persistent_save.toload
		for(var/datum/persistentobj/PO in persistent_save.toload) //Same list any way
			world << "[PO.objtype]"
			var/atom/movable/AM = new PO.objtype()
			ResetObject(AM)
			AM.name = PO.name
			var/turf/T = locate(PO.x, PO.y, PO.z)
			var/atom/movable/double = locate(AM.type) in T
			if(double && double != AM) //Hit
				AM.pixel_y = double.pixel_y
				AM.pixel_x = double.pixel_x
				AM.pixel_z = double.pixel_z
				qdel(double)
			AM.loc = locate(PO.x, PO.y, PO.z)
			PO.SelectedObj = AM
			var/obj/structure/closet/InStorage = locate() in T
			if(InStorage)
				AM.loc = InStorage
			LAZYINITLIST(PO.extravars)
			LAZYINITLIST(PO.changedvars)
//			if(PO.changedvars.len)
//				for(var/variable in AM.vars)
//					if(PO["[variable]"] == AM.vars["[variable]"])
//						var/amvar = AM.vars["[variable]"]
//						AM[amvar == PO["[variable]"]

			if(PO.extravars.len) //Has extra vars
				if(PO.extravars["component_parts"])
					var/list/parts = PO.extravars["component_parts"]
					if(parts)
						AM:component_parts = parts
				if(PO.extravars["cell"])
					var/celltype = PO.extravars["cell"]
					var/obj/item/weapon/cell/C = new celltype(AM:cell)
					C.charge = PO.extravars["ccharge"]

				if(PO.extravars["pixelxyz"])
					var/list/Pixyz = list()
					for(var/line in splittext(PO.extravars["pixelxyz"], "-"))
						Pixyz.Add(line)
					if(Pixyz.len)
						AM.pixel_x = Pixyz[1]
						AM.pixel_y = Pixyz[2]
						AM.pixel_z = Pixyz[3]
				if(PO.extravars["notpapers"])
					var/list/PaperInfo = list()
					for(var/line in splittext(PO.extravars["notpapers"], "-"))
						PaperInfo.Add(line)
					var/i= 0
					for(i=0, i<(PaperInfo.len/3), i++) //Makes papers happen.
						var/obj/item/weapon/paper/P = new(AM:contents)
						var/turf/loc = locate(PO.x, PO.y, PO.z)
						P.loc = loc
						P.name = PaperInfo[1]
						P.info = PaperInfo[2]
						var/list/stamps = list()
						stamps = splittext(PaperInfo[3], ";")
						for(var/stamper in stamps)
							var/obj/item/weapon/stamp/stamper2 = new stamper()
							P.stamped.Add(stamper2)
			AM.Initialize() //Init the thing.

//				var/list/Avars = A.vars
//				for(var/variable in Avars)
//					if(variable == initial(variable)) //If the variable hasnt changed, we don't need to save it.
//						Avars["variable"] -= variable
//				var/obj_vars = list2params(A.vars)
//				obj_vars += "\n"
//				allobjs.Add(obj_vars)
//		for(var/line in splittext(file2text(persistent_save.pers_file), "\n"))
//			allobjs.Add(line)
//		var/list/allobjs = file2list(pers_file, "\SKIP") //Gets all entries from the files.
//		if(allobjs.len && newobjs.len)
//			allobjs |= newobjs
//		world << "allobjs = [allobjs.len]"
//		fdel(persistent_save.pers_file)
//		for(var/N in allobjs)
//			text2file(N, persistent_save.pers_file)

/datum/persistentsave/proc/SpecialVarCheck(var/atom/movable/AM, var/datum/persistentobj/PO, var/type = 0) //Checks the to-save item for any vars we need to keep.
	if(type == 0)
		LAZYINITLIST(PO.extravars)
		LAZYINITLIST(PO.changedvars)
		for(var/variable in AM.vars)
			if(variable != initial(variable))
				PO.changedvars |= variable["[variable]"]
			if(variable == "cell")
				PO.extravars["cell"] = AM:cell.type //Only save type.
				PO.extravars["ccharge"] = AM:cell.charge
			if(variable == "power_supply")
				PO.extravars["cell"] = AM:power_supply.type //Only save type.
				PO.extravars["ccharge"] = AM:power_supply.charge
	else
		LAZYINITLIST(PO.extravars)
//		if(AM.vars["component_parts"])
//			PO.extravars["component_parts"] = AM:component_parts
		if(AM.vars["cell"])
			PO.extravars["cell"] = AM:cell.type //Only save type.
			PO.extravars["ccharge"] = AM:cell.charge
		if(AM.pixel_x != 0 || AM.pixel_y != 0 || AM.pixel_z != 0)
			PO.extravars["pixelxyz"] = "[AM.pixel_x]-[AM.pixel_y]-[AM.pixel_z]"
		if(istype(AM, /obj/structure/noticeboard)) //Save papers too in weird af format.
			var/list/papers = list()
			//List goes like; [1] = text, [2] = stamps.
			for(var/obj/item/weapon/paper/P in AM.contents)
				var/stamplist = ""
				for(var/obj/item/weapon/stamp/ST in P.stamped)
					stamplist += "[ST.type];"
				papers.Add("[P.name]-[P.info]-[stamplist]")
			PO.extravars["notpapers"] = papers

//A very simple piece of code that resets objects to their origional setup, used to try to fix weird vars.
/datum/persistentsave/proc/ResetObject(var/atom/movable/AM)
	for(var/variable in AM.vars)
		variable = initial(variable)
		CHECK_TICK