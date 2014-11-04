# quattroshapes-patch

A collection of all the scripts (mainly **shell**/**SQL**) that we use to patch the
[Quattroshapes](http://quattroshapes.com/) dataset before importing it into Pelias. To import, process, and export
Quattroshapes into revised shapefiles:

```bash
$ git submodule init && git submodule update
$ bash process.sh
```

#### processing steps

The script will:
  1. download all Quattroshapes shapefiles into `quattroshapes/`
  2. download a canonical admin-level 0 (countries) polygons dataset into `canonical_adm0/`
  3. create a Postgres database `quattroshapes` with the `postgis` extension
  4. import both datasets into `quattroshapes`
  5. process the Quattroshapes tables in `quattroshapes`:
   1. simplify Quattroshapes geometries by a factor of 0.0001
   2. patch their alpha 3 values using the `canonical_adm0/` dataset
  6. export all processed Quattroshapes tables into shapefiles in `exported_quattroshapes/`

Go grab a coffee. This might take a while.
