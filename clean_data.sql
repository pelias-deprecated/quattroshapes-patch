-- Miscellaneous, ad-hoc queries for cleaning up bad Quattro data (like
-- trailing characters, weird name prefixes, etc).

-- Some admin2 records have qs_a2/qs_a2_alt names with trailing parentheticals
-- (like `(c)`, `(a)`); remove those characters.
update qs_adm2
set
	qs_a2 = regexp_replace(qs_a2, ' \(.+\)$', '', ''),
	qs_a2_alt = regexp_replace(qs_a2_alt, ' \(.+\)$', '', '');
