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
  2. create a Postgres database `quattroshapes` with the `postgis` extension
  3. import the dataset into `quattroshapes`
  4. process it using a variety of shell/SQL scripts
  5. export all processed Quattroshapes tables into shapefiles in `exported_quattroshapes/`

Go grab a coffee. This might take a while.
