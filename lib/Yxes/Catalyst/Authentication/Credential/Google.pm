package Yxes::Catalyst::Authentication::Credential::Google;

use 5.006;
use Moose 2.0602;
use MooseX::Types::Moose 0.27 qw/Bool HashRef/;

use Catalyst::Exception;
use URI 1.60;
use LWP::UserAgent 6.02;
use HTTP::Request::Common 6.00 qw/POST/;
use JSON 2.53 qw/from_json/;

use namespace::autoclean;

=head1 NAME

Yxes::Catalyst::Authentication::Credential::Google - OAuth2 credential for Catalyst::Plugin::Authentication

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

In MyApp.pm

    use Catalyst qw/
        Authentication
        Session
        Session::Store::FastMmap
        Session::State::Cookie
    /;

In myapp.conf

    <Plugin::Authentication>
     default_realm oauth2
      <realms>
       <oauth2>
        <credential>
         class     +Yxes::Catalyst::Authentication::Credential::Google
         <providers>
          <google.com>
           client_id		  google_client_id
           client_secret          google_client_secret
          </google.com>
         </providers>
        </credential>
       </oauth>
      </realms>
    </Plugin::Authentication>

In controller code,

    sub oauth2 : Local {
        my ($self, $c) = @_;

        if( $c->authenticate( { provider => 'google.com' } ) ) {
            #do something with $c->user
        }
    }

=head1 DESCRIPTION

Allow Google authentication from your catalyst app.

=head1 USER METHODS

The default scope returns both user.profile and user.email information back to your application.

Here's a complete list of what's returned by default:

=over 4

=item * link

the Google+ link for this user

=item * name

Full Name

=item * locale

The default locale for this user.  ie  'en' for English

=item * family_name

the users 'last name'

=item * given_name

the users 'first name'

=item * id

Google assigns your user an id number

=item * verified_email

a Boolean returning 1 (true) or 0 (false)

=item * birthday

YYYY-MM-DD format

=item * picture

a URL pointing to the users image (as set by Google)

=item * gender

male or female (as far as I know)

=item * hd

is used if the domain is hosted by google as part of it's
Google Apps software.  Otherwise, it's blank.

ie: mydomain.com

=item * token

a hash of the token information retrieved from Google

to use these call $c->user->{token}->{expires_in} for instance

=over 4

=item * expires_in

(in seconds) default is 3600

=item * id_token

Google's ID Token string

=item * refresh_token

as the name strongly implies, allows you to refresh 
the token before it expires

=item * access_token

Used as part of your Authentication call to access Google APIs

=item * token_type

The authentication's username when calling an API.
Default is 'Bearer'

=back

=back

=head1 SUBROUTINES/METHODS

The first group of settings (if you want to use them) must be set 
in the configuration file.

Here's a list of your configuration options:

=over 4

 <Plugin::Authentication>
  ...
  <google.com>
    # mandatory
    client_id	GOOGLE CLIENT ID
    client_secre GOOGLE CLIENT SECRET
  
    # optional
    verbose     1 | 0
    scope	the goole scope URL(s)
    auth_uri    [URI object] the URL for Google's auth2 location
    token_uri   [URI object] the URL for Google's token location
    api_uri     [URI object] the URL for Google's api location

  </google.com>
 </Plugin::Authentication>

=back

to set URI objects in your configuration file use this format:

=over 4

auth_uri   URI->new('http://www.example.com/path/example');

=back

The following is breakdown of each call

=head2 verbose

Can be set to 1 (true) to display debugging information

ie: verbose 1

=cut
has verbose => (is => 'ro', isa => Bool, default => 0);

=head2 providers

caches the list of the providers

ie: providers is mandatory for the Plugin::Authentication module,
so this is just a placeholder to cache that information.

[SEE SYNOPSIS]

=cut
has providers => (is => 'ro', isa => HashRef, required => 1);

=head2 scope

the google scope URLs

Join scopes together with a plus '+' symbol.  Since they
are never used as urls in the program we don't require
(or even allow) them to be URI objects.

