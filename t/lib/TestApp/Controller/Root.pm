package TestApp::Controller::Root;

use strict;
use warnings;

use parent 'Catalyst::Controller';

sub auto : Private {
    my ($self, $c) = @_;

    return 1 if ($c->req->path =~ /logout/	||
		 $c->req->path =~ /googleauth/);

    if (!$c->user_exists) {
       $c->log->debug('***Root:auto User not found - authenticating');
       if ($c->authenticate({provider => 'google.com'})) {
           $c->res->redirect($c->uri_for('/index'));
           $c->detach();
       }else{
          # this doesn't work. I just get a 500 error - I don't bother
	  #   testing for it... instead just seeing if we got the
	  #   server error
	  $c->log->debug('***Root:auto User not Authenticated');
          $c->detach('login_error');
       }
    }

return 1;
}

sub googleauth : Path('/googleauth') {
    my ($self, $c) = @_;

    $c->res->redirect($c->req->param('redirect_uri') .'?code=spinach');
}

sub index : Path('/index') {
    my ($self, $c) = @_;

    $c->res->body( 'welcome '.$c->user->name );
}

sub home: Path('/home') {
    my ($self, $c) = @_;

    $c->res->body('welcome home');
}

sub login_error : Private {
    my ($self, $c) = @_;

    $c->response->body('the following error occured: ', $c->stash->{auth_error});
}

sub logout : Path('/logout') {
    my ($self, $c) = @_;

    $c->logout;

    $c->res->body('You have been logged out');
}

1;
