#define TICK_LIMIT_RUNNING 80
#define TICK_LIMIT_TO_RUN 78
#define TICK_LIMIT_MC 75
#define TICK_LIMIT_MC_INIT_DEFAULT 98

#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
#define CHECK_TICK if TICK_CHECK stoplag()
#define CHECK_TICK2(cpu) if(TICK_USAGE > cpu) stoplag()
