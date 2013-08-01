use utf8;
package TestApp::Schema::TestAppDB::Result::Token;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("token");

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

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
  "id",
  "TestApp::Schema::TestAppDB::Result::User",
  { id => "id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;
1;
