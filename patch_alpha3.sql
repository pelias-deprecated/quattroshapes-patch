-- Given a table name, simplify its geometry column by a factor of 0.0001.
create or replace function mz_SimplifyGeometry(table_name text)
returns void as $$
	begin
		raise info 'Simplifying geometries in %s.', table_name;
		execute format(
			'update %s set geom = st_simplify(geom, 0.0001);',
			table_name
		);
	end
$$ language plpgsql;

-- Given a table name, add a column `centroid (Geometry)` to it, populate it
-- with the centroid of each row's `geom`, and create a `gist` index on it.
create or replace function mz_CreateCentroids(table_name text)
returns void as $$
	begin
		raise info 'Creating centroids for %s.', table_name;
		perform AddGeometryColumn(table_name, 'centroid', 4326, 'POINT', 2);
		execute format(
			'update %1$s set centroid = st_centroid(geom);
			create index %1$s_centroid_index on %1$s using gist(centroid);',
			table_name
		);
	end
$$ language plpgsql;

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

-- Patch Alpha3 values in all quattroshapes tables using the `canonical_adm0`
-- table.
do $$
	declare
		table_names text[] := array[
			'qs_adm0', 'qs_adm1', 'qs_adm2', 'qs_localadmin', 'qs_localities',
			'qs_neighborhoods'
		];
		table_name varchar;
	begin
		alter table qs_neighborhoods add qs_adm0_a3 varchar(3);

		foreach table_name in array table_names
		loop
			perform mz_SimplifyGeometry(table_name);
			perform mz_CreateCentroids(table_name);
			perform mz_FindContainerPolygons(table_name);
			perform mz_PatchAlpha3Values(table_name);
		end loop;
	end
$$;
