package Yetie::Schema::ResultSet::Sales::Order::Item;
use Mojo::Base 'Yetie::Schema::ResultSet';

sub store_items {
    my ( $self, $order ) = @_;

    my $order_id = $order->id;
    my $items    = $order->items;
    $items->each(
        sub {
            my $item = shift;
            my %data = ( order_id => $order_id, %{ $item->to_data } );
            $self->update_or_create( \%data );
        }
    );
    return $self;
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::ResultSet::Sales::Order::Item

=head1 SYNOPSIS

    my $result = $schema->resultset('Sales::Order::Item')->method();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::ResultSet::Sales::Order::Item> inherits all attributes from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::ResultSet::Sales::Order::Item> inherits all methods from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head2 C<store_items>

Create or update items.

    $rs->store_items( $order );

Argument: L<Yetie::Domain::Entity::OrderDetail> object.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::ResultSet>, L<Yetie::Schema>
