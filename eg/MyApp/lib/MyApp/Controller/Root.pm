package MyApp::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

=head1 NAME

MyApp::Controller::Root - Root Controller for MyApp

=head1 DESCRIPTION

Used to test Yxes::Catalyst::Authentication::Credential::Google

=head1 METHODS

=head2 begin : Private

used to redirect the user to /login if they are not currently logged in

=cut
sub begin : Private {
    my ($self, $c) = @_;

    return 1 if (!$c->req->path || grep $c->req->path =~ /$_/, qw|index login logout favicon.ico|);

    if (!$c->user_exists) {
       $c->log->debug('***Root:auto User not found - authenticating');

       # google verifies the uri that you are coming from via the redirect_uri call
       #        in our case we have /login setup as the call so you have to ensure 
       #        that they are coming from /login if we don't know who they are yet.

    $c->res->redirect('/login', '302');
    $c->detach();
    }

}
=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->res->content_type('text/html');
    $c->res->body('you probably want this <a href="/welcome">link</a>');
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ($self, $c) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub login :Path('/login') {
    my ($self, $c) = @_;

    return $c->res->redirect('/welcome', '302')
		if ($c->authenticate({provider => 'google.com'}));

     $c->log->debug('***Root:auto User not Authenticated');
     $c->res->body('Authentication Error: '. $c->stash->{auth_error});
}

sub welcome :Path('/welcome') {
    my ($self, $c) = @_;

    $c->res->body('welcome: '.$c->user->email);
}

sub logout :Path('/logout') {
    my ($self, $c) = @_;
    $c->logout;
    $c->res->body('you have been logged out');
}

=head1 AUTHOR

Stephen D. Wells <yxes at cpan.org>

=head1 LICENSE

Copyright 2013. All Rights Reserved.  This library is free software.
You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
