
/datum/preferences/proc/load_persistent(var/savefile/S)
	S["char_department"]		>> char_department
	S["department_playtime"]	>> department_playtime
	S["dept_experience"]		>> dept_experience
	S["bank_balance"]			>> bank_balance
	S["department_rank"]		>> department_rank
	S["pension_balance"]		>> pension_balance
	S["permadeath"]				>> permadeath
	S["neurallaces"]			>> neurallaces
	S["recommendations"]		>> recommendations
	S["promotion"]				>> promoted

/datum/preferences/proc/save_persistent(var/savefile/S)
	S["char_department"]		<< char_department
	S["department_playtime"]	<< department_playtime
	S["dept_experience"]		<< dept_experience
	S["bank_balance"]			<< bank_balance
	S["department_rank"]		<< department_rank
	S["pension_balance"]		<< pension_balance
	S["permadeath"]				<< permadeath
	S["neurallaces"]			<< neurallaces
	S["recommendations"]		<< recommendations
	S["promotion"]				<< promoted