/*
The Basics

Transaction -	the unit of work performed in the database
Lock -			the sync mechanism on a resource that stops concurrent changes on it
Lock Mode -		the type of lock, defines what access other resources can have whilst a lock is occuring
Blocking -		when a transaction requests a lock mode that won't work with a lock that is currently on a resource
				and has to wait for the release
Deadlock -		when 2 transactions go for the same resource with conflicting locks

**Lock Granularity
RID/KEY -		row level locking (the lowest level you can, stops a row being updated)
PAGE	-		a single page in the database is locked
HoBT	-		A whole heap or b tree index is locked (lock at partition level)
Table	-		A whole table is locked whilst the lock is in place
META DATA -		the table schema definition is locked

As you go down the list of the above, concurrency gets harder and harder......


For example if you delete a row in a database, 

you will created intent exclusive locks on the table and page and an exclusive lock on the row until it's removed

** Lock Types

Shared (S) -	Locks the data for READS, other operations can still READ the data
Update (U) -	Used for locking resource to update it. You can only have 1 U lock at a time on the resource
				it is changing...
				Prevents deadlocks caused by lock conversions from an S to an X
Exclusive (X) -	No concurrent transactions, changes can't be made. Only READS with NOLOCK or the like can select from it
Intent (I) -	Locks on surrounding resources that have an X so the carpet isn't pulled up from them, for example
				you couldn't update all rows in the database (which would need a table lock) if a row has an X on it. 
				IS, IX, SIX, IU, SIU, UIX -> Loads of different types of these..... :-/

Check here http://msdn.microsoft.com/en-us/library/ms186396(v=sql.105).aspx to see which are compatible with
one another.....

** Isolation Levels and Locking Hints

Read Uncomitted, Read Committed, Reapeatable Read, Snapshot, Serializable
There are loads and loads of hints. Meh....
http://msdn.microsoft.com/en-us/library/ms186396(v=sql.105).aspx

Depending on the lock granularity -> 

If you are running low on memory or you need too many locks on a smaller resource, it will be escalated. 
For example, if you have to many rows locked, it will jump up to the page level. If you have too many page it
will jump up to table. Generally this is bad as more and more unneeded resources will be locked and other 
transactions will be blocked....

* DeadLock Detection
Starts by searching every 5 secs, if it finds any it starts speeding up detection. 

Take a little peek at Deadlock Priority
DEADLOCK_PRIORITY

*/

-- Trace flags

-- on for session
dbcc traceon(1222)
dbcc tracestatus

-- global
dbcc traceon(1222, -1)

-- you can also add as a startup parameter in sql config manager... 


