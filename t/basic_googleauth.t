use strict;
use warnings;

use lib 't/lib';

use Cwd 'abs_path';
use Catalyst::Test 'TestApp';
use Test::More tests => 3;

my ($res, $c) = ctx_request('/index');

action_redirect('http://localhost/googleauth/auth?response_type=code&client_id=835952862943.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%2Findex&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email', 'fetching index page redirects to google');

   ($res, $c) = ctx_request($c->res->header('location'));

action_redirect('http://localhost/index?code=spinach', 'google redirects back to me');

   ($res, $c) = ctx_request($c->res->header('location'));

is($c->user->name, 'Test User', '[ignore the man behind the curtain] user populated');

   ($res) = request('/home');

# at this point we need to perform some error checking and $c->stash->{login_error} should be populated
