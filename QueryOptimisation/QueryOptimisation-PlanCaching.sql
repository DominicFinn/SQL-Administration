---- =============================================
---- Author:		Dom Finn
---- Description:	Geeking out on cached plans
---- References:
---- http://dbamohsin.wordpress.com/2011/12/21/sql-server-query-caching-sys-dm_exec_cached_plans-adhoc-plans-syscacheobjects/
---- http://msdn.microsoft.com/en-us/library/windowsazure/hh977100.aspx
---- Professional SQL Server 2008 Internals and Troubleshooting
---- =============================================

select *
from sys.dm_os_memory_cache_counters
where [name] in (
		'sql plans'
		,'Object Plans'
		)

-- each plan hash has buckets to store plans. Each bucket should contain no more than 20 objects normally
-- if a bucket has more than 100 then sort it out
select *
from sys.dm_os_memory_cache_hash_tables
where [type] in (
		'cachestore_sqlcp'
		,-- sql plans
		'cachestore_phdr' -- parsed trees that are bound already
		)

-- finds out which buckets have the most in them
select bucketid
	,count(*)
from sys.dm_exec_cached_plans
group by bucketid
order by 2 desc

-- then look at that specific bucket
select *
from sys.dm_exec_cached_plans cp

-- take a look here http://technet.microsoft.com/en-us/library/ms187404.aspx for the explanation of the values returned
-- memory breakdown of cahced compiled plans
select plan_handle
	,ecp.memory_object_address as CompiledPlan_MemoryObject
	,omo.memory_object_address
	,pages_allocated_count
	,type
	,page_size_in_bytes
from sys.dm_exec_cached_plans as ecp
inner join sys.dm_os_memory_objects as omo on ecp.memory_object_address = omo.memory_object_address
	or ecp.memory_object_address = omo.parent_address
where cacheobjtype = 'Compiled Plan';
go

-- How much space in memory is being used by the plan cache 
-- for reference: our current sql server uses 3743mb and production server uses 286 and they seem to run ok
select ((SUM(cast(size_in_bytes as bigint)) / 1024) / 1024) as 'mb'
from sys.dm_exec_cached_plans;

-- How many plans have only been used once.... 
-- if you have hundreds or a large portion compared to your total plans
-- it probably meaning that there's a parameterisation problem
select 'count of plans'
	,count(*)
from sys.dm_exec_cached_plans

union

select 'adhoc with 1 use count'
	,count(*)
from sys.dm_exec_cached_plans
where objtype = 'ADHOC'
	and usecounts < 2;

-- this is a count of the types of cached objects
select cacheobjtype
	,objtype
	,count(*)
from sys.dm_exec_cached_plans
group by cacheobjtype
	,objtype
order by cacheobjtype
	,objtype