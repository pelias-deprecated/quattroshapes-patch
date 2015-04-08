-- Miscellaneous, ad-hoc queries for cleaning up bad Quattro data (like
-- trailing characters, weird name prefixes, etc).

-- Some admin2 records have qs_a2/qs_a2_alt names with trailing parentheticals
-- (like `(c)`, `(a)`); remove those characters.
-- See pelias/quattroshapes-pipeline#8.
update qs_adm2
set
	qs_a2 = regexp_replace(qs_a2, ' \(.+\)$', '', ''),
	qs_a2_alt = regexp_replace(qs_a2_alt, ' \(.+\)$', '', '');

-- Some (predominantly UK) admin1 records have qs_a1 names with verbose and
-- unnecessary prefixes (like 'City of'). Remove them.
-- See pelias/quattroshapes-pipeline#13.
update qs_adm1
set qs_a1 = regexp_replace(qs_a1, '^((the )?city of|city and county of( the city of)?) ', '', 'i');

-- `qs_a2_alt` contains better data than `qs_a2`, in that it's more accurate
-- ("San Francisco County" instead of "San Francisco") and, in some cases, non
-- warped ("Bierunsko-ledzinski" instead of "BieruÅ\u0084sko-lÄ\u0099dziÅ\u0084ski")
-- when it's actually present. See https://github.com/pelias/admin-lookup/issues/13
-- for an extensive write-up.
update qs_adm2 set qs_a2 = qs_a2_alt where qs_a2_alt is not null;

-- Some `qs_a1`/`qs_a2` names consist of multiple names (typically in different
-- languages) concatenate on a `#`, like `Caerdydd#Cardiff`. Replace them with
-- the second name, which seems to be the most reliable in most cases.
update qs_adm1 set qs_a1 = split_part(qs_a1, '#', 2) where qs_a1 ~ '#';
update qs_adm2 set qs_a2 = split_part(qs_a2, '#', 2) where qs_a2 ~ '#';
