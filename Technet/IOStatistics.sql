/*
IO ist still the biggest bottleneck and performance issue for a SQL Server. To get the best performance a good IO hardware strategy is required.
And in the planning you have to consider well where to locate which databases; but how to plan this?

With this Transact-SQL script you can analyse the IO statistics, from total overview down to file level.
Because of the use of CTE (common table expressions) you can easily modify the existing query or create your own statistic queries.
Three samples are already include, just remove the comments for the query of your interest.

Works with SQL Server 2005 and higher versions in all editions.
Requires VIEW SERVER STATE permissions.

Link:
  sys.dm_io_virtual_file_stats http://msdn.microsoft.com/en-US/library/ms190326.aspx
*/

-- Various SQL Server IO Statistics
;WITH 
 IOT AS    -- Total sums of all properties.
   (SELECT SUM(IOS.num_of_reads) AS Reads
          ,SUM(IOS.num_of_bytes_read) BytesRead
          ,SUM(IOS.io_stall_read_ms) AS IoStallReadMs
          ,SUM(IOS.num_of_writes) AS Writes
          ,SUM(IOS.num_of_bytes_written) AS BytesWritten
          ,SUM(IOS.io_stall_write_ms) AS IoStallWritesMs
          ,SUM(IOS.io_stall) AS IoStall
          ,SUM(IOS.size_on_disk_bytes) SizeOnDisk
    FROM sys.dm_io_virtual_file_stats(default, default) AS IOS)
,IOF AS   
   (SELECT DBS.name AS DatabaseName
          ,MF.name AS [FileName]
          ,MF.type_desc AS FileType
          ,SUBSTRING(MF.physical_name, 1, 3) AS Drive
          ,CASE WHEN DBS.name IN ('master', 'model', 'msdb', 'tempdb')
                THEN 1 ELSE 0 END AS IsSystemDB
          ,IOS.*
    FROM sys.dm_io_virtual_file_stats(default, default) AS IOS
         INNER JOIN sys.databases AS DBS
             ON IOS.database_id = DBS.database_id
         INNER JOIN sys.master_files AS MF
             ON IOS.database_id = MF.database_id
                AND IOS.file_id = MF.file_id)
/*
-- Detailed for each file
SELECT IOF.DatabaseName
      ,IOF.FileName
      ,IOF.FileType
      ,CONVERT(numeric(5,2), 100.0 * IOF.num_of_reads / IOT.Reads) AS [Reads%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.num_of_bytes_read / IOT.BytesRead) AS [BytesRead%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.io_stall_read_ms / IOT.IoStallReadMs) AS [IoStallReadMs%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.num_of_writes / IOT.Writes) AS [Writes%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.num_of_bytes_written / IOT.BytesWritten) AS [BytesWritten%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.io_stall_write_ms / IOT.IoStallWritesMs) AS [IoStallWritesMs%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.io_stall / IOT.IoStall) AS [IoStall%]
      ,CONVERT(numeric(5,2), 100.0 * IOF.size_on_disk_bytes / IOT.SizeOnDisk) AS [SizeOnDisk%]
FROM IOF CROSS APPLY IOT
ORDER BY IOF.DatabaseName
        ,IOF.FileType;
*/

/*
-- Overview by file type
SELECT IOF.FileType
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_reads / IOT.Reads)) AS [Reads%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_bytes_read / IOT.BytesRead)) AS [BytesRead%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall_read_ms / IOT.IoStallReadMs)) AS [IoStallReadMs%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_writes / IOT.Writes)) AS [Writes%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_bytes_written / IOT.BytesWritten)) AS [BytesWritten%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall_write_ms / IOT.IoStallWritesMs)) AS [IoStallWritesMs%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall / IOT.IoStall)) AS [IoStall%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.size_on_disk_bytes / IOT.SizeOnDisk)) AS [SizeOnDisk%]
FROM IOF CROSS APPLY IOT
GROUP BY IOF.FileType
ORDER BY IOF.FileType;
*/

-- Overview per drive
SELECT IOF.Drive
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_reads / IOT.Reads)) AS [Reads%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_bytes_read / IOT.BytesRead)) AS [BytesRead%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall_read_ms / IOT.IoStallReadMs)) AS [IoStallReadMs%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_writes / IOT.Writes)) AS [Writes%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.num_of_bytes_written / IOT.BytesWritten)) AS [BytesWritten%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall_write_ms / IOT.IoStallWritesMs)) AS [IoStallWritesMs%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.io_stall / IOT.IoStall)) AS [IoStall%]
      ,CONVERT(numeric(5,2), SUM(100.0 * IOF.size_on_disk_bytes / IOT.SizeOnDisk)) AS [SizeOnDisk%]
FROM IOF CROSS APPLY IOT
GROUP BY IOF.Drive
ORDER BY IOF.Drive;
