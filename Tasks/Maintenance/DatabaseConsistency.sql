-- Fix Database

DBCC CHECKDB -- check the current database you are on....


ALTER DATABASE databasename SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

BEGIN TRANSACTION;

	DBCC CHECKDB ('databasename', REPAIR_ALLOW_DATA_LOSS); -- use this only on dev.... it will lose manky records...
	
Commit transaction

ALTER DATABASE databasename SET MULTI_USER;
