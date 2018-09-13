package Yetie::Domain::Entity::Cart;
use Yetie::Domain::Base 'Yetie::Domain::Entity';
use Carp qw/croak/;
use Yetie::Domain::Value::Email;
use Yetie::Domain::Entity::Address;
use Yetie::Domain::List::CartItems;
use Yetie::Domain::List::Shipments;

has id => sub { $_[0]->hash_code( $_[0]->cart_id ) };
has cart_id         => '';
has email           => sub { Yetie::Domain::Value::Email->new };
has billing_address => sub { Yetie::Domain::Entity::Address->new };
has items           => sub { Yetie::Domain::List::CartItems->new };
has shipments       => sub { Yetie::Domain::List::Shipments->new };

my @needless_attrs = (qw/cart_id items/);

# has 'items';
# has item_count       => sub { shift->items->flatten->size };
# has original_total_price => 0;
# has total_price          => 0;
# has total_weight         => 0;

# cart.attributes
# cart.item_count
# cart.items
# cart.note
# cart.original_total_price
# cart.total_price
# cart.total_weight

sub add_item {
    my ( $self, $item ) = @_;
    croak 'Argument was not a Object' if ref $item =~ /::/;

    _add_item( $self->items, $item );

    $self->_is_modified(1);
    return $self;
}

sub add_shipping_item {
    my ( $self, $index, $item ) = @_;
    croak 'First argument was not a Digit'   if $index =~ /\D/;
    croak 'Second argument was not a Object' if ref $item =~ /::/;

    my $shipment = $self->shipments->[$index];
    _add_item( $shipment->items, $item );

    $self->_is_modified(1);
    return $self;
}

sub all_shipping_items {
    shift->shipments->map( sub { $_->items->each } );
}

# NOTE: shipment.itemsにあるitemsも削除するべきか？
sub clear {
    my $self = shift;
    $self->items->each( sub { $self->remove_item( $_->id ) } );
}

sub count {
    my ( $self, $attr ) = @_;
    return $self->$attr->size;
}

sub grand_total {
    my $self        = shift;
    my $grand_total = $self->subtotal;

    # 送料計算等

    return $grand_total;
}

sub merge {
    my ( $self, $target ) = @_;
    my ( $clone, $stored ) = ( $self->clone, $target->clone );

    # items
    foreach my $item ( @{ $stored->items->list } ) {
        $clone->items->each(
            sub {
                my ( $e, $num ) = @_;
                if ( $e->equal($item) ) {
                    $item->quantity( $e->quantity + $item->quantity );
                    my $i = $num - 1;
                    splice @{ $clone->items->list }, $i, 1;
                }
            }
        );
    }
    push @{ $stored->items->list }, @{ $clone->items->list };

    # shipments
    # NOTE: [WIP]
    # 未ログイン状態でshipmentsを設定している場合にどうするか。
    # - ログイン状態でshipmentsを設定している（カートに保存されている）
    # - ログアウト後に未ログイン状態でshipments設定まで進んだ後にログインする
    # 通常はその前にログインを促すのでありえない状態ではあるが...

    $stored->_is_modified(1);
    return $stored;
}

# NOTE: 数量は未考慮
sub remove_item {
    my ( $self, $item_id ) = @_;
    croak 'Argument was not a Scalar' if ref \$item_id ne 'SCALAR';

    my ( $removed, $collection ) = _remove_item( $self->items, $item_id );
    $self->items($collection) if $removed;
    return $removed;
}

# NOTE: 数量は未考慮
sub remove_shipping_item {
    my ( $self, $index, $item_id ) = @_;
    croak 'First argument was not a Digit'   if $index =~ /\D/;
    croak 'Second argument was not a Scalar' if ref \$item_id ne 'SCALAR';

    my $shipment = $self->shipments->[$index];
    my ( $removed, $collection ) = _remove_item( $shipment->items, $item_id );

    $shipment->items($collection) if $removed;
    return $removed;
}

sub subtotal {
    my $self     = shift;
    my $subtotal = 0;

    $subtotal += $self->items->reduce( sub { $a + $b->subtotal }, 0 );
    $subtotal += $self->shipments->reduce( sub { $a + $b->subtotal }, 0 );

    return $subtotal;
}

sub to_order_data {
    my $self = shift;
    my $data = $self->to_data;

    # Remove needless data
    delete $data->{$_} for @needless_attrs;
    return $data;
}

