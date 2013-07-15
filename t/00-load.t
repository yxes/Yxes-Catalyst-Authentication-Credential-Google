#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Yxes::Catalyst::Authentication::Credential::Google' ) || print "Bail out!\n";
}

diag( "Testing Yxes::Catalyst::Authentication::Credential::Google $Yxes::Catalyst::Authentication::Credential::Google::VERSION, Perl $], $^X" );
