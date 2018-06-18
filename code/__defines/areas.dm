//The definition of insanity? #define insane 1
//But these are define-ified area functions that are called a lot.
/*
#define AreaUsage(channel, area, tot) { \
	switch(channel) { \
		if(LIGHT) { \
			tot += area.used_light; \
			} \
		if(EQUIP) { \
			tot += area.used_equip; \
			} \
		if(ENVIRON) { \
			tot += area.used_environ; \
			} \
		if(TOTAL) { \
			tot += area.used_light + area.used_equip + area.used_environ; \
			} \
		} \
	return(tot); \
*/

#define ClearUsage(area) \
	area.used_equip = 0; \
	area.used_light = 0; \
	area.used_environ = 0;