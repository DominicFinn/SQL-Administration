-- Duplicate Indexes

;

with MyDuplicate
as (
	select Sch.[name] as SchemaName
		,Obj.[name] as TableName
		,Idx.[name] as IndexName
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 1) as Col1
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 2) as Col2
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 3) as Col3
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 4) as Col4
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 5) as Col5
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 6) as Col6
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 7) as Col7
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 8) as Col8
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 9) as Col9
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 10) as Col10
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 11) as Col11
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 12) as Col12
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 13) as Col13
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 14) as Col14
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 15) as Col15
		,INDEX_COL(Sch.[name] + '.' + Obj.[name], Idx.index_id, 16) as Col16
	from sys.indexes Idx
	inner join sys.objects Obj on Idx.[object_id] = Obj.[object_id]
	inner join sys.schemas Sch on Sch.[schema_id] = Obj.[schema_id]
	where index_id > 0
	)
select MD1.SchemaName
	,MD1.TableName
	,MD1.IndexName
	,MD2.IndexName as OverLappingIndex
	,MD1.Col1
	,MD1.Col2
	,MD1.Col3
	,MD1.Col4
	,MD1.Col5
	,MD1.Col6
	,MD1.Col7
	,MD1.Col8
	,MD1.Col9
	,MD1.Col10
	,MD1.Col11
	,MD1.Col12
	,MD1.Col13
	,MD1.Col14
	,MD1.Col15
	,MD1.Col16
from MyDuplicate MD1
inner join MyDuplicate MD2 on MD1.tablename = MD2.tablename
	and MD1.indexname <> MD2.indexname
	and MD1.Col1 = MD2.Col1
	and (
		MD1.Col2 is null
		or MD2.Col2 is null
		or MD1.Col2 = MD2.Col2
		)
	and (
		MD1.Col3 is null
		or MD2.Col3 is null
		or MD1.Col3 = MD2.Col3
		)
	and (
		MD1.Col4 is null
		or MD2.Col4 is null
		or MD1.Col4 = MD2.Col4
		)
	and (
		MD1.Col5 is null
		or MD2.Col5 is null
		or MD1.Col5 = MD2.Col5
		)
	and (
		MD1.Col6 is null
		or MD2.Col6 is null
		or MD1.Col6 = MD2.Col6
		)
	and (
		MD1.Col7 is null
		or MD2.Col7 is null
		or MD1.Col7 = MD2.Col7
		)
	and (
		MD1.Col8 is null
		or MD2.Col8 is null
		or MD1.Col8 = MD2.Col8
		)
	and (
		MD1.Col9 is null
		or MD2.Col9 is null
		or MD1.Col9 = MD2.Col9
		)
	and (
		MD1.Col10 is null
		or MD2.Col10 is null
		or MD1.Col10 = MD2.Col10
		)
	and (
		MD1.Col11 is null
		or MD2.Col11 is null
		or MD1.Col11 = MD2.Col11
		)
	and (
		MD1.Col12 is null
		or MD2.Col12 is null
		or MD1.Col12 = MD2.Col12
		)
	and (
		MD1.Col13 is null
		or MD2.Col13 is null
		or MD1.Col13 = MD2.Col13
		)
	and (
		MD1.Col14 is null
		or MD2.Col14 is null
		or MD1.Col14 = MD2.Col14
		)
	and (
		MD1.Col15 is null
		or MD2.Col15 is null
		or MD1.Col15 = MD2.Col15
		)
	and (
		MD1.Col16 is null
		or MD2.Col16 is null
		or MD1.Col16 = MD2.Col16
		)
order by MD1.SchemaName
	,MD1.TableName
	,MD1.IndexName

