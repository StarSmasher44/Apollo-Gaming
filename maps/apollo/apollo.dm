#if !defined(using_map_DATUM)

	#include "apollo_areas.dm"
	#include "apollo_effects.dm"
	#include "apollo_elevator.dm"
	#include "apollo_holodecks.dm"
	#include "apollo_presets.dm"
//	#include "apollo_shuttles.dm"

	#include "apollo_unit_testing.dm"
	#include "apollo_zas_tests.dm"

	#include "loadout/loadout_accessories.dm"
	#include "loadout/loadout_eyes.dm"
	#include "loadout/loadout_head.dm"
	#include "loadout/loadout_shoes.dm"
	#include "loadout/loadout_suit.dm"
	#include "loadout/loadout_uniform.dm"
	#include "loadout/loadout_xeno.dm"

	#include "../shared/exodus_torch/_include.dm"

	#include "apollo-1.dmm"
	#include "apollo-2_found.dmm"
	#include "apollo-3_found.dmm"
	#include "apollo-4.dmm"
//	#include "apollo-5.dmm"
//	#include "apollo-6.dmm"
//	#include "apollo-7.dmm"

	#include "../../code/modules/lobby_music/absconditus.dm"
	#include "../../code/modules/lobby_music/clouds_of_fire.dm"
	#include "../../code/modules/lobby_music/endless_space.dm"
	#include "../../code/modules/lobby_music/dilbert.dm"
	#include "../../code/modules/lobby_music/space_oddity.dm"
	#include "../../code/modules/lobby_music/title1.dm"

	#define using_map_DATUM /datum/map/apollo

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring apollo

#endif
