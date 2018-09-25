use Mojo::Base -strict;
use Test::More;

my $pkg = 'Yetie::Domain::Factory';
use_ok 'Yetie::Domain::Factory::Entity::Cart';

subtest 'argument empty' => sub {
    my $e = $pkg->new('entity-cart')->construct();
    isa_ok $e->billing_address, 'Yetie::Domain::Entity::Address';
    isa_ok $e->items,           'Yetie::Domain::List::CartItems';
    isa_ok $e->shipments,       'Yetie::Domain::List::Shipments';
    $e->shipments->each(
        sub {
            isa_ok $_->shipping_address, 'Yetie::Domain::Entity::Address';
            isa_ok $_->items,            'Yetie::Domain::List::CartItems';
        }
    );
};

subtest 'shipments empty hash ref' => sub {
    my $e = $pkg->new( 'entity-cart', { shipments => [] } )->construct();
    is_deeply $e->shipments->list->to_data, [], 'right empty';
};

subtest 'cart data empty' => sub {
    my $e = $pkg->new('entity-cart')->construct();
    is $e->items->count, 0;
};

subtest 'argument items data only' => sub {
    my $e = $pkg->new(
        'entity-cart',
        {
            items => [ {} ],
        }
    )->construct();
    isa_ok $e->items->first, 'Yetie::Domain::Entity::Cart::Item';
};

subtest 'argument shipments data only' => sub {
    my $e = $pkg->new( 'entity-cart', { shipments => [ { items => [ {}, {} ] } ] }, )->construct();
    $e->shipments->first->items->each(
        sub {
            isa_ok $_, 'Yetie::Domain::Entity::Cart::Item';
        }
    );
};

done_testing;
