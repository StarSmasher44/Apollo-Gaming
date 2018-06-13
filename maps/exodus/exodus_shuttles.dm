
// Escape shuttle and pods
/datum/shuttle/autodock/ferry/emergency/evac
	name = "Escape"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/escape/centcom
	waypoint_offsite = "nav_evac_start"
	waypoint_station = "nav_evac_station"
	landmark_transition = "nav_evac_transit"
	dock_target = "escape_shuttle"


/obj/effect/shuttle_landmark/evac/start
	name = "CentCom Dock"
	landmark_tag = "nav_evac_start"
	docking_controller = "centcom_dock"

/obj/effect/shuttle_landmark/evac/transit
	name = "In transit"
	landmark_tag = "nav_evac_transit"

/obj/effect/shuttle_landmark/evac/out
	name = "Docked to station"
	landmark_tag = "nav_evac_station"
	docking_controller = "escape_dock"

/*
/datum/shuttle/autodock/ferry/emergency/centcom
	name = "Escape"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/escape/centcom
	waypoint_offsite = "nav_evac_start"
	waypoint_station = "nav_evac_station"
	landmark_transition = "nav_evac_transit"
	dock_target = "escape_shuttle"
*/

/datum/shuttle/autodock/ferry/escape_pod/
	category = /datum/shuttle/autodock/ferry/escape_pod/
	sound_takeoff = 'sound/effects/rocket.ogg'
	sound_landing = 'sound/effects/rocket_backwards.ogg'
	var/number

/datum/shuttle/autodock/ferry/escape_pod/New()
	name = "Escape Pod [number]"
	dock_target = "escape_pod_[number]"
	arming_controller = "escape_pod_[number]_berth"
	waypoint_station = "escape_pod_[number]_start"
	landmark_transition = "escape_pod_[number]_internim"
	waypoint_offsite = "escape_pod_[number]_out"
	..()

/obj/effect/shuttle_landmark/escape_pod/
	var/number

/obj/effect/shuttle_landmark/escape_pod/start
	name = "Docked with station"

/obj/effect/shuttle_landmark/escape_pod/start/New()
	landmark_tag = "escape_pod_[number]_start"
	docking_controller = "escape_pod_[number]_berth"
	..()

/obj/effect/shuttle_landmark/escape_pod/transit
	name = "In transit"

/obj/effect/shuttle_landmark/escape_pod/transit/New()
	landmark_tag = "escape_pod_[number]_internim"
	..()

/obj/effect/shuttle_landmark/escape_pod/out
	name = "Docked with rescue ship"

/obj/effect/shuttle_landmark/escape_pod/out/New()
	landmark_tag = "escape_pod_[number]_out"
	..()

/datum/shuttle/autodock/ferry/escape_pod/escape_pod1
	warmup_time = 0
	number = 1
	shuttle_area = /area/shuttle/escape_pod1/station
/obj/effect/shuttle_landmark/escape_pod/start/pod1
	number = 1
/obj/effect/shuttle_landmark/escape_pod/out/pod1
	number = 1
/obj/effect/shuttle_landmark/escape_pod/transit/pod1
	number = 1

/datum/shuttle/autodock/ferry/escape_pod/escape_pod2
	warmup_time = 0
	number = 2
	shuttle_area = /area/shuttle/escape_pod2/station
/obj/effect/shuttle_landmark/escape_pod/start/pod2
	number = 2
/obj/effect/shuttle_landmark/escape_pod/out/pod2
	number = 2
/obj/effect/shuttle_landmark/escape_pod/transit/pod2
	number = 2

/datum/shuttle/autodock/ferry/escape_pod/escape_pod3
	warmup_time = 0
	number = 3
	shuttle_area = /area/shuttle/escape_pod3/station
/obj/effect/shuttle_landmark/escape_pod/start/pod3
	number = 3
/obj/effect/shuttle_landmark/escape_pod/out/pod3
	number = 3
/obj/effect/shuttle_landmark/escape_pod/transit/pod3
	number = 3

