package Markets::Service::Cart;
use Mojo::Base 'Markets::Service';

sub add_item {
    my ( $self, $args ) = @_;

    # NOTE: APIで利用する場合にproductがstashに無い場合は生成する？
    my $product = $self->controller->stash('product');
    $args->{price} = $product->price;

    my $item = $self->controller->factory('entity-cart-item')->create($args);
    return $self->controller->helpers->cart->add_item($item);
}

sub create_entity {
    my $self = shift;

    my $cart_data = $self->controller->cart_session->data;
    $cart_data->{cart_id} = $self->controller->cart_session->cart_id;

    return $self->app->factory('entity-cart')->create($cart_data);
}

1;
__END__

=head1 NAME

Markets::Service::Cart - Application Service Layer

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Service::Cart> inherits all attributes from L<Markets::Service> and implements
the following new ones.

=head1 METHODS

L<Markets::Service::Cart> inherits all methods from L<Markets::Service> and implements
the following new ones.

=head2 C<add_item>

    my $cart = $c->service('cart')->add_item( $product, \%params);

Return L<Markets::Domain::Entity::Cart> object.

=head2 C<create_entity>

    my $cart = $c->service('cart')->create_entity();

Return L<Markets::Domain::Entity::Cart> object.

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

L<Markets::Service>
