package MyApp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

MyApp::Controller::Root - Root Controller for MyApp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut
sub auto : Private {
    my ($self, $c) = @_;

    return 1 if (!$c->req->path || grep $c->req->path =~ /$_/, qw|index logout favicon.ico|);

    if (!$c->user_exists) {
       # google verifies the uri that you are coming from via the redirect_uri call
       #        in our case we have /login setup as the call so you have to ensure 
       #        that they are coming from /login if we don't know who they are yet.
       if ($c->req->path ne 'login') {
	  $c->res->redirect('/login', '302');
	  return $c->detach();
       }
       $c->log->debug('***Root:auto User not found - authenticating');
       if ($c->authenticate({provider => 'google.com'})) {
	  return $c->detach('/login');
       }else{
	  $c->log->debug('***Root:auto User not Authenticated');
	  $c->res->body('Authentication Error: '. $c->stash->{login_error});
          return $c->detach();
       }
    }

return 1;
}
=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub login :Path('/login') {
    my ($self, $c) = @_;
    use Data::Dumper;
    $c->response->body('welcome: '. Dumper($c->user));
}

sub welcome :Path('/welcome') {
    my ($self, $c) = @_;
    $c->res->body('welcome: '. $c->user->{email});
}

sub logout :Path('/logout') {
    my ($self, $c) = @_;
    $c->logout;
    $c->res->body('you have been logged out');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
