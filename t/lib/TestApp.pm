package TestApp;

use strict;
use warnings;

use URI::file;

use Catalyst qw/
    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;

__PACKAGE__->config(
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

__PACKAGE__->setup;

__PACKAGE__->log->levels( qw/info warn error fatal/ ) unless __PACKAGE__->debug;

1;
