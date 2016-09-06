---- =============================================
---- Author:		Dom Finn
---- Description:	Looking at Exectution plans
---- References:
---- Professional SQL Server 2008 Internals and Troubleshooting
---- http://technet.microsoft.com/en-us/library/bb326654.aspx
---- http://technet.microsoft.com/en-us/library/bb326654.aspx
---- Pluralsight video SQL Server: Query Plan Analysis
---- =============================================

-- you can get a query plan by using the include actual query plan in management studio, if you don't have 
-- management studio you can do 


-- IT'S WORTH NOTING THAT THE TEXT CAPTURES ARE ON A DEPRECATION PLAN, STICK WITH THE XML ONES

-- When you do this, you get an estimated execution plan. Not the actual estimation plan
--set showplan_xml on
--go
---- run query 
--go
--set showplan_xml off
--go

--set statistics (profile|xml) on
--go

--set statistics (profile|xml) off
--go

-- you can also do showplan_text / showplan_all

-- if you need to find the query plan for a particular query that is running, it will be cached. You will need a plan handle...
select db_name(st.dbid) as database_name
	,cp.bucketid
	,cp.usecounts
	,cp.size_in_bytes
	,cp.objtype
	,st.text
	,cp.plan_handle
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
-- you can then do where st.text like '%your sp name%'

-- worth noting that dm_exec_text_query_plan works better for ENOURMOUS query plans, you will probably won't need this
-- if you do, you often have bigger problems...

-- with a plan handle from the above, you can then get the (estimated) execution plan. Click on the query plan and it will graphically
-- show the xml
select *
from sys.dm_exec_query_plan(0x050004007C635A7C40A14C91000000000000000000000000)

-- or you can cross apply the sp to all the cached plans for example... or mix and match....
select *
from sys.dm_exec_cached_plans as cp
cross apply sys.dm_exec_text_query_plan(cp.plan_handle, default, default);

---------------------------------------------------------------------------------------------------
-- getting the execution plan for a slow running query 
-- get the process id for the slow running query
sp_who2

-- get the plan handle based on the spid
-- you can run this without the where to see what's running
select *
from sys.dm_exec_requests
where session_id = 57;

-- get the execution plan for that query
-- note, 0,-1 returns all statements in the query / batch
select query_plan
from sys.dm_exec_text_query_plan(0x0200000002C6D42F7AAACE541C95D637FEB5A6185258B435, 0, - 1);

-- not everything seems to come back with an execution plan....
-- be careful as these start getting quite beefy now to run
-- now we really start getting into looking at the naughties queries....
-- this gets the query stats and pipes it through to the query plans and then 
-- pipes it through to get the sql query ran
select st.text
	,qs.*
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset)
cross apply sys.dm_exec_sql_text(qs.plan_handle) st

-- returns the query plans and average CPU time for the top five queries
-- top 5 as in time ran by times ran (the beef equation)
-- if you want to order by something else, do a * to see what you can get
select top 5 total_worker_time / execution_count as [Avg CPU Time]
	,Plan_handle
	,query_plan
	,st.text
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_query_plan(qs.plan_handle)
cross apply sys.dm_exec_sql_text(qs.plan_handle) st
order by total_worker_time / execution_count desc;
go


-- just remember, you can use SQL trace, even extended events can add a big overhead :-/
