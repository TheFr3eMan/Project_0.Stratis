#include "..\..\OOP_Light\OOP_Light.h"

/*
Group sensor base class.
Saves some common variables at construction.
*/

#define pr private

CLASS("SensorGroup", "Sensor")

	VARIABLE("hG"); // Group handle
	VARIABLE("group"); // Group
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]]];
		pr _g = GETV(_AI, "agent");
		SETV(_thisObject, "group", _g);
		pr _gh = CALLM0(_g, "getGroupHandle");
		SETV(_thisObject, "hG", _gh);
	} ENDMETHOD;

ENDCLASS;