sub total_item_count {

    # $_[0]->items->size + $_[0]->shipments->reduce( sub { $a + $b->item_count }, 0 );
    $_[0]->count('items') + $_[0]->count('all_shipping_items');
}

sub total_quantity {
    $_[0]->items->reduce( sub { $a + $b->quantity }, 0 ) +
      $_[0]->shipments->reduce( sub { $a + $b->subtotal_quantity }, 0 );
}

sub update_shipping_address {
    my $self = shift;
    die 'Argument is missing.' unless @_;

    # Convert array reference
    if ( ref $_[0] eq 'ARRAY' ) {
        @_ = map { $_ => $_[0]->[$_] } 0 .. scalar @{ $_[0] } - 1;
    }
    my $arg = @_ > 1 ? +{@_} : { 0 => $_[0] };

    my $updated = 0;
    foreach my $key ( keys %{$arg} ) {
        $self->_update_shipping_address( $key, $arg->{$key} );
        $updated++;
    }
    return $updated;
}

sub _add_item {
    my ( $collection, $item ) = @_;

    my $exsist_item = $collection->find( $item->id );
    return $collection->push($item) unless $exsist_item;

    my $qty = $exsist_item->quantity + $item->quantity;
    $exsist_item->quantity($qty);
}

sub _remove_item {
    my ( $collection, $item_id ) = @_;

    my $removed;
    my $new_collection = $collection->grep( sub { $_->id eq $item_id ? ( $removed = $_ and 0 ) : 1 } );
    return ( $removed, $new_collection );
}

sub _update_shipping_address {
    my ( $self, $index, $address ) = @_;

    my $shipping_address =
      eval { $address->isa('Yetie::Domain::Entity::Address') }
      ? $address
      : $self->factory('entity-address')->construct($address);

    $self->shipments->[$index]->shipping_address($shipping_address);
}

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Cart

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Cart> inherits all attributes from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<billing_address>

=head2 C<cart_id>

=head2 C<id>

=head2 C<items>

    my $items = $cart->items;
    $items->each( sub { ... } );

Return L<Yetie::Domain::List::CartItems> object.
Elements is L<Yetie::Domain::Entity::Cart::Item> object.

=head2 C<shipments>

    my $shipments = $cart->shipments;
    $shipments->each( sub { ... } );

Return L<Yetie::Domain::Collection> object.
Elements is L<Yetie::Domain::Entity::Shipment> object.

=head1 METHODS

L<Yetie::Domain::Entity::Cart> inherits all methods from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<add_item>

    $cart->add_item( $entity_item_object );

Return L<Yetie::Domain::Entity::Cart> Object.

=head2 C<add_shipping_item>

    $cart->add_shipping_item( $entity_item_object );
    $cart->add_shipping_item( $index, $entity_item_object );

Return L<Yetie::Domain::Entity::Cart> Object.

C<$shipment_object> is option argument.
default $shipments->first

=head2 C<all_shipping_items>

    my $all_shipping_items = $cart->all_shipping_items;

All items in shipments.

=head2 C<clear>

    $cart->clear;

Remove all items.

=head2 C<clone>

=head2 C<count>

=head2 C<grand_total>

=head2 C<is_modified>

    my $bool = $cart->is_modified;

Return boolean value.

=head2 C<merge>

    my $merged = $cart->merge($stored_cart);

Return Entity Cart Object.

=head2 C<remove_item>

    my $removed_item = $cart->remove_item($item_id);

Return L<Yetie::Domain::Entity::Cart::Item> object or undef.

=head2 C<remove_shipping_item>

    my $removed_item = $cart->remove_shipping_item($index, $item_id);

Return L<Yetie::Domain::Entity::Cart::Item> object or undef.

=head2 C<subtotal>

    my $subtotal = $cart->subtotal;

=head2 C<to_order_data>

    my $order = $self->to_order_data;

=head2 C<total_item_count>

    my $item_count = $cart->total_item_count;

Return number of items types.

=head2 C<total_quantity>

    my $total_qty = $cart->total_quantity;

Return all items quantity.

=head2 C<update_shipping_address>

    # Update first element
    $cart->update_shipping_address( \%address );
    $cart->update_shipping_address( $address_obj );

    # Update multiple elements
    $cart->update_shipping_address( 1 => \%address, 3 => $address_obj, ... );
    $cart->update_shipping_address( [ \%address, $address_obj, ... ] );

Update shipping address.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity>, L<Yetie::Domain::List::CartItems>, L<Yetie::Domain::Entity::Cart::Item>,
L<Yetie::Domain::Entity::Shipment>