/datum/shuttle/autodock/ferry/escape_pod/escape_pod5
	warmup_time = 0
	number = 5
	shuttle_area = /area/shuttle/escape_pod5/station
/obj/effect/shuttle_landmark/escape_pod/start/pod5
	number = 5
/obj/effect/shuttle_landmark/escape_pod/out/pod5
	number = 5
/obj/effect/shuttle_landmark/escape_pod/transit/pod5
	number = 5

//merchant shuttle

/datum/shuttle/autodock/ferry/merchant
	name = "Merchant"
	warmup_time = 10
	shuttle_area = /area/shuttle/merchant/home
	waypoint_station = "nav_merchant_start"
	waypoint_offsite = "nav_merchant_out"
	dock_target = "merchant_ship_dock"

/obj/effect/shuttle_landmark/merchant/start
	name = "Merchant Base"
	landmark_tag = "nav_merchant_start"
	docking_controller = "merchant_station_dock"

/obj/effect/shuttle_landmark/merchant/out
	name = "Docking Bay"
	landmark_tag = "nav_merchant_out"
	docking_controller = "merchant_shuttle_station_dock"

//supply shuttle

/datum/shuttle/autodock/ferry/supply/cargo
	name = "Supply"
	location = 1
	warmup_time = 10
	shuttle_area = /area/supply/dock
	waypoint_station = "nav_supply_out"
	waypoint_offsite = "nav_supply_start"
	dock_target = "supply_shuttle"


/obj/effect/shuttle_landmark/supply/start
	name = "Central Command"
	landmark_tag = "nav_supply_start"

/obj/effect/shuttle_landmark/supply/out
	name = "Cargo Bay"
	landmark_tag = "nav_supply_out"
	docking_controller = "cargo_bay"

//engineering shuttle

/datum/shuttle/autodock/ferry/engineering
	name = "Engineering"
	warmup_time = 10
	location = 0
	shuttle_area = /area/shuttle/constructionsite/station
	waypoint_station = "eng_shuttle_start"
	waypoint_offsite = "eng_shuttle_out"
	dock_target = "engineering_shuttle"

/obj/effect/shuttle_landmark/engineering/start
	name = "Engineering Shuttle Dock"
	landmark_tag = "eng_shuttle_start"

/obj/effect/shuttle_landmark/engineering/out
	name = "Construction Site"
	landmark_tag = "eng_shuttle_out"
	docking_controller = "engineering_shuttle"

// mining shuttle


/datum/shuttle/autodock/ferry/mining
	name = "Mining"
	warmup_time = 10
	location = 0
	shuttle_area = /area/shuttle/mining/station
	waypoint_station = "mining_shuttle_start"
	waypoint_offsite = "mining_outpost_out"
	dock_target = "mining_shuttle"

/obj/effect/shuttle_landmark/mining/start
	name = "Mining Shuttle Dock"
	landmark_tag = "mining_shuttle_start"

/obj/effect/shuttle_landmark/mining/out
	name = "Mining Outpost"
	landmark_tag = "mining_outpost_out"
	docking_controller = "mining_shuttle"

 // research shuttle

/datum/shuttle/autodock/ferry/research
	name = "Research"
	warmup_time = 10
	location = 0
	shuttle_area = /area/shuttle/research/station
	waypoint_station = "research_shuttle_start"
	waypoint_offsite = "research_outpost_out"
	dock_target = "research_shuttle"


/obj/effect/shuttle_landmark/research/start
	name = "Research Shuttle Dock"
	landmark_tag = "research_shuttle_start"

/obj/effect/shuttle_landmark/research/out
	name = "Research outpost dock"
	landmark_tag = "research_shuttle_out"
	docking_controller = "research_shuttle"

// transport shuttle

/datum/shuttle/autodock/ferry/centcom
	name = "Centcom"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/transport1/centcom
	waypoint_station = "research_shuttle_start"
	waypoint_offsite = "research_outpost_out"
	dock_target = "research_shuttle"

// admin shuttle

/datum/shuttle/autodock/ferry/administration
	name = "Administration"
	warmup_time = 10	//want some warmup time so people can cancel.
	shuttle_area = /area/shuttle/administration/centcom
	dock_target = "admin_shuttle"
	waypoint_station = "nav_admin_start"
	waypoint_offsite = "nav_admin_out"

