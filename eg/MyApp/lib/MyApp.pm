package MyApp;

use lib '../../lib';

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;

#extends 'Catalyst';

#our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in myapp.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'MyApp',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    "Plugin::Session" => {
	storage => './tmp/session'
    },

    "Plugin::Authentication" => {
        default_realm => "oauth",
        realms => {
            oauth => {
                store => { class => '+Catalyst::Authentication::Store::Null' },
                credential => {
                   class => '+Yxes::Catalyst::Authentication::Credential::Google',
                   providers => {
                     'google.com' =>  {
                        client_id     => '',
                        client_secret => '',
                     }
                   }
                }
            }
       }
    },

);

# Start the application
__PACKAGE__->setup();


=head1 NAME

MyApp - Catalyst based application

=head1 SYNOPSIS

    script/myapp_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<MyApp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;