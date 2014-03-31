/*

*Unnused Indexes

** Consume disk space
** Queries may use less efficient indexes
** Potentially get less efficient execution plans
** Reduction in overall server performance -> maintaining pointless indexes if auto stats are on
** Confuses you when troubleshooting

-> Get rid of them! 
_ But watch out for important reporting indexes that aren't used often....


* Duplicate Indexes

** Reduces insert, update and delete performance
** Waste of space

-> Get rid of them!

* Missing Indexes

** Create narrow width indexes
** Column order can be very important

-> Check out the missing index dmv, track the results over time....
*/

-- Unused Index Script
-- Original Author: Pinal Dave (C) 2011
select top 25 o.name as ObjectName
	,i.name as IndexName
	,i.index_id as IndexID
	,dm_ius.user_seeks as UserSeek
	,dm_ius.user_scans as UserScans
	,dm_ius.user_lookups as UserLookups
	,dm_ius.user_updates as UserUpdates
	,p.TableRows
	,'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) as 'drop statement'
from sys.dm_db_index_usage_stats dm_ius
inner join sys.indexes i on i.index_id = dm_ius.index_id
	and dm_ius.OBJECT_ID = i.OBJECT_ID
inner join sys.objects o on dm_ius.OBJECT_ID = o.OBJECT_ID
inner join sys.schemas s on o.schema_id = s.schema_id
inner join (
	select SUM(p.rows) TableRows
		,p.index_id
		,p.OBJECT_ID
	from sys.partitions p
	group by p.index_id
		,p.OBJECT_ID
	) p on p.index_id = dm_ius.index_id
	and dm_ius.OBJECT_ID = p.OBJECT_ID
where OBJECTPROPERTY(dm_ius.OBJECT_ID, 'IsUserTable') = 1
	and dm_ius.database_id = DB_ID()
	and i.type_desc = 'nonclustered'
	and i.is_primary_key = 0
	and i.is_unique_constraint = 0
order by (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) asc
go

	