/obj/effect/shuttle_landmark/admin/start
	name = "Centcom"
	landmark_tag = "nav_admin_start"
	docking_controller = "admin_shuttle"
	base_area = /area/centcom
	base_turf = /turf/simulated/floor/plating

/obj/effect/shuttle_landmark/admin/out
	name = "Docking Bay"
	landmark_tag = "nav_admin_out"
	docking_controller = "admin_shuttle_dock_airlock"

/datum/shuttle/autodock/multi/antag/mercenary
	name = "Mercenary"
	warmup_time = 0
	destination_tags = list(
		"nav_merc_deck1",
		"nav_merc_deck2",
		"nav_merc_deck3",
		"nav_merc_deck4",
		"nav_merc_deck5",
		"nav_away_5",
		"nav_derelict_6",
		"nav_cluster_5",
		"nav_merc_dock",
		"nav_merc_start",
		"nav_lost_supply_base_antag",
		"nav_marooned_antag",
		"nav_smugglers_antag",
		"nav_magshield_antag",
		"nav_casino_antag",
		"nav_yacht_antag",
		"nav_slavers_base_antag",
		)
	shuttle_area = /area/syndicate_station/start
	dock_target = "merc_shuttle"
	current_location = "nav_merc_start"
	landmark_transition = "nav_merc_transition"
	announcer = "SEV Torch Sensor Array"
	home_waypoint = "nav_merc_start"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

/obj/effect/shuttle_landmark/merc/start
	name = "Mercenary Base"
	landmark_tag = "nav_merc_start"
	docking_controller = "merc_base"

/obj/effect/shuttle_landmark/merc/internim
	name = "In transit"
	landmark_tag = "nav_merc_transition"

/obj/effect/shuttle_landmark/merc/dock
	name = "Docking Port"
	landmark_tag = "nav_merc_dock"
	docking_controller = "nuke_shuttle_dock_airlock"

/obj/effect/shuttle_landmark/merc/deck1
	name = "Northeast of First Deck"
	landmark_tag = "nav_merc_deck1"

/obj/effect/shuttle_landmark/merc/deck2
	name = "Southeast of the Second deck"
	landmark_tag = "nav_merc_deck2"

/obj/effect/shuttle_landmark/merc/deck3
	name = "South of Third deck"
	landmark_tag = "nav_merc_deck3"

/obj/effect/shuttle_landmark/merc/deck4
	name = "Northwest of Fourth Deck"
	landmark_tag = "nav_merc_deck4"

/obj/effect/shuttle_landmark/merc/deck5
	name = "East of Bridge"
	landmark_tag = "nav_merc_deck5"


//Skipjack

/datum/shuttle/autodock/multi/antag/skipjack
	name = "Skipjack"
	warmup_time = 0
	destination_tags = list(
		"nav_skipjack_deck1",
		"nav_skipjack_deck2",
		"nav_skipjack_deck3",
		"nav_skipjack_deck4",
		"nav_skipjack_deck5",
		"nav_away_7",
		"nav_derelict_7",
		"nav_cluster_7",
		"nav_skipjack_dock",
		"nav_skipjack_start",
		"nav_lost_supply_base_antag",
		"nav_marooned_antag",
		"nav_smugglers_antag",
		"nav_magshield_antag",
		"nav_casino_antag",
		"nav_yacht_antag",
		"nav_slavers_base_antag",
		)
	shuttle_area =  /area/skipjack_station/start
	dock_target = "skipjack_shuttle"
	current_location = "nav_skipjack_start"
	landmark_transition = "nav_skipjack_transition"
	announcer = "SEV Torch Sensor Array"
	home_waypoint = "nav_skipjack_start"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

/obj/effect/shuttle_landmark/skipjack/start
	name = "Raider Outpost"
	landmark_tag = "nav_skipjack_start"
	docking_controller = "skipjack_base"

/obj/effect/shuttle_landmark/skipjack/internim
	name = "In transit"
	landmark_tag = "nav_skipjack_transition"

