/*
Killed EH for units. Its main job is to send messages to objects. 
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

params ["_objectHandle", "_killer", "_instigator", "_useEffects"];

// Is this object an instance of Unit class?
private _unit = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]);

//diag_log format ["[Unit] Info: Event handler: unit was destroyed: %1", _unit];

if (_unit != "") then {

};