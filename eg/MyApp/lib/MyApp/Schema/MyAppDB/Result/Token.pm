use utf8;
package MyApp::Schema::MyAppDB::Result::Token;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::MyAppDB::Result::Token

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

=head1 TABLE: C<token>

=cut

__PACKAGE__->table("token");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 set_time

  data_type: 'datetime'
  is_nullable: 1

=head2 expires_in

  data_type: 'integer'
  is_nullable: 1

=head2 id_token

  data_type: 'text'
  is_nullable: 1

=head2 refresh_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 access_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 token_type

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
  "set_time",
  { data_type => "datetime", is_nullable => 1 },
  "expires_in",
  { data_type => "integer", is_nullable => 1 },
  "id_token",
  { data_type => "text", is_nullable => 1 },
  "refresh_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "access_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "token_type",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<MyApp::Schema::MyAppDB::Result::User>

=cut

__PACKAGE__->belongs_to(
  "id",
  "MyApp::Schema::MyAppDB::Result::User",
  { id => "id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-07-31 19:18:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d3m4oM4pogw3MrgJBqiwyQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
