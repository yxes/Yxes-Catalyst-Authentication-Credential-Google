use strict;

use Test::More;
eval " use Test::WWW::Mechanize::Catalyst; 1 "
    or plan skip_all => 'test requires Test::WWW::Mechanize::Catalyst';

eval " use Catalyst::Plugin::Session::Store::FastMmap; 1 "
    or plan skip_all => 'test requires Catalyst::Plugin::Session::Store::FastMmap';

use lib 't/lib';

eval " use Test::MockObject; 1 "
    or plan skip_all => 'test requires Test::MockObject';

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'TestApp');
$mech->{catalyst_debug} = 0;

# load a page
$mech->get_ok('/index', 'full authentication');
$mech->content_like(qr/Test User/, 'user info imbedded in page');

# load another page
$mech->get_ok('/home', 'reusing the user info for the next page');

# logout
$mech->get_ok('/logout', 'log out');

# load home again
$mech->get_ok('/home', 'logging in again');

done_testing();
