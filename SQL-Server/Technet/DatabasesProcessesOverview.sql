/*
This Transact-SQL script gives a brief overview of
- count of processes
- count of distinct users and hosts connected to
- last batch execution
- total cpu, IO and memory usage
- open transactions
 per database; it reflects the current activity.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permissions.
*/

-- Databases Processes Overview
;WITH pro AS
   (SELECT PRO.dbid 
          ,COUNT(*) AS Processes
          ,SUM(PRO.cpu) AS Cpu
          ,SUM(PRO.physical_io) AS PhysicalIo
          ,SUM(PRO.memusage) AS MemUsage
          ,MAX(PRO.last_batch) AS LastBatch
          ,SUM(PRO.open_tran) AS OpenTran
          ,COUNT(DISTINCT PRO.sid) AS Users
          ,COUNT(DISTINCT PRO.hostname) AS Host
    FROM sys.sysprocesses AS PRO
    GROUP BY PRO.dbid)
SELECT DB.name AS DatabaseName
      ,pro.*
      ,DB.log_reuse_wait_desc AS LogReUse
FROM sys.databases AS DB
     LEFT JOIN pro
         ON DB.database_id = pro.dbid
ORDER BY DB.name;
