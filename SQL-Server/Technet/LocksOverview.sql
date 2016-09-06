/*
http://gallery.technet.microsoft.com/scriptcenter/Overview-of-Locks-per-0e7f8fee
Take a peek at this to see the different types of locks that are currently on the databases, watch out for massive X's etc.... !

This Transact-SQL gives a quick overview of the counts of locks per database, lock type and status.
It reflects the current activities on the databases.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permission on the server.

Links:
  sys.dm_tran_locks: http://msdn.microsoft.com/en-us/library/ms190345.aspx
*/

-- Overview of Locks per Database and Type
SELECT DB.name AS DatabaseName
      ,TL.request_mode AS ReqMode
      ,TL.request_type AS ReqType
      ,TL.request_status AS ReqStatus
      ,TL.request_owner_type AS ReqOwner
      ,COUNT(*) AS LocksCount
FROM sys.databases AS DB
     INNER JOIN sys.dm_tran_locks AS TL
         ON DB.database_id = TL.resource_database_id
GROUP BY DB.name
        ,TL.request_mode
        ,TL.request_type
        ,TL.request_status
        ,TL.request_owner_type;


SELECT DB.name AS DatabaseName
      ,TL.request_mode AS ReqMode
      ,TL.request_type AS ReqType
      ,TL.request_status AS ReqStatus
      ,TL.request_owner_type AS ReqOwner,
	  TL.*
FROM sys.databases AS DB
     INNER JOIN sys.dm_tran_locks AS TL
         ON DB.database_id = TL.resource_database_id
where DB.name = 'something'

SELECT object_name(object_id), *
    FROM sys.partitions
    WHERE hobt_id='72057594064601088'


-- Find out what is blocked....
SELECT 
        t1.resource_type,
        t1.resource_database_id,
        t1.resource_associated_entity_id,
        t1.request_mode,
        t1.request_session_id,
        t2.blocking_session_id
    FROM sys.dm_tran_locks as t1
    INNER JOIN sys.dm_os_waiting_tasks as t2
        ON t1.lock_owner_address = t2.resource_address;



SELECT STasks.session_id, SThreads.os_thread_id
    FROM sys.dm_os_tasks AS STasks
    INNER JOIN sys.dm_os_threads AS SThreads
        ON STasks.worker_address = SThreads.worker_address
    WHERE STasks.session_id IS NOT NULL
    ORDER BY STasks.session_id;
GO




