package MyApp;

use lib '../../lib';

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/
    ConfigLoader

    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie

    Authorization::Roles
/;

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
);

# Start the application
__PACKAGE__->setup();

=head1 NAME

MyApp - Catalyst based application for testing

=head1 SYNOPSIS

    script/myapp_server.pl

=head1 DESCRIPTION

Simple Catalyst application to test 

=over 4

=item * Yxes::Catalyst::Authentication::Credential::Google

=item * [optional] Yxes::Catalyst::Authentication::Credential::Google::Roles

=back

To run this just type 'script/myapp_server.pl' and point your browser
to 'http://localhost:3000/'

=head1 SEE ALSO

L<MyApp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Stephen D. Wells, C<< <yxes at cpan.org> >>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
