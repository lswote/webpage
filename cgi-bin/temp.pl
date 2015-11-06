#!/usr/bin/perl

use lib::Wire10;
use Net::MySQL;
use debug::utils;

my $dbh = wire_connect();
my $dbh = Net::MySQL->new(
    host     => 'localhost',
    user     => 'bhammond',
    password => 'bhammond',
    database => 'website',
    debug    => 1,
   );
