var/runtime_diary = null


var/list/combatlog = list()
var/list/IClog     = list()
var/list/OOClog    = list()

var/datum/configuration/config      = null
var/list/jobMax        = list()

var/diary               = null
var/adminlog            = null

GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)
GLOBAL_VAR(world_runtime_log)
GLOBAL_PROTECT(world_runtime_log)
GLOBAL_VAR(world_qdel_log)
GLOBAL_PROTECT(world_qdel_log)
GLOBAL_VAR(world_attack_log)
GLOBAL_PROTECT(world_attack_log)
GLOBAL_VAR(adminlog)
GLOBAL_VAR(diary)
GLOBAL_VAR(world_error_log)
