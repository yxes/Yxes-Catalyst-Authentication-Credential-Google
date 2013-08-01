use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

#use Cwd 'abs_path';
use Catalyst::Test 'TestApp';
use Test::More tests => 3;

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
                store => { class => '+Catalyst::Authentication::Store::Null' },
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

my ($res, $c) = ctx_request('/index');

action_redirect('http://localhost/googleauth/auth?response_type=code&client_id=835952862943.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%2Findex&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email', 'fetching index page redirects to google');

   ($res, $c) = ctx_request($c->res->header('location'));

action_redirect('http://localhost/index?code=spinach', 'google redirects back to me');

   ($res, $c) = ctx_request($c->res->header('location'));

is($c->user->name, 'Test User', '[ignore the man behind the curtain] user populated');

   ($res) = request('/home');

# at this point we need to perform some error checking and $c->stash->{auth_error} should be populated
