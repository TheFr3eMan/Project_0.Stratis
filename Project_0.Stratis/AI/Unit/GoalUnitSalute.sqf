#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\goalRelevance.hpp"

/*
The goal of saluting to someone

Author: Sparker 24.11.2018
*/


#define pr private

CLASS("GoalUnitSalute", "Goal")
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		// We want to salute if there is a fact that we have been saluted by someone
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_SALUTED_BY] call wf_fnc_setType;
		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		if (isNil "_wf") exitWith {GOAL_RELEVANCE_BIAS_LOWER};
		
		// We have found the world fact
		// Now check if it is relevant
		// After responding to this world fact, the action will mark the world fact as irrelevant
		if ((WF_GET_RELEVANCE(_wf)) == 0) exitWith {GOAL_RELEVANCE_BIAS_LOWER};
		
		diag_log format ["[GoalUnitSalute] high relevance for AI: %1", _AI];
		GOAL_RELEVANCE_UNIT_SALUTE
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// If this goal has doesn't support planner and supports a predefined plan, this method must
	// create an Action and return it.
	// Otherwise it must return ""
	
	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		// Find the unit to salute to from the world fact
		pr _target = objNull;
		pr _query = WF_NEW();
		[_query, WF_TYPE_UNIT_SALUTED_BY] call wf_fnc_setType;
		pr _wf = CALLM(_AI, "findWorldFact", [_query]);
		if (! (isNil "_wf")) then {
			_target = WF_GET_SOURCE(_wf);
		};
		pr _args = [_AI, _target];
		pr _action = NEW("ActionUnitSalute", _args);
		
		diag_log format ["[GoalSalute:createPredefinedAction] AI: %1, created action to salute to: %2", _AI, _target];
		
		// Return the created action
		_action
	} ENDMETHOD;

ENDCLASS;