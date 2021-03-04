/datum/job/assistant
	title = "Assistant"
//	department = "Engineering"
	department_flag = CIV

	total_positions = -1
	spawn_positions = -1
	supervisors = "Literally everyone on board."
	selection_color = "#515151"
	alt_titles = list("Off-Duty Personnel")
	economic_modifier = 1
	base_pay = 2
	intern = 1
	access = list()
	minimal_access = list()
	outfit_type = /decl/hierarchy/outfit/job/assistant


/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()

