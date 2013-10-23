--- indexes

-- Identify Index Defragmentation
declare @tablename varchar(200)
set @tablename = ''

select	ps.database_id(), object_name(ps.object_Id),
		ps.index_id,
		b.name,
		ps.avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (db_id(), null, null, null, null) ps
inner join sys.indexes as b on ps.object_id = b.object_id
and ps.index_id = b.index_id
where ps.database_id = db_id()
and b.object_id = objecT_id(tablename)
order by ps.object_id


alter index indexname
on tablename reorganize
go

alter index indexname
on tablename rebuild
go

-- a big task....
alter index all on tablename rebuild 


-- index maintenance screipt from ola hellengren
-- index optiom
-- http://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html
execute master.dbo.indexoptimize @databases = 'name of database'
-- sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'USER_DATABASES', @LogToTable = 'Y'" -b

SELECT OBJECT_NAME(OBJECT_ID), index_id,index_type_desc,index_level,
avg_fragmentation_in_percent,avg_page_space_used_in_percent,page_count
FROM sys.dm_db_index_physical_stats
(DB_ID(N'nameofdatabase'), NULL, NULL, NULL , 'SAMPLED')
ORDER BY avg_fragmentation_in_percent DESC