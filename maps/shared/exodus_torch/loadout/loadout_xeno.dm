/datum/gear/suit/resomicoat
	display_name = "small coat (Resomi)"
	path = /obj/item/clothing/suit/storage/toggle/Resomicoat
	sort_category = "Xenowear"
	whitelisted = list(SPECIES_RESOMI)

// /datum/gear/uniform/smock
//	display_name = "smock selection (Resomi)"
//	path = /obj/item/clothing/under/resomi
//	whitelisted = list(SPECIES_RESOMI)
//	sort_category = "Xenowear"
//
// /datum/gear/uniform/smock/New()
//	..()
//	var/list/smocks = list()
//	for(var/smock in typesof(/obj/item/clothing/under/resomi/smock))
//		var/obj/item/clothing/under/resomi/smock/smock_type = smock
//		smocks[initial(smock_type.name)] = smock_type
//	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(smocks))

/datum/gear/uniform/undercoat
	display_name = "undercoat selection (Resomi)"
	path = /obj/item/clothing/under/resomi/undercoat
	whitelisted = list(SPECIES_RESOMI)
	sort_category = "Xenowear"

/datum/gear/uniform/undercoat/New()
	..()
	var/list/undercoats = list()
	for(var/undercoat in typesof(/obj/item/clothing/under/resomi/undercoat))
		var/obj/item/clothing/under/resomi/undercoat/undercoat_type = undercoat
		undercoats[initial(undercoat_type.name)] = undercoat_type
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(undercoats))

/datum/gear/suit/cloak
	display_name = "cloak selection (Resomi)"
	path = /obj/item/clothing/suit/storage/resomi/cloak
	whitelisted = list(SPECIES_RESOMI)
	sort_category = "Xenowear"

/datum/gear/suit/cloak/New()
	..()
	var/list/cloaks = list()
	for(var/cloak in typesof(/obj/item/clothing/suit/storage/resomi/cloak))
		var/obj/item/clothing/suit/storage/resomi/cloak/cloak_type = cloak
		cloaks[initial(cloak_type.name)] = cloak_type
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(cloaks))