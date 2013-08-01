use utf8;
package TestApp::Schema::TestAppDB::Result::Role;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("roles");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
  "user_roles",
  "TestApp::Schema::TestAppDB::Result::UserRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->meta->make_immutable;
1;