default: https://www.googleapis.com/auth/userinfo.profile +
	 https://www.googleapis.com/auth/userinfo.email

NOTE: this is NOT a URI object so just put your scope in your
config file as a string.

ie: scope https://www.googleapis.com/auth/tasks.readonly

You can find other scopes here:

L<[Google Developer Playground]|https://developers.google.com/oauthplayground/>

=cut
has scope => (is => 'ro', isa => 'Str', required => 1,
			default => sub { 'https://www.googleapis.com/auth/userinfo.email '.
					 'https://www.googleapis.com/auth/userinfo.profile' });
=head2 auth_uri

the google authentication uri

default: URI->new('https://accounts.google.com/o/oauth2/auth')

=cut
has auth_uri => (is => 'ro', isa => 'URI', required => 1,
			default => sub { URI->new('https://accounts.google.com/o/oauth2/auth') });
=head2 token_uri

the google token uri

default: URI->new('https://accounts.google.com/o/oauth2/token')

=cut
has token_uri => (is => 'ro', isa => 'URI', required => 1,
			default => sub { URI->new('https://accounts.google.com/o/oauth2/token') });

=head2 api_uri

the google api uri

default: URI->new('https://www.googleapis.com/oauth2/v2/userinfo')

=cut
has api_uri => (is => 'ro', isa => 'URI', required => 1,
			default => sub { URI->new('https://www.googleapis.com/oauth2/v2/userinfo') });

=head2 BUILDARGS

[INTERNAL METHOD]

Snatches up the configruation information and returns it to Moose in a canonical way

=cut
sub BUILDARGS {
    my ($self, $config, $c, $realm) = @_;

    return $config;
}

=head2 authenticate

 use Data::Dumper;

 if ($c->authenticate({provider => 'google.com'})) {
    $c->res->body('We are in! - '. Dumper($c->user));
 }else{
    $c->logout if ($c->user);
    $c->res->body('No Juice: ' . $c->stash->{auth_error});
 }

=cut
sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    Catalyst::Exception->throw( "Provider is not defined." )
        unless defined $auth_info->{provider} || defined $self->providers->{ $auth_info->{provider} };

    my $provider = $self->providers->{ $auth_info->{provider} };

    $c->log->debug( "authenticate() called from " . $c->request->uri ) if $self->verbose;

    # look for an error from google
    if ($c->req->param('error')) {
       $c->log->debug('authenticate() Google Error Message: ' . $c->req->param('error'));
       $c->stash->{auth_error} = 'Google Responded with: '. $c->req->param('error');
       $c->logout;
       return;
    }

    if (my $code = $c->req->param('code')) {  # we have a response from google through the browser
       my $ua = LWP::UserAgent->new();

       my $user_data; # a combination of token and user data
       {;
	  # first we need to get at the token data
	  my $req_uri = $c->request->uri->clone;
	     $req_uri->query(undef);
	  my $attribs = [
			code => $code,
			redirect_uri => $req_uri,
			client_id => $provider->{client_id},
			scope => '',
			client_secret => $provider->{client_secret},
			grant_type => 'authorization_code'
          ];

          my $req = $self->_build_req($c, $self->token_uri, $attribs, 'POST');

	  my $res = $ua->request($req);

          if ($res->is_success()) {
	     my $token = from_json($res->content());

	     # using the token data we can extract the user data
	     my $req = $self->_build_req($c, $self->api_uri->clone);
	        $req->authorization(join ' ', ($token->{token_type}, $token->{access_token}));

	     my $res = $ua->request($req);
	     if ($res->is_success()) {
		$user_data = from_json($res->content());
		$user_data->{token} = $token;
	     }
          }else{
	     my $error = from_json($res->content())->{error};
	     $c->log->debug('Authentication Error: Google OAuth->token returned: '. $error);
	     Catalyst::Exception->throw('Authentication Error: Google OAuth2 token failed: '. $error);
	  return;
	  }
					  
       }

       my $user = +{ %$user_data };
       my $user_obj = $realm->find_user($user, $c);
      return $user_obj if ref $user_obj; # success!

        # failed to identify
	$c->log->debug('Verification of Google OAuth2 failed') if $self->verbose;
        Catalyst::Exception->throw("Authentication Error: Google OAuth2 failed");
      return;
    }

    my $auth_uri = $self->auth_uri->clone;
       $auth_uri->query_form(
		response_type => 'code',
		client_id     => $provider->{client_id},
		redirect_uri  => $c->request->uri,
		scope	      => $self->scope
       );