/obj/effect/shuttle_landmark/skipjack/dock
	name = "Docking Port"
	landmark_tag = "nav_skipjack_dock"
	docking_controller = "skipjack_shuttle_dock_airlock"

/obj/effect/shuttle_landmark/skipjack/deck1
	name = "Northwest of First Deck"
	landmark_tag = "nav_skipjack_deck1"

/obj/effect/shuttle_landmark/skipjack/deck2
	name = "Southwest of the Second deck"
	landmark_tag = "nav_skipjack_deck2"

/obj/effect/shuttle_landmark/skipjack/deck3
	name = "Southeast of Third deck"
	landmark_tag = "nav_skipjack_deck3"

/obj/effect/shuttle_landmark/skipjack/deck4
	name = "Northwest of Fourth Deck"
	landmark_tag = "nav_skipjack_deck4"

/obj/effect/shuttle_landmark/skipjack/deck5
	name = "South of Bridge"
	landmark_tag = "nav_skipjack_deck5"

//NT Rescue Shuttle

/datum/shuttle/autodock/multi/antag/rescue
	name = "Rescue"
	warmup_time = 0
	destination_tags = list(
		"nav_ert_deck1",
		"nav_ert_deck2",
		"nav_ert_deck3",
		"nav_ert_deck4",
		"nav_ert_deck5",
		"nav_away_4",
		"nav_derelict_4",
		"nav_cluster_4",
		"nav_ert_dock",
		"nav_ert_start",
		"nav_lost_supply_base_antag",
		"nav_marooned_antag",
		"nav_smugglers_antag",
		"nav_magshield_antag",
		"nav_casino_antag",
		"nav_yacht_antag",
		"nav_slavers_base_antag",
		)
	shuttle_area = /area/rescue_base/start
	dock_target = "rescue_shuttle"
	current_location = "nav_ert_start"
	landmark_transition = "nav_ert_transition"
	home_waypoint = "nav_ert_start"
	announcer = "SEV Torch Sensor Array"
	arrival_message = "Attention, vessel detected entering vessel proximity."
	departure_message = "Attention, vessel detected leaving vessel proximity."

/obj/effect/shuttle_landmark/ert/start
	name = "Response Team Base"
	landmark_tag = "nav_ert_start"
	docking_controller = "rescue_base"

/obj/effect/shuttle_landmark/ert/internim
	name = "In transit"
	landmark_tag = "nav_ert_transition"

/obj/effect/shuttle_landmark/ert/dock
	name = "Docking Port"
	landmark_tag = "nav_ert_dock"
	docking_controller = "rescue_shuttle_dock_airlock"

/obj/effect/shuttle_landmark/ert/deck1
	name =  "Southwest of Fourth deck"
	landmark_tag = "nav_ert_deck1"

/obj/effect/shuttle_landmark/ert/deck2
	name = "Northwest of Third deck"
	landmark_tag = "nav_ert_deck2"

/obj/effect/shuttle_landmark/ert/deck3
	name = "Northwest of Second deck"
	landmark_tag = "nav_ert_deck3"

/obj/effect/shuttle_landmark/ert/deck4
	name = "Southwest of First Deck"
	landmark_tag = "nav_ert_deck4"

/obj/effect/shuttle_landmark/ert/deck5
	name = "West of Bridge"
	landmark_tag = "nav_ert_deck5"

//Deathsquad Assault Pod

/datum/shuttle/autodock/ferry/specops/ert
	name = "Special Operations"
	warmup_time = 10
	shuttle_area = /area/shuttle/specops/centcom
	dock_target = "specops_shuttle_fore"
	waypoint_station = "nav_specops_start"
	waypoint_offsite = "nav_specops_out"

/obj/effect/shuttle_landmark/specops/start
	name = "Centcom"
	landmark_tag = "nav_specops_start"
	docking_controller = "specops_shuttle_port"

/obj/effect/shuttle_landmark/specops/out
	name = "Docking Bay"
	landmark_tag = "nav_specops_out"
	docking_controller = "specops_dock_airlock"
