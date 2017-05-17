package Markets::Schema::Result::Customer;
use Mojo::Base 'Markets::Schema::ResultCommon';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column created_at => {
    data_type   => 'DATETIME',
    is_nullable => 0,
    timezone    => Markets::Schema->TZ,
};

column updated_at => {
    data_type   => 'DATETIME',
    is_nullable => 1,
    timezone    => Markets::Schema->TZ,
};

has_many
  addresses => 'Markets::Schema::Result::Customer::Address',
  { 'foreign.customer_id' => 'self.id' };

has_many
  order_headers => 'Markets::Schema::Result::Sales::OrderHeader',
  { 'foreign.customer_id' => 'self.id' };

1;