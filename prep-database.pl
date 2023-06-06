#!/usr/bin/perl

my $password =
    `python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)'`;

`sed -i 's/PASSWORD/'$password'/g' /mud/create_db.pl`;
`/mud/create_db.pl`;

print $password;
