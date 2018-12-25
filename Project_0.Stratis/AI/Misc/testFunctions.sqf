#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

#define pr private

// Makes a unit with objectHandle stop its AI brain and switch to specified action immediately
AI_misc_fnc_forceUnitAction = {
	params [ ["_objectHandle", objNull, [objNull]], ["_actionClassName", "", [""]], ["_parameters", []], ["_updateInterval", 1, [1]] ];
	
	// Find the AI of this objectHandle
	pr _unit = _objectHandle getVariable "unit";
	if (isNil "_unit") exitWith { diag_log "Error: object handle is not a unit!"; };
	
	// Get the unit's group
	pr _group = CALLM0(_unit, "getGroup");
	pr _unitAI = CALLM0(_unit, "getAI");
	pr _groupAI = CALLM0(_group, "getAI");
	if (isNil "_unitAI") exitWith {diag_log "Error: unit AI is not found!";};
	if (isNil "_groupAI") exitWith {diag_log "Error: group AI is not found!";};
	
	// Stop the AI brain of this unit's group
	CALLM0(_groupAI, "stop");
	
	// Create an action for this AI
	pr _args = [_unitAI, _parameters];
	pr _action = NEW(_actionClassName, _args);
	
	// Make this action autonomous
	CALLM1(_action, "setAutonomous", _updateInterval);
	
	// Return the created action
	_action
};

/*
Example:
_unit = cursorObject;
_actionClassName = "ActionUnitSalute";
_parameters = player;
_interval = 1;
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
_Action = [_unit, _actionClassName, _parameters, _interval] call AI_misc_fnc_forceUnitAction;
_action
*/