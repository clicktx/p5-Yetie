package Yetie::Schema::ResultSet::SalesOrderItem;
use Mojo::Base 'Yetie::Schema::ResultSet';

sub store_item {
    my ( $self, $data ) = @_;

    my $id = $data->{id} || q{};
    my $item = $self->find(
        $id,
        {
            prefetch => [ { sales_price => 'price' }, 'tax_rule' ],
        }
    );

    # Update
    return $self->_update( $item, $data ) if $item;

    # Insert
    return $self->create($data);
}

sub _update {
    my ( $self, $item, $data ) = @_;

    # price
    my $sales_price_data = delete $data->{sales_price};
    $item->sales_price->price->update( $sales_price_data->{price} );
    return $item->update($data);
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::ResultSet::SalesOrderItem

=head1 SYNOPSIS

    my $result = $schema->resultset('SalesOrderItem')->method();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::ResultSet::SalesOrderItem> inherits all attributes from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::ResultSet::SalesOrderItem> inherits all methods from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head2 C<store_item>

    $rs->store_item( \%data );

Return value

create: $result

update: undef

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::ResultSet>, L<Yetie::Schema>
