---- =============================================
---- Author:		Dom Finn
---- Description:	Geeking out on cached plans
---- References:
---- http://dbamohsin.wordpress.com/2011/12/21/sql-server-query-caching-sys-dm_exec_cached_plans-adhoc-plans-syscacheobjects/
---- http://msdn.microsoft.com/en-us/library/windowsazure/hh977100.aspx
---- Professional SQL Server 2008 Internals and Troubleshooting
---- http://dba.stackexchange.com/questions/19544/how-badly-do-sql-compilations-impact-the-performance-of-sql-server
---- =============================================

select *
from sys.dm_os_memory_cache_counters
where [name] in (
		'sql plans'
		,'Object Plans'
		)
		
------------------------------------------------------------------------------------------

-- each plan hash has buckets to store plans. Each bucket should contain no more than 20 objects normally
-- if a bucket has more than 100 then sort it out
select *
from sys.dm_os_memory_cache_hash_tables
where [type] in (
		'cachestore_sqlcp'
		,-- sql plans
		'cachestore_phdr' -- parsed trees that are bound already
		)
		
------------------------------------------------------------------------------------------

-- finds out which buckets have the most in them
select bucketid
	,count(*)
from sys.dm_exec_cached_plans
group by bucketid
order by 2 desc

------------------------------------------------------------------------------------------
-- then look at that specific bucket
select *
from sys.dm_exec_cached_plans cp

------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------

-- How much space in memory is being used by the plan cache 
-- for reference: our current sql server uses 3743mb and production server uses 286 and they seem to run ok
select ((SUM(cast(size_in_bytes as bigint)) / 1024) / 1024) as 'mb'
from sys.dm_exec_cached_plans;

------------------------------------------------------------------------------------------

-- How many adhoc plans have only been used once.... 
-- if you have hundreds or a large portion compared to your total plans
-- it probably meaning that there's a parameterisation problem
select 'count of plans'
	,count(*)
from sys.dm_exec_cached_plans
where objtype = 'ADHOC'
union

select 'adhoc with 1 use count'
	,count(*)
from sys.dm_exec_cached_plans
where objtype = 'ADHOC'
	and usecounts < 2;

------------------------------------------------------------------------------------------

-- this is a count of the types of cached objects
select cacheobjtype
	,objtype
	,count(*)
from sys.dm_exec_cached_plans
group by cacheobjtype
	,objtype
order by cacheobjtype
	,objtype
	
/*

when plans are determined that they are no longer valid they need to be recompiled. This happens on a schema change or when 
the statistics change. When someone goes to run the query and it needs to be cached again it will either be compiled or recompiled
depending on if the query is in use or not

use perfmon to monitor these events: SQL Server object

SQL Statistics\Batch Requests/sec
SQL Statistics\SQL Compilations/sec
SQL Statistics\SQL Re-Compilations/sec

keep an eye on the ratio of compilations/batch request, lower is better

It's a general rule of thumb that Compilations/sec should be at 10% or less than total Batch Requests/sec.

*/

------------------------------------------------------------------------------------------

-- query to look for frequently recompiled queries... this could be recorded as a trend over time
SELECT TOP 50
    qs.plan_generation_num,
    qs.execution_count,
    qs.statement_start_offset,
    qs.statement_end_offset,
    st.text
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
    WHERE qs.plan_generation_num > 1
    ORDER BY qs.plan_generation_num DESC
    
------------------------------------------------------------------------------------------    
    
-- To get a ratio of how many single-use count plans you have compared to all cached plans: 
declare @single_use_counts int, @multi_use_counts int

;with PlanCacheCte as 
(
    select
        db_name(st.dbid) as database_name,
        cp.bucketid,
        cp.usecounts,
        cp.size_in_bytes,
        cp.objtype,
        st.text
    from sys.dm_exec_cached_plans cp
    cross apply sys.dm_exec_sql_text(cp.plan_handle) st
    where cp.cacheobjtype = 'Compiled Plan'
)
select @single_use_counts = count(*)
from PlanCacheCte
where usecounts = 1

;with PlanCacheCte as 
(
    select
        db_name(st.dbid) as database_name,
        cp.bucketid,
        cp.usecounts,
        cp.size_in_bytes,
        cp.objtype,
        st.text
    from sys.dm_exec_cached_plans cp
    cross apply sys.dm_exec_sql_text(cp.plan_handle) st
    where cp.cacheobjtype = 'Compiled Plan'
)
select @multi_use_counts = count(*)
from PlanCacheCte
where usecounts > 1

------------------------------------------------------------------------------------------

--to drill down into what's being cached

select
    @single_use_counts as single_use_counts,
    @multi_use_counts as multi_use_counts,
    @single_use_counts * 1.0 / (@single_use_counts + @multi_use_counts) * 100
        as percent_single_use_counts    
        
        
        
select
    db_name(st.dbid) as database_name,
    cp.bucketid,
    cp.usecounts,
    cp.size_in_bytes,
    cp.objtype,
    st.text
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st