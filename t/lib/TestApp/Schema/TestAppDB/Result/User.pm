use utf8;
package TestApp::Schema::TestAppDB::Result::User;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("users");

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

__PACKAGE__->set_primary_key("id");

__PACKAGE__->might_have(
  "token",
  "TestApp::Schema::TestAppDB::Result::Token",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "user_roles",
  "TestApp::Schema::TestAppDB::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->meta->make_immutable;
1;
