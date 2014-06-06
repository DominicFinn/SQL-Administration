set transaction isolation level read uncommitted


DECLARE @page_count_minimum smallint     
DECLARE @fragmentation_minimum float

SET @page_count_minimum   = 50
SET @fragmentation_minimum   = 30

SELECT
	sys.objects.name AS Table_Name,
	sys.indexes.name AS Index_Name,	
	avg_fragmentation_in_percent AS frag,
	page_count AS page_count,
	sys.dm_db_index_physical_stats.object_id AS objectid,
	sys.dm_db_index_physical_stats.index_id AS indexid,
	partition_number AS partitionnum,
	case 
		when avg_fragmentation_in_percent > 40 then 'alter index ' + sys.indexes.name + '	on ' + sys.objects.name + ' rebuild'	
		else 'alter index '  + sys.indexes.name +  '	on '  + sys.objects.name +  ' reorganize'	
	end as [script]
FROM sys.dm_db_index_physical_stats (DB_ID(N'NameOfDatabase'), NULL, NULL , NULL, 'SAMPLED')
	inner join sys.objects 
		on sys.objects.object_id = sys.dm_db_index_physical_stats.object_id
	inner join sys.indexes 
		on sys.indexes.index_id = sys.dm_db_index_physical_stats.index_id 
			and sys.indexes.object_id = sys.dm_db_index_physical_stats.object_id
WHERE avg_fragmentation_in_percent > @fragmentation_minimum 
	AND sys.dm_db_index_physical_stats.index_id > 0 
	AND page_count > @page_count_minimum
ORDER BY page_count DESC

-- OVERVIEW
SELECT OBJECT_NAME(OBJECT_ID), *
FROM sys.dm_db_index_physical_stats
(DB_ID(N'Reports'), NULL, NULL, NULL , 'SAMPLED') -- can swap for LIMITED OR DETAILED
ORDER BY avg_fragmentation_in_percent DESC