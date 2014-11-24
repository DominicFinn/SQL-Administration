/*
create table someTableToLogChangesToSomeTable (
	audwhen datetime null,
	userId nvarchar(max),
	hostname nvarchar(max),
	programname nvarchar(max),
	loginname nvarchar(max),
	querytext nvarchar(max)
)
*/

-- =============================================
-- Author:		Dom Finn
-- Create date: 24/11/2014
-- Description:	Logging queries that are changing the table to work out what is deleting the information. Added this because something or someone was 
-- 				changing the data without us knowing and I didn't want to run a trace long term
-- =============================================
CREATE TRIGGER LogTableQueries
   ON  dbo.SomeTable
   for INSERT,DELETE,UPDATE
AS 
BEGIN

	SET NOCOUNT ON;

	insert into someTableToLogChangesToSomeTable (
		audwhen, userId, hostname, programname, loginname, querytext
	) 
	select getdate(), system_user, sp.hostname, sp.program_name, sp.loginame, st.text as query_text
	from sys.sysprocesses sp
	cross apply sys.dm_exec_sql_text(sp.sql_handle) as st  
	where sp.spid = @@spid
	
END
GO

