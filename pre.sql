-- Any SQL that needs to be run before all other Quattroshapes processing.

-- A convenience function for executing a query against all Quattroshapes
-- tables. `query` will be passed to `format()`, which will receive only one
-- additional argument: a table name.
create or replace function ForEachQuattroTable(
	query text,
	table_names text[] DEFAULT array[
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
			raise notice '%', format(query, table_name);
		end loop;
	end
$$ language plpgsql;
