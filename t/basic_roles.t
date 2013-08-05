use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;

BEGIN {
  use TestApp;
  TestApp->config(
     "Plugin::Session" => {
         storage => './t/tmp/session'
     },
     "Plugin::Authentication" => {
         default_realm => "oauth",
         realms => {
            oauth => {
                store => {
		   class => 'DBIx::Class',
		   store_user_class => 'Yxes::Catalyst::Authentication::Store::Roles',
		   user_model => 'TestAppDB::User',
		},
                credential => {
                   class => '+Yxes::Catalyst::Authentication::Credential::Google',
                   auth_uri => URI->new('http://localhost/googleauth/auth'),
                   token_uri => URI::file->new_abs('./t/dat/token.json'),
                   api_uri => URI::file->new_abs('./t/dat/user.json'),
                   providers => {
                     'google.com' =>  {  # these are NOT real (of course)
                        client_id     => '835952862943.apps.googleusercontent.com',
                        client_secret => 'pP0DwxRjdTDHQ7wTsQ-ls_5k',
                     }
                   }
                }
            }
         }
     },
  );

  TestApp->setup(qw/Authentication Session Session::Store::FastMmap Session::State::Cookie/);
  TestApp->log->levels(qw/info warn error fatal/) unless TestApp->debug;
}

eval " use Test::WWW::Mechanize::Catalyst; 1 "
    or plan skip_all => 'test requires Test::WWW::Mechanize::Catalyst';

eval " use Catalyst::Plugin::Session::Store::FastMmap; 1 "
    or plan skip_all => 'test requires Catalyst::Plugin::Session::Store::FastMmap';

eval " use Test::MockObject; 1 "
    or plan skip_all => 'test requires Test::MockObject';

# reset the database
my $reset_database = sub {
  unlink 't/db/testapp.db';
  system('sqlite3 t/db/testapp.db < t/db/testapp.sql');
};

$reset_database->();

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

$reset_database->();

done_testing();
