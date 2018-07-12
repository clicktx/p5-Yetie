package Yetie::Schema::Result::Address;
use Mojo::Base 'Yetie::Schema::Base::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column hash => {
    data_type   => 'VARCHAR',
    size        => 64,
    is_nullable => 0,
};

column country_code => {
    data_type   => 'VARCHAR',
    size        => 2,
    is_nullable => 0,
    comments    => 'ISO 3166-1 alpha-2',
};

column line1 => {
    data_type   => 'VARCHAR',
    size        => 128,
    is_nullable => 0,
};

column line2 => {
    data_type   => 'VARCHAR',
    size        => 128,
    is_nullable => 0,
};

column level1 => {
    data_type   => 'VARCHAR',
    size        => 32,
    is_nullable => 0,
    comments    => 'State/Province/Province/Region',
};

column level2 => {
    data_type   => 'VARCHAR',
    size        => 32,
    is_nullable => 0,
    comments    => 'City/Town',
};

column postal_code => {
    data_type   => 'VARCHAR',
    size        => 16,
    is_nullable => 0,
    comments    => 'Post Code/Zip Code',
};

column organization => {
    data_type   => 'VARCHAR',
    size        => 32,
    is_nullable => 0,
};

column personal_name => {
    data_type   => 'VARCHAR',
    size        => 32,
    is_nullable => 0,
};

# Index
unique_constraint ui_hash => [qw/hash/];

# Relation
has_many
  customer_addresses => 'Yetie::Schema::Result::Customer::Address',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

has_many
  phones => 'Yetie::Schema::Result::Address::Phone',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

has_many
  sales => 'Yetie::Schema::Result::Sales',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

has_many
  orders => 'Yetie::Schema::Result::Sales::Order',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

sub to_data {
    my $self = shift;
    my $data = {};
    $data->{$_} = $self->$_ for qw(
      id hash country_code line1 line2 level1 level2 postal_code personal_name organization
    );

    # phone, fax, mobile
    $self->phones->each( sub { $data->{ $_->type->name } = $_->number; } );

    return $data;
}

1;
