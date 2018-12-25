#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"

private _s = WSP_GAR_COUNT;

/*
Initializes costs, effects and preconditions of actions, relevance values of goals.
*/

// ---- Goal relevance values and effects ----
// The actual relevance returned by goal can be different from the one which is set below

["GoalGarrisonRelax",				1] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonMove",				20] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonRepairAllVehicles",	10] call AI_misc_fnc_setGoalIntrinsicRelevance;

["GoalGarrisonDefendPassive",		30] call AI_misc_fnc_setGoalIntrinsicRelevance;


// ---- Goal effects ----
// The actual effects returned by goal can depend on context and differ from those set below

["GoalGarrisonRelax", _s,				[]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonMove", _s,				[[WSP_GAR_POSITION, "g_pos", true]]] call AI_misc_fnc_setGoalEffects;

["GoalGarrisonRepairAllVehicles", _s, [	[WSP_GAR_ALL_VEHICLES_REPAIRED, true],
										[WSP_GAR_ALL_VEHICLES_CAN_MOVE, true]]] call AI_misc_fnc_setGoalEffects;
										
["GoalGarrisonMoveCargo", _s,			[[WSP_GAR_CARGO_POSITION, "g_cargoPos", true],
										[WSP_GAR_HAS_CARGO, false]]] call AI_misc_fnc_setGoalEffects;
										
["GoalGarrisonDefendPassive", _s,		[[WSP_GAR_AWARE_OF_ENEMY, false]]] call AI_misc_fnc_setGoalEffects;


// ---- Predefined actions of goals ----

["GoalGarrisonRelax", "ActionGarrisonRelax"] call AI_misc_fnc_setGoalPredefinedAction;


// ---- Action preconditions and effects ----

// Repair all vehicles
["ActionGarrisonRepairAllVehicles",	_s, [	[WSP_GAR_ENGINEER_AVAILABLE,	true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonRepairAllVehicles",	_s,	[	[WSP_GAR_ALL_VEHICLES_REPAIRED,	true],
											[WSP_GAR_ALL_VEHICLES_CAN_MOVE,	true]]] call AI_misc_fnc_setActionEffects;
										
// Mount crew
["ActionGarrisonMountCrew",	_s,			[]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountCrew",	_s,			[	[WSP_GAR_ALL_CREW_MOUNTED,		true]]] call AI_misc_fnc_setActionEffects;

// Mount infantry
["ActionGarrisonMountInfantry",	_s,		[]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMountInfantry",	_s,		[	[WSP_GAR_ALL_INFANTRY_MOUNTED,	true]]] call AI_misc_fnc_setActionEffects;

// Move mounted
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	true]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMounted", _s,		[	[WSP_GAR_POSITION,	"a_pos",	true],
											[WSP_GAR_VEHICLES_POSITION,	"a_pos",	true]]] call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action

// Move mounted cargo
["ActionGarrisonMoveMountedCargo", _s,		[	[WSP_GAR_ALL_CREW_MOUNTED,		true],
												[WSP_GAR_ALL_INFANTRY_MOUNTED,	true],
												[WSP_GAR_HAS_CARGO,				true]]] 		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveMountedCargo", _s,		[	[WSP_GAR_POSITION,	"a_pos",	true], 
												[WSP_GAR_CARGO_POSITION,	"a_pos",	true],
												[WSP_GAR_VEHICLES_POSITION,	"a_pos",	true]]] 		call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action


// Move dismounted
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_ALL_CREW_MOUNTED,		false],
											[WSP_GAR_ALL_INFANTRY_MOUNTED,	false]]] call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonMoveDismounted", _s,	[	[WSP_GAR_POSITION,	"a_pos",	true]]]			call AI_misc_fnc_setActionEffects; // Position is defined in parameter 0 of the action

// Load cargo
["ActionGarrisonLoadCargo", _s,			[	[WSP_GAR_HAS_CARGO,	false],
											[WSP_GAR_VEHICLES_POSITION, [1, 1, 1]]]]	call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonLoadCargo", _s,			[	[WSP_GAR_HAS_CARGO, true]]]		call AI_misc_fnc_setActionEffects;
["ActionGarrisonLoadCargo", 			["g_cargo"]] call AI_misc_fnc_setActionParametersFromGoal;

// Unload cargo
["ActionGarrisonUnloadCurrentCargo", _s,	[	[WSP_GAR_HAS_CARGO,	true]]]		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonUnloadCurrentCargo", _s,	[	[WSP_GAR_HAS_CARGO,	false]]]	call AI_misc_fnc_setActionEffects;

// Defend passive
["ActionGarrisonDefendPassive", _s,	[	]]		call AI_misc_fnc_setActionPreconditions;
["ActionGarrisonDefendPassive", _s,	[	[WSP_GAR_AWARE_OF_ENEMY,	false]]]	call AI_misc_fnc_setActionEffects;


// ---- Action costs ----
["ActionGarrisonMountCrew",				0.4]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMountInfantry",			0.6]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMounted",			2]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveMountedCargo",		3]	call AI_misc_fnc_setActionCost;
["ActionGarrisonMoveDismounted",		3]	call AI_misc_fnc_setActionCost;
["ActionGarrisonLoadCargo",				2] 	call AI_misc_fnc_setActionCost;
["ActionGarrisonUnloadCurrentCargo", 	0.3]	call AI_misc_fnc_setActionCost;
["ActionGarrisonDefendPassive", 		1.0]	call AI_misc_fnc_setActionCost;