$c->res->redirect($auth_uri->as_string);
$c->detach;
}

# doing it this way provides a 'hook' for testing
sub _build_req {
    my ($self, $c, $uri, $attribs, $method)  = @_;
    $method ||= 'GET';

    my $req;
    if ($uri->scheme eq 'file') { # this overrides the method 
       $req = HTTP::Request->new(GET => $uri->as_string);
    }elsif (uc($method) eq 'GET') {
       $req = HTTP::Request->new(GET => $uri->as_string, %$attribs);
    }elsif (uc($method) eq 'POST') {
       $req = POST $uri, [@$attribs];
    }else{
       Catalyst::Exception->throw('URI Error in authenticate(): '.
	"Invalid Method: $method - We can only handle methods GET or POST");
    }

return $req; # you have to handle errors on your own
}

=head1 SAMPLE CONFIGURATION FILE

 <Plugin::Authentication>
  default_realm 	oauth2
  <realms>
    <oauth2>
      <store>
	class			Catalyst::Authentication::Store::Null
      </store>
      <credential>
        class			+Yxes::Catalyst::Authentication::Credential::Google
	<providers>
	  <google.com>
	    client_id		43522351S345.apps.googleusercontent.com
	    client_secret	qKK85h4H_3mJXQP9n5qzO
	  </google.com>
        </providers>
      </credential>
    </oauth2>
   </realms>
 </Plugin::Authentication>

=head1 AUTHOR

Stephen D. Wells, C<< <yxes at cpan.org> >>

=head1 SUPPORT

The following (albetit very limited) support is available:

=head2 DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc Yxes::Catalyst::Authentication::Credential::Google

=head2 GITHUB

This package is hosted on github.com

L<[Yxes::Catalyst::Authentication::Credential::Google]|https://github.com/yxes/Yxes-Catalyst-Authentication-Credential-Google>

=head2 EXAMPLE APPLICATION

Bundled with this, is a Catalyst example that you are encouraged to play
with.

It can be found in the ./eg/MyApp directory.  Read the README file in there
to review how to retrieve your 'Client ID' and 'Client secret' values from
Google, then add that to the configuration to test the application before
you install it.

=head1 ACKNOWLEDGEMENTS

The majority of this code was lifted from the CPAN module:
Catalyst::Authentication::Credential::OAuth and 
those authors deserve the credit for this module:

Cosmin Budrica E<lt>cosmin@sinapticode.comE<gt>

Bogdan Lucaciu E<lt>bogdan@sinapticode.comE<gt>

Pavel Bashinsky E<lt>pavel.bashinsky at gmail.comE<gt>

With contributions from:

  Tomas Doran E<lt>bobtfish@bobtfish.netE</gt>

Further to this, Bashinsky needs to be credited with changes that
introduce code to enable the above module to use OAuth with Google.

L<[see post]|http://grokbase.com/t/sc/catalyst-commits/1162ezwhnw/r14028-in-catalyst-authentication-credential-oauth-trunk-lib-catalyst-authentication-credential>

His code was introduced as a patch but I was unable to get the patch to work so I went line by line and
made the appropriate changes in the code - debugged it and viola - it seems to work.

...and then...

The upgrade to OAuth2 was reformatted using Net::Google::Drive::Simple, specficially 
Mike Schilli's E<lt>cpan@perlmeister.com</gt>
L<[google-drive-init]|https://metacpan.org/source/MSCHILLI/Net-Google-Drive-Simple-0.05/eg/google-drive-init>
script in the 'eg' directory.  He has a very cool technique for storing the keys to handle long
transfers without being logged out of Google - check it out!

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Stephen D. Wells.  All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Yxes::Catalyst::Authentication::Credential::Google
