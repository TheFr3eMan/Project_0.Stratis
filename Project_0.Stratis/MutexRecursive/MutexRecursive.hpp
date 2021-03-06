/*
Class: MutexRecursive
A recursive mutex is a mutex that can be re-entered multiple times.

Warning: the mutex must be:

- Unlocked the same amount of times as it was locked
- Unlocked by the thread it was locked by

Author: Sparker 28.12.2018
*/

/*Macro: MUTEX_RECURSIVE_NEW()
Returns a new Mutex*/
#define MUTEX_RECURSIVE_NEW() [scriptNull, 0]

/*Macro: MUTEX_RECURSIVE_LOCK(mutex)
Locks the mutex*/
#define MUTEX_RECURSIVE_LOCK(mutex) waitUntil { \
	isNil { \
		private _s = (mutex select 0); \
		if( (_s isEqualTo _thisScript) || (_s isEqualTo scriptNull) ) then { \
			mutex set [0, _thisScript]; \
			mutex set [1, (mutex select 1) + 1]; \
			nil \
		} else { \
			0 \
		}; \
	}; \
};

/*Macro: MUTEX_RECURSIVE_UNLOCK(mutex)
Unlocks the mutex*/
#define MUTEX_RECURSIVE_UNLOCK(mutex) isNil { \
	mutex params ["_hScript", "_lockCount"]; \
	if (_hScript isEqualTo _thisScript) then { \
		if (_lockCount == 1) then { \
			mutex set [0, scriptNull]; \
			mutex set [1, 0]; \
		} else { \
			mutex set [1, (mutex select 1) - 1]; \
		}; \
	} else { \
		diag_log format ["ERROR: error unlocking mutex %1", mutex]; \
	}; \
};