/*
*/

#define UNIT_DATA_ID_CAT			0
#define UNIT_DATA_ID_SUBCAT			1
#define UNIT_DATA_ID_CLASS_NAME		2
#define UNIT_DATA_ID_OBJECT_HANDLE	3
#define UNIT_DATA_ID_GARRISON		4
#define UNIT_DATA_ID_OWNER			5
#define UNIT_DATA_ID_GROUP			6
#define UNIT_DATA_ID_MUTEX			7
#define UNIT_DATA_ID_VEHICLE_ROLE	8
#define UNIT_DATA_ID_VEHICLE_CREW	9
// Vehicle assigned to this unit
#define UNIT_DATA_ID_VEHICLE		10
#define UNIT_DATA_ID_AI				11

#define UNIT_DATA_SIZE				12

//								 0, 1,  2,       3,  4, 5,  6,  7,               8,	9, 10, 11
#define UNIT_DATA_DEFAULT		[0, 0, "", objNull, "", 2, "", [], UNIT_VR_DEFAULT, 0, "", ""]

//Class name of Unit class, in case I need to rename it everywhere
#define UNIT_CLASS_NAME "Unit"

// Vehicle roles
#define UNIT_VR_NONE			0
#define UNIT_VR_DRIVER			1
#define UNIT_VR_TURRET			2
#define UNIT_VR_CARGO_TURRET	3
#define UNIT_VR_CARGO			4

// Array with all available vehicle roles
#define UNIT_VR_ALL [VR_NONE, VR_DRIVER, VR_TURRET, VR_CARGO_TURRET, VR_CARGO]

// Vehicle role array structure is: [vehicleRole, turretPath]
#define UNIT_VR_ID_ROLE			0
#define UNIT_VR_ID_TURRET_PATH	1
#define UNIT_VR_DEFAULT			[UNIT_VR_NONE]
