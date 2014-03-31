-- Missing Indexes

-- Missing Index Script
-- Original Author: Pinal Dave (C) 2011
select   top 25 Dm_Mid.Database_Id as Databaseid,
                Dm_Migs.Avg_User_Impact * (Dm_Migs.User_Seeks + Dm_Migs.User_Scans) as Avg_Estimated_Impact,
                Dm_Migs.Last_User_Seek as Last_User_Seek,
                OBJECT_NAME(Dm_Mid.OBJECT_ID, Dm_Mid.Database_Id) as [Tablename],
                'create index [IX_' + OBJECT_NAME(Dm_Mid.OBJECT_ID, Dm_Mid.Database_Id) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(Dm_Mid.Equality_Columns, ''), ', ', '_'), '[', ''), ']', '') + case 
when Dm_Mid.Equality_Columns is not null
                                                                                                                                                                                                        and Dm_Mid.Inequality_Columns is not null then '_' else '' 
end + REPLACE(REPLACE(REPLACE(ISNULL(Dm_Mid.Inequality_Columns, ''), ', ', '_'), '[', ''), ']', '') + ']' + ' on ' + Dm_Mid.Statement + ' (' + ISNULL(Dm_Mid.Equality_Columns, '') + case 
when Dm_Mid.Equality_Columns is not null
                                                                                                                                                                                                                                                                                                                                                                                                                                                                  and Dm_Mid.Inequality_Columns is not null then ',' else '' 
end + ISNULL(Dm_Mid.Inequality_Columns, '') + ')' + ISNULL(' include (' + Dm_Mid.Included_Columns + ')', '') as Create_Statement
from     Sys.Dm_Db_Missing_Index_Groups as Dm_Mig
         inner join
         Sys.Dm_Db_Missing_Index_Group_Stats as Dm_Migs
         on Dm_Migs.Group_Handle = Dm_Mig.Index_Group_Handle
         inner join
         Sys.Dm_Db_Missing_Index_Details as Dm_Mid
         on Dm_Mig.Index_Handle = Dm_Mid.Index_Handle
where    Dm_Mid.Database_ID = DB_ID()
order by Avg_Estimated_Impact desc;