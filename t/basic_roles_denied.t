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
#                   ignore_fields_in_find => [qw/google_id link name locale family_name given_name
#                                                verified_email birthday picture gender/],
		},
                credential => {
                   class => '+Yxes::Catalyst::Authentication::Credential::Google',
                   auth_uri => URI->new('http://localhost/googleauth/auth'),
                   token_uri => URI::file->new_abs('./t/dat/token.json'),
                   api_uri => URI::file->new_abs('./t/dat/denied_user.json'),
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
  $mech->get('http://localhost/index');
  is($mech->status, 500, "Access is denied for this user");

# load another page
  $mech->get('/home');
  is($mech->status, 500, "Again - Access is denied for this user");

# logout
$mech->get_ok('/logout', 'log out');

$reset_database->();

done_testing();
