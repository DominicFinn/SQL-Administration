SELECT sum(pg_column_size(COL)), avg(pg_column_size(COL)), sum(pg_column_size(COL)) * 100.0 / pg_relation_size('public.NAMEOFTABLE')
  FROM public.NAMEOFTABLE;
