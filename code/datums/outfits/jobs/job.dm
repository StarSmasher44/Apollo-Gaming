/decl/hierarchy/outfit/job
	name = "Standard Gear"
	hierarchy_type = /decl/hierarchy/outfit/job

	uniform = /obj/item/clothing/under/color/grey
	l_ear = /obj/item/device/radio/headset
	shoes = /obj/item/clothing/shoes/black

	id_slot = slot_wear_id
	id_type = /obj/item/weapon/card/id/civilian
	pda_slot = slot_belt
	pda_type = /obj/item/device/pda

	flags = OUTFIT_HAS_BACKPACK

/decl/hierarchy/outfit/job/equip_id(mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/C = ..()
	if(H.mind && H.mind.initial_account)
		if(H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number
			if(!C.associated_account_number)
				C.associated_account_number = H.CharRecords.bank_account.account_number
	return C
