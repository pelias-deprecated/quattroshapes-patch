-- Any SQL that needs to be run before after all other Quattroshapes processing.

-- Break up all centroids into separate `float`-type `lat`/`lon` attributes to
-- allow them to be exported to a shapefile without being converted to a string
-- (which they would be, since a shapefile can only contain only one geometry
-- and it already has polygons -- at export time, pgsql2shp would convert the
-- `Geometry`-type centroids to a `varchar`).
select ForEachQuattroTable('
alter table %1$s add column lat float, add column lon float;
update %1$s set lat = st_y(centroid), lon = st_x(centroid);
alter table %1$s drop column centroid;
');
