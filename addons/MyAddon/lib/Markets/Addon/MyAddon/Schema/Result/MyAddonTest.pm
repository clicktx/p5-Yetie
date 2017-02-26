package Markets::Addon::MyAddon::Schema::Result::MyAddonTest;
use strict;
use warnings;

use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type => 'VARCHAR',
    size      => 50,
};

column data => {
    data_type => 'MEDIUMTEXT',
    is_nullable => 1,
};

1;