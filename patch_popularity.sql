-- The `qs_neighborhoods` layer has several attributes that indicate
-- popularity, like `photo_sum` and `photo_max`. This script will propagate
-- those values to all of the other layers (`qs_adm0`, `qs_adm1`, etc.)

-- For each record in `table_name`, find all polygons in `qs_neighborhoods`
-- whose centroids lie inside it, sum up their popularity-related attributes,
-- and add them to that record.
--
-- Note that it's unclear what some of these values (like `local_sum` and
-- `local_max`) actually are, but may as well add them.
create or replace function PatchPopularity(table_name text)
returns void as $$
	declare
		query_string text;
	begin
		raise info 'Patching popularity in %s.', table_name;
		query_string := '
			create table %1$s_neighborhoods
			as select
				%1$s.gid,
				sum(neighbor.quad_count) as quad_count,
				sum(neighbor.photo_sum) as photo_sum,
				sum(neighbor.photo_max) as photo_max,
				sum(neighbor.localhoods) as localhoods,
				sum(neighbor.local_sum) as local_sum,
				sum(neighbor.local_max) as local_max
			from qs_neighborhoods neighbor
			join %1$s
			on st_contains(%1$s.geom, neighbor.centroid)
			group by %1$s.gid;

			alter table %1$s
			add column quad_count numeric,
			add column photo_sum numeric,
			add column photo_max numeric,
			add column localhoods numeric,
			add column local_sum numeric,
			add column local_max numeric,
			add column popularity numeric;

			update %1$s
			set
				quad_count = neighbor.quad_count,
				photo_sum = neighbor.photo_sum,
				photo_max = neighbor.photo_max,
				localhoods = neighbor.localhoods,
				local_sum = neighbor.local_sum,
				local_max = neighbor.local_max,
				popularity = neighbor.photo_sum
			from %1$s_neighborhoods neighbor
			where neighbor.gid = %1$s.gid;

			drop table %1$s_neighborhoods';

		execute format(query_string, table_name);
	end
$$ language plpgsql;

select ForEachQuattroTable(
	'select PatchPopularity(''%s'');',
	array['qs_adm0', 'qs_adm1', 'qs_adm2', 'qs_localadmin', 'qs_localities']
);
