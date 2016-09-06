/*
SPID - session id

status 
	- running ->	the session is currently running 
	- background -> just a job like checking for deadlocks etc...
	- rollback ->	something went wrong in a session and it's rolling back
	- pening ->		no worker threads are currently available
	- runnable ->	session is waiting in the runnable queue
	- suspended ->	session is requesting access to a resource that is currently not available. This can be a logical resource like a locked row or
					a physical resource like a memory data page. The query starts running again, once the resource becomes awailable.

CPU Time -	total milliseconds of cpu time used by the process. Background sessions will always be high because they run for a long time
			other sessions shouldn't have a high cputime, it might mean they are taking too long or hogging

DISK OP -	Ignore background tasks for now. This can mean lots of pages needed to be accessed to fulfill the request. This means the query is far reaching
			Watch out for this depending on the command in the session. You don't want massive locks... if you have big shared read locks on resources
			That something else wants to write to you will block them.....

*/

-- this is the	query
sp_who2

set transaction isolation level read uncommitted

-- if there's a session that is upsetting you, take a look at the command that is running....
SELECT session_id, TEXT
FROM sys.dm_exec_connections
CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST
where session_id = 85     

-- who has what sessions open, it there are any people with loads of sessions open, slap them
SELECT login_name ,COUNT(session_id) AS session_count 
FROM sys.dm_exec_sessions 
GROUP BY login_name;


select *
from sys.dm_exec_sessions with (nolock)
where session_id = 85

-- find the sessions query plan 
SELECT plan_handle FROM sys.dm_exec_requests WHERE session_id = 85

-- have a peek at the execution plan
SELECT query_plan FROM sys.dm_exec_query_plan (0x06000600078EDB1C40017BE8000000000000000000000000);

-- find sessions with long running cursors

SELECT creation_time ,cursor_id 
    ,name ,c.session_id ,login_name 
FROM sys.dm_exec_cursors(0) AS c 
JOIN sys.dm_exec_sessions AS s 
   ON c.session_id = s.session_id 
WHERE DATEDIFF(mi, c.creation_time, GETDATE()) > 5;

-- idle sessions that have open transactions
SELECT s.* 
FROM sys.dm_exec_sessions AS s
WHERE EXISTS 
    (
    SELECT * 
    FROM sys.dm_tran_session_transactions AS t
    WHERE t.session_id = s.session_id
    )
    AND NOT EXISTS 
    (
    SELECT * 
    FROM sys.dm_exec_requests AS r
    WHERE r.session_id = s.session_id
    );


-- get some real low level information about the connection 
SELECT 
    c.session_id, c.net_transport, c.encrypt_option, 
    c.auth_scheme, s.host_name, s.program_name, 
    s.client_interface_name, s.login_name, s.nt_domain, 
    s.nt_user_name, s.original_login_name, c.connect_time, 
    s.login_time 
FROM sys.dm_exec_connections AS c
JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
WHERE c.session_id = 75