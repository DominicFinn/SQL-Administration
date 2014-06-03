SELECT name, is_auto_update_stats_on, is_auto_update_stats_async_on 
FROM sys.databases

-- Database is currently this... 
--ALTER DATABASE X 
--SET AUTO_UPDATE_STATISTICS ON

-- The tables are too big for the above. It would never finish. Better with -> 

ALTER DATABASE X 
SET AUTO_UPDATE_STATISTICS_ASYNC ON

-- Risks - There's a possibility of a suboptimal query plan because it could be based on out of date statistics
-- Mitigation - We don't have large scale table changes so the above doesn't really matter.
-- Benefits - We can apply indexes without killing the system.. 

-- If we don't like it, we can always add it back after we have applied the indexes. 

