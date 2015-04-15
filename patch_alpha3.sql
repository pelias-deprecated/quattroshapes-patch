-- Given a table name, create a table `${table_name}_container_polygons`, and
-- populate it with all of records in that table whose alpha3 values mismatches
-- their container adm0 polygon's alpha3 values. These will be patched by
-- `mz_PatchAlpha3Values()`, and will be used to update the original table
-- `table_name`.
create or replace function mz_FindContainerPolygons(table_name text)
returns void as $$
	declare
		query_string text;
	begin
		raise info 'Getting container polygons for %s.', table_name;
		query_string := format(
			'create table %1$s_container_polygons as
			select child.gid as child_gid,
				parent.iso3 as parent_a3
			from canonical_adm0 parent
			join %1$s child
			on parent.geom && child.centroid and
				st_contains(parent.geom, child.centroid) and
				(child.qs_adm0_a3 is null or
				parent.iso3 != child.qs_adm0_a3);',
			table_name
		);
		execute(query_string);
	end
$$ language plpgsql;

-- Given a table name, patch its alpha3 values using the mismatches in
-- `${table_name}_container_polygons`; then, delete the container-polygons
-- table, the `table_name` table's centroid index, and its `centroid` column.
create or replace function mz_PatchAlpha3Values(table_name text)
returns void as $$
	declare
		query_string text;
	begin
		raise info 'Patching alpha3 values in %s using container polygons.',
			table_name;
		query_string := format(
			'update %s as original
			set qs_adm0_a3 = intersection.parent_a3
			from %1$s_container_polygons as intersection
			where original.gid = intersection.child_gid;

			drop table %1$s_container_polygons;
			drop index %1$s_centroid_index;',
			table_name
		);
		execute(query_string);
	end
$$ language plpgsql;

alter table qs_neighborhoods add qs_adm0_a3 varchar(3);
select ForEachQuattroTable('
perform mz_FindContainerPolygons(%1$s);
perform mz_PatchAlpha3Values(%1$s);
');
