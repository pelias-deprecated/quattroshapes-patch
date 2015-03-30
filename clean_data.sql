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
set
	qs_a1 = regexp_replace(qs_a1, '^((the )?city of|city and county of) ', '', 'i');
