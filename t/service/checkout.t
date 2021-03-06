package t::service::checkout;

use Mojo::Base 't::common';
use t::Util;
use Test::Mojo;

sub t00_startup : Tests(startup) { shift->app->routes->any('/:controller/:action')->to() }

sub t01_basic : Tests() {
    my $self = shift;
    my $t    = $self->t;

    $t->get_ok('/test/create')->status_is(200);
    $t->get_ok('/test/load')->status_is(200);
    $t->get_ok('/test/save')->status_is(200);
    $t->get_ok('/test/delete')->status_is(200);
}

sub t02_add_all_cart_items : Tests() {
    my $self = shift;
    my $t    = $self->t;
    $t->get_ok('/test/add_all_cart_items')->status_is(200);
}

sub t03_set_address : Tests() {
    my $self = shift;
    my $t    = $self->t;
    $t->get_ok('/test/reset')->status_is(200);
}

sub t04_set_address : Tests() {
    my $self = shift;
    my $t    = $self->t;
    $t->get_ok('/test/set_shipping_address')->status_is(200);
    $t->get_ok('/test/after_set_shipping_address')->status_is(200);

    $t->get_ok('/test/set_billing_address')->status_is(200);
    $t->get_ok('/test/after_set_billing_address')->status_is(200);
}

sub t05_calculate_shipping_fees : Tests() {
    my $self = shift;
    my $t    = $self->t;
    $t->get_ok('/test/calculate_shipping_fees')->status_is(200);
}

__PACKAGE__->runtests;

package Yetie::Controller::Catalog::Test;
use Mojo::Base 'Yetie::Controller::Catalog';
use Test::More;
use Test::Deep;
use Test::Exception;

sub add_all_cart_items {
    my $c        = shift;
    my $checkout = $c->service('checkout')->get;

    # Cart in
    $c->service('cart')->add_item( { product_id => 1, quantity => 1 } );
    $c->service('cart')->add_item( { product_id => 2, quantity => 2 } );

    # Add shipping address
    my $address = $checkout->factory('entity-address')->construct( country_code => 'jp' );

    $c->service('checkout')->set_shipping_address($address);

    my $items = $c->cart->items;
    $c->service('checkout')->add_all_cart_items();
    is_deeply $items->to_data, $checkout->sales_orders->first->items->to_data, 'right items';

    return $c->render( text => 1 );
}

sub after_set_billing_address {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    is $checkout->billing_address->country_code, 'baz', 'right reload billing address';

    return $c->render( text => 1 );
}

sub after_set_shipping_address {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    is $checkout->sales_orders->first->shipping_address->country_code, 'bar', 'right reload shipping address';

    return $c->render( text => 1 );
}

sub calculate_shipping_fees {
    my $c = shift;

    lives_ok { $c->service('checkout')->calculate_shipping_fees };
    return $c->render( text => 1 );
}

sub create {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    isa_ok $checkout, 'Yetie::Domain::Entity::Checkout';
    is $checkout->sales_orders->size, 1, 'right new element in sales orders';
    isa_ok $checkout->sales_orders->first, 'Yetie::Domain::Entity::SalesOrder';
    ok $c->server_session->data('checkout'), 'right create';
    ok $c->stash('checkout'), 'right stash';

    return $c->render( text => 1 );
}

sub delete {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    ok $c->server_session->data('checkout'), 'right session';
    $c->service('checkout')->delete;
    is_deeply $c->server_session->data('checkout'), undef, 'right delete';
    ok !$c->stash('checkout'), 'right stash';

    return $c->render( text => 1 );
}

sub load {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    isa_ok $checkout, 'Yetie::Domain::Entity::Checkout';
    is $checkout->sales_orders->size, 1, 'right load sales orders';

    return $c->render( text => 1 );
}

sub reset {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    my $new      = $c->service('checkout')->reset;
    isnt $checkout, $new, 'right reset checkout';

    my $load = $c->service('checkout')->get;
    is $new, $load, 'right stored object';
    return $c->render( text => 1 );
}

sub save {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    $checkout->set_billing_address( $c->factory('entity-address')->construct( id => 'foo' ) );

    $c->service('checkout')->save;
    is $c->server_session->data('checkout')->{billing_address}->{id}, 'foo', 'right save data';
    is $c->stash('checkout'), $checkout, 'right equals object for stash';

    return $c->render( text => 1 );
}

sub set_billing_address {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    my $address = $c->factory('entity-address')->construct( country_code => 'baz' );
    $c->service('checkout')->set_billing_address($address);
    is $checkout->billing_address->country_code, 'baz', 'right set blling address';

    return $c->render( text => 1 );
}

sub set_shipping_address {
    my $c = shift;

    my $checkout = $c->service('checkout')->get;
    my $address = $c->factory('entity-address')->construct( country_code => 'foo' );
    $c->service('checkout')->set_shipping_address($address);
    is $checkout->sales_orders->first->shipping_address->country_code, 'foo', 'right set shipping address';

    $address = $c->factory('entity-address')->construct( country_code => 'bar' );
    $c->service('checkout')->set_shipping_address( 0 => $address );
    is $checkout->sales_orders->first->shipping_address->country_code, 'bar', 'right update shipping address';

    return $c->render( text => 1 );
}

1;
