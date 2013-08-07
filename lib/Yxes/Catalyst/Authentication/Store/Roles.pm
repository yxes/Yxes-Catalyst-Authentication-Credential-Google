package Yxes::Catalyst::Authentication::Store::Roles;

use Moose;
use namespace::autoclean;
extends 'Catalyst::Authentication::Store::DBIx::Class::User';

override 'load' => sub {
    my ($self, $authinfo, $c) = @_;

    # if we receive 'email' - it's coming from Google
    #   otherwise it's coming from the database
    if (exists $authinfo->{email}) {
       # switch the 'id' to 'google_id' - we'd like to avoid any db entanglements...
         $authinfo->{google_id} = $authinfo->{id};
         delete $$authinfo{id};

       # coming from our host
         my $host = lc($c->req->uri->host);
	    $host =~ s/www\.//;
       my $ref;
       if ($authinfo->{email} =~ /\@$host$/) { # if they are part of our host we automatically add them
	  # you can not use find_or_create here because of the 'active' switch
          $ref = $self->resultset->find({email => $authinfo->{email}}) ||
	         $self->resultset->create({email => $authinfo->{email}, active => 1});
	  
	  $ref = undef unless $ref->active; # you better have active in your db default to '1'
       }else{ 
	  $ref = $self->resultset->find({email => $authinfo->{email}, active => 1}); # otherwise we look them up
       }

       if ($ref) {
	  for my $key (keys %$authinfo) {
	      next if ($key eq 'email');
	      if ($key eq 'token') { # add in our tokens
		 my $tokeobj = $ref->token || $ref->create_related('token', { id => $ref->id });
		 for (keys %{$authinfo->{$key}}) {
		     next unless $tokeobj->has_column($_);
		     $tokeobj->$_($authinfo->{$key}->{$_});
		 }
	         $tokeobj->update();
	       next;
	      }

	      next unless $ref->has_column($key);

	      if ($key eq 'verified_email') { # VERIFY EMAIL is returning BOOLEAN
		 $ref->$key($authinfo->{$key} eq 'true' ? 1 : 0); # we convert it to 1 or 0
	      }else{
	         $ref->$key($authinfo->{$key});
	      }
	  }

	  $ref->update();
	  $authinfo->{dbix_class} = { email => $authinfo->{email}, result => $ref };
       }else{
	  $authinfo->{dbix_class} = {email => $authinfo->{email}};
	  $c->stash('auth_error' => $authinfo->{email} . ' is not registered with us');
	  $c->log->debug('NO REF FOUND!');
       }
    }

super() # allow Catalyst::Authentication::Store::DBIx::Class::User to do it's sweet thang!
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
__END__

=head1 NAME

Yxes::Catalyst::Authentication::Store::Roles - establish roles for
Yxes::Catalyst::Authentication::Credential::Google

=head1 SYNOPSIS

Currently this library is used with 
Yxes::Catalyst::Authentication::Credential::Google
and has a couple minor features attributed to that.

=over 4

=item 1. Automated Database Updates

It automatically updates your database with the information delivered from
Google.

=item 2. Automated Host Inclusion

If the email address the user uses is the same as your host

ie: www.mydomain.com --> user@mydomain.com

that user is automatically entered into the database and setup.

=item 3. Placeholder

There is no third feature, but things seem nicer when they come in threes

=back

The rest is internal - not used directly, please see
L<Catalyst::Authentication::Store::DBIx::Class::User> for details on 
how to use this module

...or even better, it's parent...

L<Catalyst::Authentication::Store::DBIx::Class> 

=head1 DESCRIPTION

After inheriting all the features of L<Catalyst::Authentication::Store::DBIx::Class::User>
we override just the load method.  This lets us fill in the current database with information
from Google or just deliver directly from the database, depending on where the call comes 
from.

=head1 SUBROUTINES / METHODS

=head2 load ($authinfo, $c)

Retrieves a user from storage using the information provided in $authinfo.

If the user is found in the database, we update the database with Google's latest
information on that user.

If the user is not found in our database then we check to see if the user's 
email address is the same as our host.

=over 4

  ie:  me@myhost.com matches www.myhost.com
       you@yourhost.com does not match www.myhost.com

=back

If the user's email address host matches our host, they are automatically added to
the database and given limited levels of access.  This allows sites that utilize
Google Apps (to manage their email) the ability to setup and use the site
automatically.  In contrast, other google-addressed email accounts 
(ie. me@gmail.com) can be added to the database manually and assigned 
roles to allow access.  Thus providing a 2-step authentication system:

=over 4

=item 1.

Google Authenticates the Email Address

=item 2. 

Only if that Email Address is found in our Local Database are they 
allowed in.

=back

If the user is NOT found in the database AND their email address is NOT coming
from our domain - they are rejected.  An error is placed into stash:

 auth_error => $email is not registered with us

Otherwise, it updates Google's information into our local database 
[see L</"DB TABLE INFO"> below] and assigns C<$c-E<gt>user> with their information.

Of course, there are times when you let an employee go and no longer wish
them to have access to your system.  Simply flip the active switch to '0'
in the users table and they can't get in anymore.  Keep in mind that without
this, if your employee has access to the Google account they'll get in, even
if you delete their information from your local database.  [You should manage
their Google account if they are your employee anyway]

=head1 SAMPLE CONFIGURATION FILE

 <Plugin::Authentication>
  default_realm 	oauth2
  <realms>
    <oauth2>
      <store>
	class			DBIx::Class
	store_user_class	Yxes::Catalyst::Authentication::Store::Roles
        user_model		MyAppDB::User

	# optional
	role_relation   	roles
        role_field      	role
      </store>
      <credential>
        class		+Yxes::Catalyst::Authentication::Credential::Google
	<providers>
	  <google.com>
	    client_id		435223515345.apps.googleusercontent.com
	    client_secret	qKK85h4H_3mJXQP9n5qWO
	  </google.com>
        </providers>
      </credential>
    </oauth2>
   </realms>
 </Plugin::Authentication>

=head1 DB TABLE INFO

The program expects the following tables

=head2 SQLite version

 PRAGMA foreign_keys = ON;

 CREATE TABLE users (
  id		 INTEGER PRIMARY KEY,
  email		 VARCHAR(255) NOT NULL,
  link		 VARCHAR(255),
  name		 VARCHAR(30),
  locale	 VARCHAR(10),
  family_name    VARCHAR(60),
  given_name	 VARCHAR(30),
  google_id	 VARCHAR(50),
  verified_email TINYINT,
  birthday	 DATE,
  hd		 VARCHAR(250),
  picture	 VARCHAR(255),
  gender	 VARCHAR(30),
  active	 TINYINT NOT NULL DEFAULT '1'
 );

 CREATE TABLE user_roles (
  user_id	INTEGER,
  role_id	INTEGER,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE
 );

 CREATE TABLE roles (
  id		INTEGER PRIMARY KEY,
  role		varchar(50)
 );

 CREATE TABLE token (
  id		INTEGER PRIMARY KEY,
  set_time	DATETIME,
  user_id	INTEGER NOT NULL UNIQUE,
  expires_in	INTEGER,
  id_token	TEXT,
  refresh_token VARCHAR(255),
  access_token  VARCHAR(255),
  token_type	VARCHAR(30),
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
 );

 CREATE TRIGGER add_role AFTER INSERT ON users BEGIN INSERT INTO user_roles VALUES(NEW.id,'1'); END;

 INSERT INTO roles(role) VALUES('user');

=head1 BUGS AND LIMITATIONS

If it was more configurable it'd be useful in more applications...

=head1 AUTHOR

Stephen D. Wells <yxes at cpan.org>

=head1 THANKS

the prodigious...

Tomas Doran (tOm) <bobtfish@bobtfish.net>

...for leaving an indelible mark on my understanding....

=for comment
he stamped on my foot

=head1 LICENSE

Copyright (c) 2013 Stephen D. Wells. All Rights Reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
