use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Test::Mojo;

my $pkg = 'Markets::Domain::Factory';
use_ok 'Markets::Domain::Factory::Entity::Cart';

my $shipments = bless [
    bless {
        shipping_address => ( bless {}, 'Markets::Domain::Entity::Address' ),
        shipping_items => ( bless [], 'Markets::Domain::Collection' ),
    },
    'Markets::Domain::Entity::Shipment'
  ],
  'Markets::Domain::Collection';

subtest 'argument empty' => sub {
    my $e = $pkg->new('entity-cart')->create_entity;
    cmp_deeply $e,
      bless {
        items => ( bless [], 'Markets::Domain::Collection' ),
        shipments       => $shipments,
        billing_address => ( bless {}, 'Markets::Domain::Entity::Address' ),
      },
      'Markets::Domain::Entity::Cart';
};

subtest 'shipments empty hash ref' => sub {
    my $e = $pkg->new( 'entity-cart', { shipments => [] } )->create_entity;
    cmp_deeply $e,
      bless {
        items           => ignore(),
        shipments       => $shipments,
        billing_address => ignore(),
      },
      'Markets::Domain::Entity::Cart';
};

subtest 'cart data empty' => sub {
    my $e = $pkg->new('entity-cart')->create_entity;
    cmp_deeply $e,
      bless {
        items => ( bless [], 'Markets::Domain::Collection' ),
        shipments       => ignore(),
        billing_address => ignore(),
      },
      'Markets::Domain::Entity::Cart';
};

subtest 'argument items data only' => sub {
    my $e = $pkg->new(
        'entity-cart',
        {
            items => [ {} ],
        }
    )->create_entity;
    cmp_deeply $e,
      bless {
        items => ( bless [ ( bless {}, 'Markets::Domain::Entity::SellingItem' ) ], 'Markets::Domain::Collection' ),
        shipments       => ignore(),
        billing_address => ignore(),
      },
      'Markets::Domain::Entity::Cart';
};

subtest 'argument shipments data only' => sub {
    my $e = $pkg->new( 'entity-cart', { shipments => [ { shipping_items => [ {}, {} ] } ] }, )->create_entity;
    $shipments->[0]->{shipping_items} = bless [ ( bless {}, 'Markets::Domain::Entity::SellingItem' ),
        ( bless {}, 'Markets::Domain::Entity::SellingItem' ) ],
      'Markets::Domain::Collection';
    cmp_deeply $e,
      bless {
        items           => ignore(),
        shipments       => $shipments,
        billing_address => ignore(),
      },
      'Markets::Domain::Entity::Cart';
};

done_testing;
