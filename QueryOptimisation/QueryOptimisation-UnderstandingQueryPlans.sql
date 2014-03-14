---- =============================================
---- Author:		Dom Finn
---- Description:	Understanding execution plans
---- References:
---- Professional SQL Server 2008 Internals and Troubleshooting

---- =============================================

select * from sys.dm_exec_query_optimizer_info
where counter in (
	'optimizations',
	'trivial plan',
	'search 0',
	'search 1',
	'search 2'	
) order by [counter]

/* 
Basic explanation of how queries get optimized

How queries get parsed and executed:
Parse -> Bind -> Optimize -> Execute

Pasing just makes sure you have valid sql, binding gets the objects you are trying to query
and makes sure they exist. It also checks all the types match. 

The Optimizer then finds an good execution plan, it might not be the best but it's a toss up between
time to find an execution plan that works best and one that is acceptably fast. 

1. is there already a valid cached plan? if yes, use that.
2. is it a trivial plan? if it is just run it
3. simplify the query tree as much as possible
4. is the plan reasonably cheap? if yes, run it
5. Start cost based optimisation....

- search 0 explores the basic rules and hash and joins
6. if the plan is < 0.2 then use it

- search 1 looks at alternative join orders, if it can parralelize use that.. (not sure about this)
7. if the plan is < 1 use it else try 

8. explore other ideas.... (need to research some more about this...) 

-- basically, the more queries you have moving up through the searches, the more problems you have

-- Looking at the exectuion plan... 

Join / Loops

3 types of joins

** Nested Join
_Good for small tables, make sure tgere is an index on the inner table on the join key_

Scans all the rows in the outer table and then scans the inner table. If the row on the inner matches the row on the outer
then it's included. 

This tends to work well if the inner table has few rows and you are joining to a larger table, a good example would be doing
from smalltable s left outer join largertable l on s.indexedkey = l.key

This join types runs terribly when the tables get large

** Merge
_Good for medium sized tables, make sure there are indexes on the join keys_

needs its tables (inputs) to be sorted, runs down both tables at the same time.... (need to know more about this...)

** Hash 
_Good for medium to large tables_

Works out which table is smallest and puts it in a has table, then runs over the large table matching keys in the hash.
This method scales and works well in parralel environments apparently... 

* Looking at Query plans	

When you look at the query plans, if you look at a 

*/

