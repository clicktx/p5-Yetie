package Yetie::Domain::Entity::SalesOrder;
use Yetie::Util qw(args2hash);

use Moose;
use namespace::autoclean;
extends 'Yetie::Domain::Entity';

has items => (
    is      => 'ro',
    isa     => 'Yetie::Domain::List::SalesItems',
    default => sub { shift->factory('list-sales_items')->construct() }
);
has shipping_address => (
    is      => 'ro',
    isa     => 'Yetie::Domain::Entity::Address',
    default => sub { shift->factory('entity-address')->construct() },
    writer  => 'set_shipping_address',
);
has shippings => (
    is      => 'ro',
    isa     => 'Yetie::Domain::List::Shippings',
    default => sub { shift->factory('list-shippings')->construct() },
);

sub count_items { return shift->items->size }

sub subtotal_excl_tax {
    my $self = shift;

    my $price = $self->_init_price( is_tax_included => 0 );
    my $items_total = $self->items->reduce( sub { $a + $b->row_total_excl_tax }, $price );

    my $subtotal = $items_total;
    return $subtotal;
}

sub subtotal_incl_tax {
    my $self = shift;

    my $price = $self->_init_price( is_tax_included => 1 );
    my $items_total = $self->items->reduce( sub { $a + $b->row_total_incl_tax }, $price );

    my $subtotal = $items_total;
    return $subtotal;
}

sub to_order_data {
    my $self = shift;
    return {
        id               => $self->id,
        items            => $self->items->to_order_data,
        shipping_address => { id => $self->shipping_address->id },

        # shippings => $self->shippings->to_order_data,
    };
}

sub _init_price {
    my $self = shift;
    my $args = args2hash(@_);

    my $first_item = $self->items->first;
    return $first_item
      ? $first_item->price->clone( value => 0, is_tax_included => $args->{is_tax_included} )
      : $self->factory('value-price')->construct( is_tax_included => $args->{is_tax_included} );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Yetie::Domain::Entity::SalesOrder

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::SalesOrder> inherits all attributes from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<shipping_address>

Return L<Yetie::Domain::Entity::Address> object.

=head2 C<items>

Return L<Yetie::Domain::List::LineItems> object.

=head1 METHODS

L<Yetie::Domain::Entity::SalesOrder> inherits all methods from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<count_items>

    my $count = $sales_order->count_items;

=head2 C<subtotal_excl_tax>

    my $subtotal_excl_tax = $sales_order->subtotal_excl_tax;

=head2 C<subtotal_incl_tax>

    my $subtotal_incl_tax = $sales_order->subtotal_incl_tax;

=head2 C<to_order_data>

    my $order_data = $sales_order->to_order_data();

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity>
