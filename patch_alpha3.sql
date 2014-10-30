create or replace function mz_CreateCentroids(table_name text)
returns void as $$
	begin
		raise info 'Creating centroids for %s.', table_name;
		execute format(
			'alter table %1$s add centroid Geometry;
			update %1$s set centroid = st_centroid(geom);
			create index %1$s_centroid_index on %1$s using gist(centroid);',
			table_name
		);
	end
$$ language plpgsql;

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
			from adm0 parent
			join %1$s child
			on parent.geom && child.centroid and
				st_contains(parent.geom, child.centroid) and
				parent.iso3 != child.qs_adm0_a3;',
			table_name
		);
		execute(query_string);
	end
$$ language plpgsql;

create or replace function mz_PatchAlpha3Values(table_name text)
returns void as $$
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

do $$
	declare
		table_names text[] := array[
			'qs_adm0', 'qs_adm1', 'qs_adm2', 'qs_localadmin', 'qs_localities'
		];
		table_name varchar;
	begin
		alter table qs_neighborhoods add qs_adm0_a3 varchar(3);

		foreach table_name in array table_names
		loop
			perform mz_CreateCentroids(table_name);
			perform mz_FindContainerPolygons(table_name);
			perform mz_PatchAlpha3Values(table_name);
		end loop;
	end
$$;
