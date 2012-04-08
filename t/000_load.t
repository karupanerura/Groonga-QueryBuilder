#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'Groonga::QueryBuilder';
}

diag "Testing Groonga::QueryBuilder/$Groonga::QueryBuilder::VERSION";
