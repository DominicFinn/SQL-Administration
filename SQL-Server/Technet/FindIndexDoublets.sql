-- Find identically or similar indexes

-- Script to find identically or similar indexes.

/*

Many RDBMS don't allow to create identically indexes, n MS SQL Server you can do so, even if they are not usefull.
Equal indexes means additional efforts for maintenance without getting any benefit by the doublet index.

This Transact-SQL script identifies identically indexes by comparing the definition.
You can remove several WHERE conditions to find similar indexes, e.g. IndexColumnID for the column order within the index.

Works with Microsoft SQL Server 2005 or higher version in all editions.
Requieres view metadata / definition permissions.

*/

;WITH
-- Index ID with count of columns
COLSTAT AS
    (SELECT object_id AS ObjectID
           ,index_id  AS IndexID
           ,COUNT(*)  AS CntCols
     FROM sys.index_columns AS COL
     GROUP BY object_id, index_id)
-- Possible matching indexes by object_id and count of columns
,MATCHIDX AS
    (SELECT ST1.ObjectID AS ObjectID
           ,ST1.CntCols  AS CntCols
           ,ST1.IndexID  AS IndexID1
           ,ST2.IndexID  AS IndexID2
     FROM COLSTAT AS ST1
          INNER JOIN
          COLSTAT AS ST2
              ON ST1.ObjectID = ST2.ObjectID
                 AND ST1.CntCols = ST2.CntCols
                 AND ST1.IndexID <> ST2.IndexID)
-- Details of an index incl. columns.      
,IdxDetails AS
   (SELECT IDX.object_id AS ObjectID
          ,IDX.index_id  AS IndexID
          ,IDX.name      AS IndexName
          ,IDX.type_desc AS IndexType
          ,IDX.is_unique AS IsUnique
          ,COL.column_id AS ColumnID
          ,COL.index_column_id     AS IndexColumnID
          ,COL.is_descending_key   AS IsDescColumn
          ,COL.is_included_column  AS IsInclColumn
    FROM sys.indexes AS IDX
         INNER JOIN sys.index_columns AS COL
             ON IDX.object_id = COL.object_id
                AND IDX.index_id = COL.index_id)
SELECT MAX(SCH.name) + '.' + MAX(OBJ.name) AS ObjectName
      ,MAX(IDX1.IndexName) AS Index1Name
      ,MAX(IDX1.IndexType) AS Index1Type
      ,MAX(IDX2.IndexName) AS Index2Name
      ,MAX(IDX2.IndexType) AS Index2Type
FROM MATCHIDX
     INNER JOIN IdxDetails AS IDX1
         ON MATCHIDX.ObjectID = IDX1.ObjectID
            AND MATCHIDX.IndexID1 = IDX1.IndexID
     INNER JOIN IdxDetails AS IDX2
         ON MATCHIDX.ObjectID = IDX2.ObjectID
            AND MATCHIDX.IndexID2 = IDX2.IndexID
     INNER JOIN sys.objects AS OBJ
         ON MATCHIDX.ObjectID = OBJ.object_id
     INNER JOIN sys.schemas AS SCH
         ON OBJ.schema_id = SCH.schema_id
WHERE IDX1.ColumnID = IDX2.ColumnID
      AND IDX1.IndexColumnID = IDX2.IndexColumnID
      AND IDX1.IsUnique = IDX2.IsUnique
      AND IDX1.IndexType = IDX2.IndexType
      AND IDX1.IsInclColumn = IDX2.IsInclColumn
      AND IDX1.IsDescColumn = IDX2.IsDescColumn
GROUP BY MATCHIDX.ObjectID
      ,MATCHIDX.IndexID1
      ,MATCHIDX.IndexID2
      ,MATCHIDX.CntCols
HAVING MATCHIDX.CntCols = COUNT(IDX1.ColumnID)
       AND MATCHIDX.CntCols = COUNT(IDX2.ColumnID)
ORDER BY MAX(OBJ.name)
        ,MATCHIDX.IndexID1
        ,MATCHIDX.IndexID2