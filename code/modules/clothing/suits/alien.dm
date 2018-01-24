//Unathi clothing.

/obj/item/clothing/suit/unathi/robe
	name = "roughspun robes"
	desc = "A traditional Unathi garment."
	icon_state = "robe-unathi"
	item_state = "robe-unathi"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/suit/unathi/mantle
	name = "hide mantle"
	desc = "A rather grisly selection of cured hides and skin, sewn together to form a ragged mantle."
	icon_state = "mantle-unathi"
	item_state = "mantle-unathi"
	body_parts_covered = UPPER_TORSO

//Taj clothing.

/obj/item/clothing/suit/tajaran/furs
	name = "heavy furs"
	desc = "A traditional Zhan-Khazan garment."
	icon_state = "zhan_furs"
	item_state = "zhan_furs"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS

/obj/item/clothing/head/tajaran/scarf
	name = "headscarf"
	desc = "A scarf of coarse fabric. Seems to have ear-holes."
	icon_state = "zhan_scarf"
	body_parts_covered = HEAD|FACE

/obj/item/clothing/shoes/sandal/tajaran/caligae
	name = "caligae"
	desc = "The standard Tajaran footwear loosly resembles the Roman Caligae. Made of leather and rubber, their unique design allows for improved traction and protection. They don't look like they would fit on anyone but a Tajara."
	description_fluff = "These traditional Tajaran footwear, also called Haskri, have remained reletivly unchanged in principal, with improved materials and construction being the only notable improvment. Originally used for harsher environment, they became widespread for their comfort and hygiene. Some of them come with covering for additional protection for more sterile environments. Made for the Tajarans digitigrade anatomy, they won't fit on any other species."
	icon_state = "caligae"
	item_state = "caligae"
	body_parts_covered = FEET|LEGS
	species_restricted = list(SPECIES_TAJARA)

/obj/item/clothing/shoes/sandal/tajaran/caligae/white
	desc = "The standard Tajaran footwear loosly resembles the Roman Caligae. Made of leather and rubber, their unique design allows for improved traction and protection. They don't look like they would fit on anyone but a Tajara. /This one has a white covering."
	icon_state = "whitecaligae"
	item_state = "whitecaligae"

/obj/item/clothing/shoes/sandal/tajaran/caligae/grey
	desc = "The standard Tajaran footwear loosly resembles the Roman Caligae. Made of leather and rubber, their unique design allows for improved traction and protection. They don't look like they would fit on anyone but a Tajara. /This one has a grey covering."
	icon_state = "greycaligae"
	item_state = "greycaligae"

/obj/item/clothing/shoes/sandal/tajaran/caligae/black
	desc = "The standard Tajaran footwear loosly resembles the Roman Caligae. Made of leather and rubber, their unique design allows for improved traction and protection. They don't look like they would fit on anyone but a Tajara. /This one has a black covering."
	icon_state = "blackcaligae"
	item_state = "blackcaligae"

//Resomi clothing

/obj/item/clothing/suit/storage/toggle/Resomicoat
 	name = "small coat"
 	desc = "A coat that seems too small to fit a human."
 	icon_state = "resomicoat"
 	item_state = "resomicoat"
 	icon_open = "resomicoat_open"
 	icon_closed = "resomicoat"
 	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS
 	species_restricted = list(SPECIES_RESOMI)

/obj/item/clothing/suit/storage/resomi/cloak
	name = "black and orange cloak "
	desc = "It drapes over a Resomi's shoulders and closes at the neck with pockets convienently placed inside."
	icon = 'icons/obj/clothing/species/resomi/suits.dmi'
	icon_state = "resomi_cloak_bo"
	item_state = "resomi_cloak_bo"
	species_restricted = list(SPECIES_RESOMI)
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bo
	name = "black and orange cloak"
	icon_state = "resomi_cloak_bo"
	item_state = "resomi_cloak_bo"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bg
	name = "black and grey cloak"
	icon_state = "resomi_cloak_bg"
	item_state = "resomi_cloak_bg"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bmg
	name = "black and medium grey cloak"
	icon_state = "resomi_cloak_bmg"
	item_state = "resomi_cloak_bmg"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_blg
	name = "black and light grey cloak"
	icon_state = "resomi_cloak_blg"
	item_state = "resomi_cloak_blg"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bw
	name = "black and white cloak"
	icon_state = "resomi_cloak_bw"
	item_state = "resomi_cloak_bw"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_br
	name = "black and red cloak"
	icon_state = "resomi_cloak_br"
	item_state = "resomi_cloak_br"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bn
	name = "black cloak"
	icon_state = "resomi_cloak_bn"
	item_state = "resomi_cloak_bn"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_by
	name = "black and yellow cloak"
	icon_state = "resomi_cloak_by"
	item_state = "resomi_cloak_by"

