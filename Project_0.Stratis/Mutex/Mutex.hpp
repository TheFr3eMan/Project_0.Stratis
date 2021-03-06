/*
Struct: Mutex
Mutex lets multiple threads (scheduled scripts) share the same resource so that only one of the threads can access it.

Usage: Create a Mutex known to both threads. Lock it before doing read-modify-write operations on the common resource. Unlock it.

Warning: this Mutex is NON-RECURSIVE! The thread will DEADLOCK if attempted to lock a mutex more than once.
 
thx to Freghar from BIS forum for the implementation: https://forums.bohemia.net/forums/topic/183993-scripting-introduction-for-new-scripters/?tab=comments#comment-3016726
*/

/*Macro: MUTEX_NEW()
Returns a new Mutex*/
#define MUTEX_NEW() []

/*Macro: MUTEX_LOCK(mutex)
Locks the mutex*/
#define MUTEX_LOCK(mutex) waitUntil { (mutex pushBackUnique 0) == 0;}

/*Macro: MUTEX_UNLOCK(mutex)
Unlocks the mutex*/
#define MUTEX_UNLOCK(mutex) mutex deleteAt 0

/*Macro: MUTEX_TRY_LOCK(mutex)
Tries to lock the mutex without blocking. Returns immediately if the mutex is already locked.

Returns: true if successful, false if the mutex has already been locked
*/

#define MUTEX_TRY_LOCK(mutex) if((mutex pushBackUnique 0) == 0) then {true} else {false}