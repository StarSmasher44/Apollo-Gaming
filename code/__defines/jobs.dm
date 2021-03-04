#define ENG 1
#define SEC 2
#define MED 4
#define SCI 8
#define CIV 16
#define COM 32
#define CRG 64
#define MSC 128
#define SRV 256
#define LOG 512
#define SPT 1024
#define EXP 2048
#define NTO 4096


// Defines for basically the promoted variable from Character Records,CharRecords.
#define JOB_LEVEL_INTERN 0
#define JOB_LEVEL_REGULAR 1
#define JOB_LEVEL_SENIOR 2
#define JOB_LEVEL_HEAD 4

#define REVIVEPRICE 3000 //3k for a permadeath char neural lace/revive.

#define PENSION_TAX_PD 16 //Permadeath has a higher tax rate for pension.
#define PENSION_TAX_REG 8 //Regular pension tax.
#define INCOME_TAX 40


//DEPARTMENT CONTRACTS DEFINES
#define CONTRACT_SCI 1 //Science contract (XRP/Research power)
#define CONTRACT_ENGI 2 //Engineering Contract (Power)
#define CONTRACT_LOGI 4 //Logistics Contract (Resources)

// Company size defines the ranges between the required resource(s). A small business can do great with a small amount of power, but EG Fucken Google needs more for everyone's porn search.
#define COMPANY_SMALL 0 //Small contract
#define COMPANY_MEDIUM 1 //Medium Contract
#define COMPANY_LARGE 2 //Large Contract