package Yetie::Domain::Entity::Checkout;
use Yetie::Util;
use Carp qw(croak);

use Moose;
use namespace::autoclean;
extends 'Yetie::Domain::Entity';

has billing_address => (
    is      => 'ro',
    isa     => 'Yetie::Domain::Entity::Address',
    default => sub { shift->factory('entity-address')->construct() },
    writer  => 'set_billing_address',
);
has payment_method => (
    is      => 'ro',
    isa     => 'Yetie::Domain::Entity::PaymentMethod',
    default => sub { shift->factory('entity-payment_method')->construct() },
    writer  => 'set_payment_method',
);
has sales_orders => (
    is      => 'ro',
    isa     => 'Yetie::Domain::List::SalesOrders',
    default => sub { shift->factory('list-sales_orders')->construct() },
);
has transaction => (
    is      => 'ro',
    isa     => 'Yetie::Domain::Entity::Transaction',
    default => sub { shift->factory('entity-transaction')->construct() },
);

# NOTE: not use
# sub add_shipment_item {
#     my $self = shift;
#     my ( $index, $item ) = @_ > 1 ? ( shift, shift ) : ( 0, shift );
#     croak 'First argument was not a Digit'   if $index =~ /\D/sxm;
#     croak 'Second argument was not a Object' if ref $item =~ /::/sxm;

#     my $sales_order = $self->sales_orders->get($index);
#     $sales_order->items->append($item);
#     return $self;
# }

sub has_billing_address { return shift->billing_address->is_empty ? 0 : 1 }

sub has_payment_method { return shift->payment_method->is_empty ? 0 : 1 }

sub has_shipping_address {
    my $self = shift;

    return 0 if !$self->sales_orders->has_elements;
    return $self->sales_orders->first->shipping_address->is_empty ? 0 : 1;
}

sub has_shipping_item { return shift->sales_orders->has_item }

sub set_shipping_address {
    my ( $self, @args ) = @_;
    croak 'Argument is missing.' if !@args;

    # Convert arguments
    my $addresses = @args > 1 ? +{@args} : Yetie::Util::array_to_hash(@args);

    foreach my $index ( keys %{$addresses} ) {
        my $address     = $addresses->{$index};
        my $sales_order = $self->sales_orders->get($index);

        next if $sales_order->shipping_address->equals($address);
        $sales_order->set_shipping_address($address);
    }
    return $self;
}

sub to_order_data {
    my $self = shift;
    my $data = $self->to_data;

    # Transaction
    if ( !$self->transaction->id ) {
        delete $data->{transaction};
    }

    # Remove unnecessary data
    # for (qw/is_confirmed/) { delete $data->{$_} }

    # Billing Address
    $data->{billing_address} = { id => $data->{billing_address}->{id} };

    # Payment Method
    $data->{payment_method} = { id => $data->{payment_method}->{id} };

    # Override Sales Orders
    $data->{sales_orders} = $self->sales_orders->to_order_data();

    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Checkout

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Checkout> inherits all attributes from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<billing_address>

Return L<Yetie::Domain::Entity::Address> object.

=head2 C<sales_orders>

    my $sales_orders = $checkout->sales_orders;

Return L<Yetie::Domain::List::SalesOrders> object.

=head2 C<transaction>

    my $transaction = $checkout->transaction;

Return L<Yetie::Domain::Entity::Transaction> object.

=head1 METHODS

L<Yetie::Domain::Entity::Checkout> inherits all methods from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<add_shipment_item>

    $checkout->add_shipment_item( $entity_item_object );
    $checkout->add_shipment_item( $index_no => $entity_item_object );

Return L<Yetie::Domain::Entity::Checkout> Object.

C<$index_no> is option argument.
Default $sales_orders->first

=head2 C<has_billing_address>

    my $bool = $checkout->has_billing_address;

Return boolean value.

=head2 C<has_payment_method>

    my $bool = $checkout->has_payment_method;

Return boolean value.

=head2 C<has_shipping_address>

    my $bool = $checkout->has_shipping_address;

Return boolean value.

=head2 C<has_shipping_item>

    my $bool = $checkout->has_shipping_item;

Return boolean value.

=head2 C<revert>

    $checkout->revert;

Delete except the first shipping-information.
Also delete all shipping-items of the first shipping-information.

See L<Yetie::Domain::List::SalesOrders/revert>.

=head2 C<set_billing_address>

    $checkout->set_billing_address( $address_obj );

=head2 C<set_shipping_address>

    # Update first element
    $checkout->set_shipping_address( $address_obj );

    # Update multiple elements
    $checkout->set_shipping_address( 1 => $address_obj, 3 => $address_obj, ... );
    $checkout->set_shipping_address( [ $address_obj, $address_obj, ... ] );

Update shipping address.

=head2 C<to_order_data>

    my $order_data = $checkout->to_order_data;

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity::Cart>, L<Yetie::Domain::Entity::Transaction>, L<Yetie::Domain::Entity>