/obj/item/clothing/suit/storage/resomi/cloak/resomi_cloak_bgr
	name = "black and green cloak"
	icon_state = "resomi_cloak_bgr"
	item_state = "resomi_cloak_bgr"

/obj/item/clothing/suit/storage/resomi/cloak/black_blue
	name = "black and blue cloak"
	icon_state = "resomi_cloak_bbl"
	item_state = "resomi_cloak_bbl"

/obj/item/clothing/suit/storage/resomi/cloak/black_purple
	name = "black and purple cloak"
	icon_state = "resomi_cloak_bp"
	item_state = "resomi_cloak_bp"

/obj/item/clothing/suit/storage/resomi/cloak/black_pink
	name = "black and pink cloak"
	icon_state = "resomi_cloak_bpi"
	item_state = "resomi_cloak_bpi"

/obj/item/clothing/suit/storage/resomi/cloak/black_brown
	name = "black and brown cloak"
	icon_state = "resomi_cloak_bbr"
	item_state = "resomi_cloak_bbr"

/obj/item/clothing/suit/storage/resomi/cloak/orange_grey
	name = "orange and grey cloak"
	icon_state = "resomi_cloak_og"
	item_state = "resomi_cloak_og"

/obj/item/clothing/suit/storage/resomi/cloak/rainbow
	name = "rainbow cloak"
	icon_state = "resomi_cloak_rainbow"
	item_state = "resomi_cloak_rainbow"

/obj/item/clothing/suit/storage/resomi/cloak/lightgrey_grey
	name = "light grey and grey cloak"
	icon_state = "resomi_cloak_lgg"
	item_state = "resomi_cloak_lgg"

/obj/item/clothing/suit/storage/resomi/cloak/white_grey
	name = "white and grey cloak"
	icon_state = "resomi_cloak_wg"
	item_state = "resomi_cloak_wg"

/obj/item/clothing/suit/storage/resomi/cloak/red_grey
	name = "red and grey cloak"
	icon_state = "resomi_cloak_rg"
	item_state = "resomi_cloak_rg"

/obj/item/clothing/suit/storage/resomi/cloak/orange
	name = "orange cloak"
	icon_state = "resomi_cloak_on"
	item_state = "resomi_cloak_on"

/obj/item/clothing/suit/storage/resomi/cloak/yellow_grey
	name = "yellow and grey cloak"
	icon_state = "resomi_cloak_yg"
	item_state = "resomi_cloak_yg"

/obj/item/clothing/suit/storage/resomi/cloak/green_grey
	name = "green and grey cloak"
	icon_state = "resomi_cloak_gg"
	item_state = "resomi_cloak_gg"

/obj/item/clothing/suit/storage/resomi/cloak/blue_grey
	name = "blue and grey cloak"
	icon_state = "resomi_cloak_blug"
	item_state = "resomi_cloak_blug"

/obj/item/clothing/suit/storage/resomi/cloak/purple_grey
	name = "purple and grey cloak"
	icon_state = "resomi_cloak_pg"
	item_state = "resomi_cloak_pg"

/obj/item/clothing/suit/storage/resomi/cloak/pink_grey
	name = "pink and grey cloak"
	icon_state = "resomi_cloak_pig"
	item_state = "resomi_cloak_pig"

/obj/item/clothing/suit/storage/resomi/cloak/brown_grey
	name = "brown and grey cloak"
	icon_state = "resomi_cloak_brg"
	item_state = "resomi_cloak_brg"

//Vox clothing

/obj/item/clothing/suit/armor/vox_scrap
	name = "rusted metal armor"
	desc = "A hodgepodge of various pieces of metal scrapped together into a rudimentary vox-shaped piece of armor."
	allowed = list(/obj/item/weapon/gun, /obj/item/weapon/tank)
	armor = list(melee = 70, bullet = 30, laser = 20,energy = 5, bomb = 40, bio = 0, rad = 0) //Higher melee armor versus lower everything else.
	icon_state = "vox-scrap"
	icon_state = "vox-scrap"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS
	species_restricted = list(SPECIES_VOX)
	siemens_coefficient = 1 //Its literally metal
