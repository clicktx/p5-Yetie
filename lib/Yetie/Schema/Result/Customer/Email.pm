package Yetie::Schema::Result::Customer::Email;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column customer_id => {
    data_type   => 'INT',
    is_nullable => 0,
};

column email_id => {
    data_type   => 'INT',
    is_nullable => 0,
};

column is_primary => {
    data_type     => 'BOOLEAN',
    is_nullable   => 0,
    default_value => 0,
};

# Relation
belongs_to
  customer => 'Yetie::Schema::Result::Customer',
  { 'foreign.id' => 'self.customer_id' };

belongs_to
  email => 'Yetie::Schema::Result::Email',
  { 'foreign.id' => 'self.email_id' };

# Index
sub sqlt_deploy_hook {
    my ( $self, $table ) = @_;

    # alter index type
    my @indices = $table->get_indices;
    foreach my $index (@indices) {
        $index->type('unique') if $index->name eq 'customer_emails_idx_email_id';
    }
}

sub to_data {
    my $self = shift;

    return {
        value       => $self->email->address,
        is_primary  => $self->is_primary,
        is_verified => $self->email->is_verified,
    };
}

1;
