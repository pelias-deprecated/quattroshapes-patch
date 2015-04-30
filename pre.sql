-- Any SQL that needs to be run before all other Quattroshapes processing.

-- A convenience function for executing a query against all Quattroshapes
-- tables. `query` will be passed to `format()`, which will receive only one
-- additional argument: a table name.
create or replace function ForEachQuattroTable(
	query text,
	table_names text[] default Array[
			'qs_adm0', 'qs_adm1', 'qs_adm2', 'qs_localadmin', 'qs_localities',
			'qs_neighborhoods'
		]
)
returns void as $$
	declare
		table_name varchar;
	begin
		foreach table_name in array table_names
		loop
			execute format(query, table_name);
		end loop;
	end
$$ language plpgsql;

-- Simplify all geometries to speed up processing, since some are way too
-- detailed. Also, build an index for them.
select ForEachQuattroTable('
update %1$s set geom = st_simplify(geom, 0.0001);
create index %1$s_geom_index on %1$s using gist(geom);'
);

-- Some geometries are null, and are thus useless for our purposes. Remove
-- them.
select ForEachQuattroTable('delete from %s where geom is null or st_isempty(geom);');

-- Compute the centroids of all geometries and build an index for them, since
-- they're necessary for some processing.
select ForEachQuattroTable('
select AddGeometryColumn(''%1$s'', ''centroid'', 4326, ''POINT'', 2);
update %1$s set centroid = st_centroid(geom);
create index %1$s_centroid_index on %1$s using gist(centroid);'
);
