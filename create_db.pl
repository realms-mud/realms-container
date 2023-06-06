#!/usr/bin/perl

my $mysql = "/usr/bin/mysql -u root -pPASSWORD";
`$mysql -e "create user 'RealmsLib'\@'localhost' identified by 'PASSWORD';"`;
`$mysql -e "create database RealmsLib;"`;
`$mysql -e "grant all privileges on RealmsLib.* to 'RealmsLib'\@'localhost';"`;
