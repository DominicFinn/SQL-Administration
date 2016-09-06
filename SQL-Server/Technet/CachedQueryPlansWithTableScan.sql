/*
http://gallery.technet.microsoft.com/scriptcenter/Get-all-SQL-Statements-0622af19

"Table scan" (and also "Index scan") can cause poor performance, especially when they are performed on large tables.
To identify queries causing such scans you can use the SQL Profiler with the events "Scans" => "Scan:Started" and "Scan.Stopped".
Other option is to analyse the cached query plans.
This Transact-SQL statements filters the cached query plans for existing table scan operators and returns the statement and query statistics.
An additional filter is set on the attribute "EstimateRows * @AvgRowSize" = "Estimate size" to filter out scans on small tables.
Note: The xml data of the cached query plans is not indexed in the DMV, therefore the query can run up to several minutes.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permissions.
*/

-- Get all SQL Statements with "table scan" in cached query plan
;WITH 
 XMLNAMESPACES
    (DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'  
            ,N'http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS ShowPlan) 
,EQS AS
    (SELECT EQS.plan_handle
           ,SUM(EQS.execution_count) AS ExecutionCount
           ,SUM(EQS.total_worker_time) AS TotalWorkTime
           ,SUM(EQS.total_logical_reads) AS TotalLogicalReads
           ,SUM(EQS.total_logical_writes) AS TotalLogicalWrites
           ,SUM(EQS.total_elapsed_time) AS TotalElapsedTime
           ,MAX(EQS.last_execution_time) AS LastExecutionTime
     FROM sys.dm_exec_query_stats AS EQS
     GROUP BY EQS.plan_handle)   
SELECT EQS.[ExecutionCount]
      ,EQS.[TotalWorkTime]
      ,EQS.[TotalLogicalReads]
      ,EQS.[TotalLogicalWrites]
      ,EQS.[TotalElapsedTime]
      ,EQS.[LastExecutionTime]
      ,ECP.[objtype] AS [ObjectType]
      ,ECP.[cacheobjtype] AS [CacheObjectType]
      ,DB_NAME(EST.[dbid]) AS [DatabaseName]
      ,OBJECT_NAME(EST.[objectid], EST.[dbid]) AS [ObjectName]
      ,EST.[text] AS [Statement]      
      ,EQP.[query_plan] AS [QueryPlan]
FROM sys.dm_exec_cached_plans AS ECP
     INNER JOIN EQS
         ON ECP.plan_handle = EQS.plan_handle     
     CROSS APPLY sys.dm_exec_sql_text(ECP.[plan_handle]) AS EST
     CROSS APPLY sys.dm_exec_query_plan(ECP.[plan_handle]) AS EQP
WHERE EQP.[query_plan].exist('data(//RelOp[@PhysicalOp="Table Scan"][@EstimateRows * @AvgRowSize > 50000.0][1])') = 1
      -- Optional filters
      AND EQS.[ExecutionCount] > 1  -- No Ad-Hoc queries
      AND ECP.[usecounts] > 1
ORDER BY EQS.TotalElapsedTime DESC
        ,EQS.ExecutionCount DESC;