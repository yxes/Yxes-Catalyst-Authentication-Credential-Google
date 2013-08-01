package TestApp::Model::TestAppDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'TestApp::Schema::TestAppDB',
    
    connect_info => {
        dsn => 'dbi:SQLite:dbname=./t/db/testapp.db',
    }
);

1;
