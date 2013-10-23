-- accumulated wait stats
select	wait_type, 
		waiting_tasks_count, 
		wait_time_ms, max_wait_time_ms, 
		signal_wait_time_ms
from sys.dm_os_wait_stats
order by wait_time_ms desc
go

-- Looks for active io issues, are they perforamnce issues at this point in time?
select	session_id,
		wait_duration_ms,
		wait_type,
		resource_description
from sys.dm_os_waiting_tasks
where	wait_type like N'PAGEIOLATCH%' or
		wait_type in (
			N'IO_COMPLETION', N'WRITELOG', N'ASYNC_IO_COMPLETION'
		)

-- which databases are involved in the IO problems, you can see the big ones, which ones are doing the most io
-- order by io_stall to see the latency....
select	database_id,
		db_name(database_id) as databasename,
		file_id,
		num_of_reads,
		num_of_bytes_read,
		io_stall_read_ms,
		num_of_writes,
		num_of_bytes_written,
		io_stall_write_ms,
		io_stall,
		size_on_disk_bytes
from sys.dm_io_virtual_file_stats(null, null)
order by io_stall desc;
go

-- top queries that are using the most io when they are called
select	q.query_hash,
		substring(t.[text], (q.statement_start_offset / 2) + 1,
			(((case q.statement_end_offset
				when -1 then datalength(t.[text])
				else q.statement_end_offset
			end) - q.statement_start_offset) / 2) + 1),
		sum(q.total_physical_reads) as total_physical_reads
from sys.dm_exec_query_stats as q
cross apply sys.dm_exec_sql_text(q.sql_handle) as t
group by q.query_hash,
	substring(t.[text], (q.statement_start_offset / 2) + 1,
		(((case q.statement_end_offset
			when -1 then datalength(t.[text])
			else q.statement_end_offset
		end) - q.statement_start_offset) / 2) + 1)
order by sum(q.[total_physical_reads]) desc			

-- copy the hash from the above, the hash is the hash of the grouped query plan that is cached, the query will return the plans that are cached
select	p.query_plan
from	sys.dm_exec_query_stats as q
cross apply sys.dm_exec_query_plan(q.plan_handle) as p
where	q.query_hash = 0x4B128E34AC0ADAE3

--Execution plans
-- Missing indexes aren't that useful on your own but they hint at possible missing indexes...
-- Indexes should be seek not scanned

-- top 5 queries by average CPU_Time
SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time/execution_count DESC;

