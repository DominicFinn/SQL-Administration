/*
Storage IO is still a big bottleneck. If you perform larger DML statements SQL Server have to access the storage frequently.
The DMV dm_io_pending_io_requests gives you informations of such pending IO operations. With this informations you can create statistics of how many current pending operations exists and the wait times of them.
The more pending IoRequests you have and the higher the PendingWaitTimes are, the worse the performance gets. 
This Transact-SQL script lists all OS scheduler and work with the sum of pending Io requests and the time in ticks.

It also (can) demonstrate the advantage if the best-pratice pattern "one database file per processor core".
If you have only one database file and you are currently working on one database, then only one Cpu core will handle the requests (and may a second for the log file).

Remark:
In SQL Server 2005 the "CpuID" returns only the Cpu affinity, in 2008 and higher it returns the real Cpu Id.

Link:
  sys.dm_io_pending_io_requests: http://msdn.microsoft.com/en-us/library/ms188762.aspx
  sys.dm_os_schedulers: http://msdn.microsoft.com/en-us/library/ms177526.aspx
  sys.dm_os_workers: http://msdn.microsoft.com/en-us/library/ms178626.aspx
*/

-- Pending IO Requests
;WITH 
 pir AS
    (SELECT PIR.scheduler_address
           ,COUNT(*) AS PendIoRequests
           ,SUM(PIR.io_pending_ms_ticks) AS PendWaitTime
     FROM sys.dm_io_pending_io_requests AS PIR
     GROUP BY PIR.scheduler_address
     )
,req AS
     (SELECT ER.task_address
            ,COUNT(*) AS ReqCnt
            ,COUNT(DISTINCT ER.database_id) AS ReqDbCnt
            ,SUM(ER.wait_time) AS ReqWaitTime
      FROM sys.dm_exec_requests AS ER
      GROUP BY ER.task_address
     )
SELECT OS.scheduler_id AS Scheduler
      ,OS.cpu_id AS CpuId
      ,CASE WHEN OS.scheduler_id < 1048576
            THEN 'Query'
            ELSE 'Internal' END AS Scheduler
      ,OS.[status] AS OsStatus
      ,OS.current_workers_count AS CurrWrk
      ,OS.active_workers_count AS ActWrk
      ,OS.pending_disk_io_count AS pDiskIo
      ,OW.pending_io_count AS pIoCount
      ,OW.pending_io_byte_count AS pIoBytes
      ,OW.[state] AS WorkerState
      ,req.ReqDbCnt
      ,req.ReqCnt
      ,req.ReqWaitTime
      ,pir.PendIoRequests
      ,pir.PendWaitTime
FROM sys.dm_os_schedulers AS OS
     INNER JOIN sys.dm_os_workers AS OW
         ON OS.active_worker_address = OW.worker_address    
     -- Change it to INNER join to get only pending schedulers
     LEFT JOIN pir
         ON pir.scheduler_address = OS.scheduler_address
     LEFT JOIN req
         ON req.task_address = OW.task_address
ORDER BY OS.scheduler_id;