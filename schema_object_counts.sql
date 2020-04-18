-- note example below uses schema, "sample".  Just change globally to adapt to your schema count check.

select rt.tbls_regular as tbls_regular, ut.unlogged_tables as tbls_unlogged, pt.partitions as tbls_child, pn.parents as tbls_parents, rt.tbls_regular + ut.unlogged_tables + pt.partitions + pn.parents as tbls_total,
se.sequences as sequences, ix.indexes as indexes, vi.views as views, pv.pviews as pub_views, fn.functions as functions, ty.types as types, tf.trigfuncs, tr.triggers as triggers from  
(select count(*) as tbls_regular from pg_class c, pg_tables t, pg_namespace n where t.schemaname = 'sample' and t.tablename = c.relname and c.relkind = 'r' and n.oid = c.relnamespace and n.nspname = t.schemaname and c.relpersistence = 'p' and c.relispartition is false) rt,
(select count(distinct (t.schemaname, t.tablename)) as unlogged_tables from pg_tables t, pg_class c where t.schemaname = 'sample' and t.tablename = c.relname and c.relkind = 'r' and c.relpersistence = 'u' ) ut,
(SELECT count(*) as sequences FROM pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind = 'S' and n.nspname = 'sample') se,
(select count(*) as indexes from pg_indexes where schemaname = 'sample') ix,
(select count(*) as views from pg_views where schemaname = 'sample') vi,
(select count(*) as pviews from pg_views where schemaname = 'public') pv,
(select count(distinct p.relname) as parents FROM pg_inherits JOIN pg_class AS c ON (inhrelid=c.oid) JOIN pg_class as p ON (inhparent=p.oid) JOIN pg_namespace pn ON pn.oid = p.relnamespace JOIN pg_namespace cn ON cn.oid = c.relnamespace WHERE pn.nspname = 'sample' and c.relkind = 'r') pn,
(SELECT count(*) as partitions FROM pg_inherits JOIN pg_class AS c ON (inhrelid=c.oid) JOIN pg_class as p ON (inhparent=p.oid) JOIN pg_namespace pn ON pn.oid = p.relnamespace JOIN pg_namespace cn ON cn.oid = c.relnamespace WHERE pn.nspname = 'sample' and c.relkind = 'r') pt,
(SELECT count(*) as functions FROM pg_proc p INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid) WHERE ns.nspname = 'sample') fn,
(SELECT count(*) as types FROM pg_type t LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid) AND n.nspname = 'sample') ty,
(SELECT count(*) as trigfuncs FROM pg_catalog.pg_proc p LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang WHERE pg_catalog.pg_get_function_result(p.oid) = 'trigger' and n.nspname = 'sample') tf,
(SELECT count(distinct (trigger_schema, trigger_name, event_object_table, action_statement, action_orientation, action_timing)) as triggers  FROM information_schema.triggers WHERE trigger_schema = 'sample') tr;
