/*
Unit class.
A virtualized Unit is a man, vehicle or a drone which can be spawned or not spawned.

Author: Sparker
10.06.2018
*/

#include "Unit.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

#define pr private

Unit_fnc_EH_killed = compile preprocessFileLineNumbers "Unit\EH_killed.sqf";

CLASS(UNIT_CLASS_NAME, "")
	VARIABLE("data");
	STATIC_VARIABLE("all");
	
	// ----------------------------------------------------------------------
	// |                             N E W                                  |
	// ----------------------------------------------------------------------
					
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_template", [], [[]]], ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_classID", 0, [0]], ["_group", "", [""]]];

		//Check argument validity
		private _valid = false;
		//Check template
		if(_classID == -1) then	{
			if(([_template, _catID, _subcatID, 0] call t_fnc_isValid)) then	{
				_valid = true;
			};
		}
		else {
			if(([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) then {
				_valid = true;
			};
		};
		if (!_valid) exitWith { SET_MEM(_thisObject, "data", []);  diag_log format ["[Unit::new] Error: created invalid unit: %1", _this] };
		//Check group
		if(_group == "" && _catID == T_INF) exitWith { diag_log "[Unit] Error: men must be added with a group!";};
		
		//If a random class was requested to be added
		private _class = "";
		if(_classID == -1) then {
			private _classData = [_template, _catID, _subcatID] call t_fnc_selectRandom;
			_class = _classData select 0;
		} else {
			_class = [_template, _catID, _subcatID, _classID] call t_fnc_select;
		};
		
		//Create the data array
		private _data = UNIT_DATA_DEFAULT;
		_data set [UNIT_DATA_ID_CAT, _catID];
		_data set [UNIT_DATA_ID_SUBCAT, _subcatID];
		_data set [UNIT_DATA_ID_CLASS_NAME, _class];
		_data set [UNIT_DATA_ID_MUTEX, MUTEX_NEW()];
		_data set [UNIT_DATA_ID_GROUP, _group];
		SET_MEM(_thisObject, "data", _data);
		
		//Push the new object into the array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray pushBack _thisObject;
		
		//Add this unit to a group
		if(_group != "") then {
			CALL_METHOD(_group, "addUnit", [_thisObject]);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params[["_thisObject", "", [""]]];
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select UNIT_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		
		//Despawn this unit if it was spawned
		CALLM(_thisObject, "despawn", []);
		
		// Remove the unit from its group
		private _group = _data select UNIT_DATA_ID_GROUP;
		CALL_METHOD(_group, "removeUnit", [_thisObject]);
		
		//Remove this unit from array with all units
		private _allArray = GET_STATIC_MEM(UNIT_CLASS_NAME, "all");
		_allArray = _allArray - [_thisObject];
		SET_STATIC_MEM(UNIT_CLASS_NAME, "all", _allArray);
		MUTEX_UNLOCK(_mutex);
		SET_MEM(_thisObject, "data", nil);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                             I S   V A L I D                        |
	// ----------------------------------------------------------------------
	
	//Checks if the created unit is valid(check the constructor code)
	//After creating a new unit, make sure it's valid before adding it to other objects
	METHOD("isValid") {
		params [["_thisObject", "", [""]]];
		private _data = GET_MEM(_thisObject, "data");
		if (isNil "_data") exitWith {false};
		//Return true if the data array is of the correct size
		( (count _data) == UNIT_DATA_SIZE)
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         I S   S P A W N E D                        |
	// ----------------------------------------------------------------------
	
	//Returns true if the unit is spawned
	METHOD("isSpawned") {
		params [["_thisObject", "", [""]]];
		private _mutex = _data select UNIT_DATA_ID_MUTEX;
		MUTEX_LOCK(_mutex);
		private _return = !( isNull (_data select UNIT_DATA_ID_OBJECT_HANDLE));
		MUTEX_UNLOCK(_mutex);
		_return
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           C R E A T E   A I
	// ----------------------------------------------------------------------
	
	METHOD("createAI") {
		params [["_thisObject", "", [""]]];
		
		// Create an AI object of the unit
		// Don't start the brain, because its process method will be called by
		// its group's AI brain
		pr _data = GETV(_thisObject, "data");
		pr _AI = NEW("AIUnit", [_thisObject]);
		_data set [UNIT_DATA_ID_AI, _AI];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                             S P A W N                              |
	// ----------------------------------------------------------------------
	
	METHOD("spawn") {
		params [["_thisObject", "", [""]], "_pos", "_dir"];
		//Unpack data
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select UNIT_DATA_ID_MUTEX;
		
		//Lock the mutex
		MUTEX_LOCK(_mutex);
		
		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (isNull _objectHandle) then { //If it's not spawned yet
			private _className = _data select UNIT_DATA_ID_CLASS_NAME;
			private _group = _data select UNIT_DATA_ID_GROUP;
			
			//Perform object creation
			private _catID = _data select UNIT_DATA_ID_CAT;
			switch(_catID) do {
				case T_INF: {
					private _groupHandle = CALL_METHOD(_group, "getGroupHandle", []);
					//diag_log format ["---- Received group of side: %1", side _groupHandle];
					_objectHandle = _groupHandle createUnit [_className, _pos, [], 10, "FORM"];
					[_objectHandle] joinSilent _groupHandle; //To force the unit join this side
					
					//_objectHandle disableAI "PATH";
					//_objectHandle setUnitPos "UP"; //Force him to not sit or lay down
					
					CALLM0(_thisObject, "createAI");					
				};
				case T_VEH: {
					_objectHandle = createVehicle [_className, _pos, [], 0, "can_collide"];
				};
				case T_DRONE: {
				};
			};
			
			// Set variable of the object
			_objectHandle setVariable ["unit", _thisObject];
			
			// Set event handlers of the object
			_objectHandle addEventHandler ["Killed", Unit_fnc_EH_killed];
			
			//if (_group != "") then { CALL_METHOD(_group, "handleUnitSpawned", []) };
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, _objectHandle];
			_objectHandle setDir _dir;
			_objectHandle setPos _pos;
		};		
		//Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           D E S P A W N                            |
	// ----------------------------------------------------------------------
	
	METHOD("despawn") {
		params [["_thisObject", "", [""]]];
		//Unpack data
		private _data = GET_MEM(_thisObject, "data");
		private _mutex = _data select UNIT_DATA_ID_MUTEX;
		
		//Lock the mutex
		MUTEX_LOCK(_mutex);
		
		//Unpack more data...
		private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		if (!(isNull _objectHandle)) then { //If it's been spawned before
			// Stop AI, sensors, etc
			pr _AI = _data select UNIT_DATA_ID_AI;
			// Some units are brainless. Check if the unit had a brain.
			if (_AI != "") then {
				pr _msg = MESSAGE_NEW();
				MESSAGE_SET_TYPE(_msg, AI_MESSAGE_DELETE);			
				pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
				CALLM(_AI, "waitUntilMessageDone", [_msgID]);
				_data set [UNIT_DATA_ID_AI, ""];
			};
			
			// Delete the vehicle
			deleteVehicle _objectHandle;
			private _group = _data select UNIT_DATA_ID_GROUP;
			//if (_group != "") then { CALL_METHOD(_group, "handleUnitDespawned", [_thisObject]) };
			_data set [UNIT_DATA_ID_OBJECT_HANDLE, objNull];
		};		
		//Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    S E T   V E H I C L E   R O L E                 |
	// ----------------------------------------------------------------------
	// Assigns the unit to a vehicle with specified vehicle role
	METHOD("setVehicleRole") {
		params [["_thisObject", "", [""]], "_vehicle", "_vehicleRole"];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   S E T / G E T   G A R R I S O N                  |
	// ----------------------------------------------------------------------
	// Sets the garrison of this unit (use Garrison::addUnit to add a unit to a garrison)
	METHOD("setGarrison") {
		params [["_thisObject", "", [""]], ["_garrison", "", [""]] ];
		private _data = GET_VAR(_thisObject, "data");
		_data set [UNIT_DATA_ID_GARRISON, _garrison];
	} ENDMETHOD;
	
	// Returns the garrison of this unit
	METHOD("getGarrison") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_GARRISON
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        G E T   O B J E C T   H A N D L E           |
	// ----------------------------------------------------------------------
	
	// Returns the group of this unit
	METHOD("getObjectHandle") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_OBJECT_HANDLE
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        G E T   G R O U P                           |
	// ----------------------------------------------------------------------
	
	// Returns the group of this unit
	METHOD("getGroup") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_GROUP
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        G E T   A I
	// ----------------------------------------------------------------------
	
	// Returns the group of this unit
	METHOD("getAI") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_AI
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T   M A I N   D A T A                        |
	// ----------------------------------------------------------------------
	// Returns [_catID, _subcatID, _className] of this unit
	METHOD("getMainData") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		[_data select UNIT_DATA_ID_CAT, _data select UNIT_DATA_ID_SUBCAT, _data select UNIT_DATA_ID_CLASS_NAME]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   V E H I C L E   C R E W                 |
	// ----------------------------------------------------------------------
	// Returns the units assigned to this vehicle
	METHOD("getVehicleCrew") {
		params [["_thisObject", "", [""]]];
		private _data = GET_MEM(_thisObject, "data");
		_data select UNIT_DATA_ID_VEHICLE_CREW
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   U N I T   K I L L E D             |
	// ----------------------------------------------------------------------
	
	//Called by event dispatcher	
	METHOD("handleDestroyed") {
		params [["_thisObject", "", [""]]];
		//Oh no, Johny is down! What should we do?
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                       G E T   D E B U G   D A T A                  |
	// ----------------------------------------------------------------------
	// Returns data which is meant to be shown in debug messages to help find errors
	METHOD("getDebugData") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "data")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |         G E T   U N I T   F R O M   O B J E C T   H A N D L E
	// |
	// |  Gets the unit object of this object handle
	// | If this object is not associated with a unit, returns ""
	// ----------------------------------------------------------------------
	STATIC_METHOD("getUnitFromObjectHandle") {
		params [ ["_thisClass", "", [""]], ["_objectHandle", objNull, [objNull]] ];
		_objectHandle getVariable ["unit", ""]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// | I S   I N F A N T R Y   /   V E H I C L E   /   D R O N E
	// | Returns true if the unit is of specified type
	// ----------------------------------------------------------------------
	
	METHOD("isInfantry") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_INF
	} ENDMETHOD;

	METHOD("isVehicle") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_VEH
	} ENDMETHOD;
	
	METHOD("isDrone") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		_data select UNIT_DATA_ID_CAT == T_DRONE
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            G O A P                             
	// ----------------------------------------------------------------------	
	
	METHOD("getSubagents") {
		[] // A single unit has no subagents
	} ENDMETHOD;
	
	// Returns the AI object of this unit
	METHOD("getAI") {
		params [["_thisObject", "", [""]]];
		pr _data = GET_MEM(_thisObject, "data");
		_data select UNIT_DATA_ID_AI
	} ENDMETHOD;
	
	METHOD("getPossibleGoals") {
		["GoalUnitSalute","GoalUnitScareAway"]
	} ENDMETHOD;
	
	METHOD("getPossibleActions") {
		["ActionUnitSalute","ActionUnitScareAway"]
	} ENDMETHOD;
	
	
	
	
	
	// --------------------- Generic functions -----------------
	METHOD("getPos") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _oh = _data select UNIT_DATA_ID_OBJECT_HANDLE;
		getPos _oh
	} ENDMETHOD;
	
	
	
	
	
	
	// ================= File based methods ======================
	METHOD_FILE("createDefaultCrew", "Unit\createDefaultCrew.sqf");
	METHOD_FILE("doMoveInf", "Unit\doMoveInf.sqf");
	METHOD_FILE("doStopInf", "Unit\doStopInf.sqf");
	//METHOD_FILE("doSitOnBench", "Unit\doSitOnBench.sqf");
	//METHOD_FILE("doGetUpFromBench", "Unit\doGetUpFromBench.sqf");
	//METHOD_FILE("doAnimRepairVehicle", "Unit\doAnimRepairVehicle.sqf");
	METHOD_FILE("doInteractAnimObject", "Unit\doInteractAnimObject.sqf");
	METHOD_FILE("doStopInteractAnimObject", "Unit\doStopInteractAnimObject.sqf");
	METHOD_FILE("distance", "Unit\distance.sqf"); // Returns distance between this unit and another position
	METHOD_FILE("getBehaviour", "Unit\getBehaviour.sqf");
	METHOD_FILE("isAlive", "Unit\isAlive.sqf");
	
ENDCLASS;

SET_STATIC_MEM("Unit", "all", []);