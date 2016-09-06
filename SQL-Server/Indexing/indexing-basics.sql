use tempdb

go

-- fundamentals with b-trees 

-- makes sure a row is almost 8000 bytes so a row will only get 1 page and a page can't store more than 1 row
create table indexing (
	id int identity(1,1),
	name char(4000),
	company char(4000),
	pay int
)

-- you should see the table is currently just a heap type, index_id of 0 is a heap
select	
	object_name(object_id) tablename,
	isnull(name, object_name(object_id)) indexname,
	index_id, 
	type_desc
from sys.indexes
where object_name(object_id) = 'indexing'

-- supresses the end rows affected
set nocount on

insert into indexing values 
('dom', 'north51', 10000)
, ('jim', 'north52', 12000)
, ('big billy', 'billys bean emporium', 1000)

select
	object_name(object_id) as tablename,
	index_type_desc, -- ie heap
	alloc_unit_type_desc, -- the row data fits in a page
	index_id,
	index_depth,
	index_level,
	record_count,
	page_count,
	fragment_count
from sys.dm_db_index_physical_stats(db_id(), object_id('indexing'), NULL, NULL , 'DETAILED')

insert into indexing values 
('erin', 'Big Mouths R Us', 20000)
, ('aoife', 'Boffers Paradise', 11000)

--insert into indexing values 
--('dummy row', '', 0)
--go 700

-- change from a heap, add a clustered index
create clustered index ci_indexingId on indexing(id)
go

-- run the status check now and see the change!
-- sql server uses stats heavily, average length is 4 which is narrow
-- notice the uniqueness, btw if you create a ci on a table with no unique values, sql server will add another 4 bytes onto the column to make it unique for indexing purposes
dbcc show_statistics('indexing', ci_indexingid)

-- remember this will only store the key, not the data it just has a pointer to the data using a row id / clustered index keys 
create nonclustered index nci_page on indexing(pay)

dbcc show_statistics('indexing', nci_page)

-- fill factor of > 50% can cause your read factor to degrade by 2 times as it has to read across more than 1 page, although there are arguments against this
-- for example, the full 8k of space will still be used so you have wasted memory and also there will be more pages to look through in the first place
-- :-/

