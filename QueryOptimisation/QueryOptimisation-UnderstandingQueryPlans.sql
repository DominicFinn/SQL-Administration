---- =============================================
---- Author:		Dom Finn
---- Description:	Understanding execution plans
---- References:
---- Professional SQL Server 2008 Internals and Troubleshooting

---- =============================================

select * from sys.dm_exec_query_optimizer_info
where counter in (
	'optimizations',
	'trivia plan',
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
*/