--http://gallery.technet.microsoft.com/scriptcenter/ec6abcda-e451-4863-92ed-8648fdfc67ac

-- Database size growth as a pivot table

-- Transact-SQL script to analyse the database size growth using backup history.

/*
This Transact-SQL script uses the backup history to analyse the growth of the databases size over last twelve months and expose
the average size of each month per database in a pivot table.
The values are useful for future resource planning of the storage and backup system.

Works with MS SQL Server 2005 and higher versions in all editions.
Requires access and select permissions to the msdb system database.
*/

-- Transact-SQL script to analyse the database size growth using backup history.
DECLARE @startDate datetime;
SET @startDate = GetDate();

SELECT PVT.DatabaseName
      , PVT.[0], PVT.[-1], PVT.[-2], PVT.[-3],  PVT.[-4],  PVT.[-5],  PVT.[-6]
               , PVT.[-7], PVT.[-8], PVT.[-9], PVT.[-10], PVT.[-11], PVT.[-12]
FROM
   (SELECT BS.database_name AS DatabaseName
          ,DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
          ,CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM msdb.dbo.backupset as BS
         INNER JOIN
         msdb.dbo.backupfile AS BF
             ON BS.backup_set_id = BF.backup_set_id
    WHERE NOT BS.database_name IN
              ('master', 'msdb', 'model', 'tempdb')
          AND BF.[file_type] = 'D'
          AND BS.backup_start_date BETWEEN DATEADD(yy, -1, @startDate) AND @startDate
    GROUP BY BS.database_name
            ,DATEDIFF(mm, @startDate, BS.backup_start_date)
    ) AS BCKSTAT
PIVOT (SUM(BCKSTAT.AvgSizeMB)
       FOR BCKSTAT.MonthsAgo IN ([0], [-1], [-2], [-3], [-4], [-5], [-6], [-7], [-8], [-9], [-10], [-11], [-12])
      ) AS PVT
ORDER BY PVT.DatabaseName;