-- Pages per object in buffer pool.

-- Lists the sum of pages per user object hold in the SQL Server buffer pool.

/*
Based on the DMV sys.dm_os_buffer_descriptors this script lists the sum of pages per user object actually hold in the SQL Server buffer pool.
The list is ordered by the total pages in buffer. This values indicates the most frequently used objects & indexes. 
If you run the DBCC DROPCLEANBUFFERS you can see afterwards how to buffer pool is populated with new buffered pages.
This can be usefull to create a cache-warming strategie to speed up application response after a server reboot (e.g. after installing patches).

Requires VIEW SERVER STATE permissions.
Works with Microsoft SQL Server 2005 and higher versions in all editions.
*/


-- Lists the sum of pages per user object hold in the SQL Server buffer pool.
SELECT SCH.name + '.' + OBJ.name AS ObjectName
      ,MAX(OBJ.type_desc) AS ObjectType
      ,IDX.name AS IndexName
      ,MAX(IDX.type_desc) AS IndexType
      ,OBD.page_type AS PageType
      ,COUNT(OBD.page_id) AS PagesInOsBuffer
      ,SUM(AU.total_pages) AS OfTotalObjectPages
      ,SUM(OBD.row_count) AS RowsInOsBuffer
      ,SUM(PRT.rows) AS OfTotalObjectRows
  FROM sys.dm_os_buffer_descriptors AS OBD
       INNER JOIN sys.allocation_units AS AU
           ON OBD.allocation_unit_id = AU.allocation_unit_id
       INNER JOIN sys.partitions AS PRT
           ON (AU.container_id = PRT.partition_id 
               AND AU.type = 2)
              OR
              (AU.container_id = PRT.hobt_id 
               AND AU.type IN(1, 3))
       INNER JOIN sys.objects AS OBJ
           ON PRT.object_id = OBJ.object_id
       INNER JOIN sys.schemas AS SCH
           ON OBJ.schema_id = SCH.schema_id
       INNER JOIN sys.indexes AS IDX
           ON PRT.object_id = IDX.object_id
              AND PRT.index_id = IDX.index_id
WHERE OBD.database_id = DB_ID()   -- Only objec
      AND OBJ.type = 'U'          -- Filter on user tables
GROUP BY SCH.name
        ,OBJ.name
        ,IDX.name
        ,OBD.page_type
ORDER BY PagesInOsBuffer DESC
        ,ObjectName ASC