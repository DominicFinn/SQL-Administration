/*
http://gallery.technet.microsoft.com/scriptcenter/List-expensive-queries-f6d63ac6

This Transact-SQL script returns the values from DMV sys.dm_exec_query_stats to rate SQL statements by their costs.
These "costs" can be
- AvgCPUTimeMiS = Average CPU execution time
- AvgLogicalIo  = Average logical operations
or the total values of this measures.
The statement returns only statistics for queries which at least have been executed once in the past month.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permissions.

Link:
  http://msdn.microsoft.com/de-de/library/ms189741.aspx
*/

-- List expensive queries
DECLARE @MinExecutions int;
SET @MinExecutions = 5

SELECT EQS.total_worker_time AS TotalWorkerTime
      ,EQS.total_logical_reads + EQS.total_logical_writes AS TotalLogicalIO
      ,EQS.execution_count As ExeCnt
      ,EQS.last_execution_time AS LastUsage
      ,EQS.total_worker_time / EQS.execution_count as AvgCPUTimeMiS
      ,(EQS.total_logical_reads + EQS.total_logical_writes) / EQS.execution_count 
       AS AvgLogicalIO
      ,DB.name AS DatabaseName
      ,SUBSTRING(EST.text
                ,1 + EQS.statement_start_offset / 2
                ,(CASE WHEN EQS.statement_end_offset = -1 
                       THEN LEN(convert(nvarchar(max), EST.text)) * 2 
			           ELSE EQS.statement_end_offset END 
                 - EQS.statement_start_offset) / 2
                ) AS SqlStatement
      -- Optional with Query plan; remove comment to show, but then the query takes !!much longer time!!
      --,EQP.[query_plan] AS [QueryPlan]
FROM sys.dm_exec_query_stats AS EQS
     CROSS APPLY sys.dm_exec_sql_text(EQS.sql_handle) AS EST
     CROSS APPLY sys.dm_exec_query_plan(EQS.plan_handle) AS EQP
     LEFT JOIN sys.databases AS DB
         ON EST.dbid = DB.database_id     
WHERE EQS.execution_count > @MinExecutions
      AND EQS.last_execution_time > DATEDIFF(MONTH, -1, GETDATE())
ORDER BY AvgLogicalIo DESC
        ,AvgCPUTimeMiS DESC