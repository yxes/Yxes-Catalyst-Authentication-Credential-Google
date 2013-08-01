use utf8;
package MyApp::Schema::MyAppDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::MyAppDB::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 link

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 locale

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 family_name

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 given_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 google_id

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 verified_email

  data_type: 'tinyint'
  is_nullable: 1

=head2 birthday

  data_type: 'date'
  is_nullable: 1

=head2 picture

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 gender

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "link",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "locale",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "family_name",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "given_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "google_id",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "verified_email",
  { data_type => "tinyint", is_nullable => 1 },
  "birthday",
  { data_type => "date", is_nullable => 1 },
  "picture",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "gender",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 token

Type: might_have

Related object: L<MyApp::Schema::MyAppDB::Result::Token>

=cut

__PACKAGE__->might_have(
  "token",
  "MyApp::Schema::MyAppDB::Result::Token",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<MyApp::Schema::MyAppDB::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "MyApp::Schema::MyAppDB::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-07-30 08:54:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i2+CuyGjw4m8u9d6DwaMrw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
