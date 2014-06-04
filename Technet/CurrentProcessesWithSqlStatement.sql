/*
What's currently going on on the SQL Server, who is executing which query or fetches a few thousands of rows and slowing down the server with it?
With this Transact-SQL script you can list all processes with their SQL statements.
Additional you get the cummulative values of IO / CPU usage and the row count of the last statement execution.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permissions.
*/

-- Current processes and their SQL statements
SELECT PRO.loginame AS LoginName
      ,DB.name AS DatabaseName
      ,PRO.[status] as ProcessStatus
      ,PRO.cmd AS Command
      ,PRO.last_batch AS LastBatch
      ,PRO.cpu AS Cpu
      ,PRO.physical_io AS PhysicalIo
      ,SES.row_count AS [RowCount]
      ,STM.[text] AS SQLStatement
FROM sys.sysprocesses AS PRO
     INNER JOIN sys.databases AS DB
         ON PRO.dbid = DB.database_id
     INNER JOIN sys.dm_exec_sessions AS SES
        ON PRO.spid = SES.session_id
     CROSS APPLY sys.dm_exec_sql_text(PRO.sql_handle) AS STM     
WHERE PRO.spid >= 50  -- Exclude system processes
ORDER BY PRO.physical_io DESC
        ,PRO.cpu DESC;