use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Yetie::Factory;

my $pkg = 'Yetie::Domain::List::Shipments';
use_ok $pkg;

sub construct {
    Yetie::Factory->new('list-shipments')->construct(@_);
}

subtest 'basic' => sub {
    my $v = construct();
    isa_ok $v, 'Yetie::Domain::List';
};

subtest 'create_shipment' => sub {
    my $v        = construct();
    my $shipment = $v->create_shipment;
    is $v->count, 1, 'right create shipment';
    isa_ok $shipment, 'Yetie::Domain::Entity::Shipment';
    isa_ok $v->first, 'Yetie::Domain::Entity::Shipment';

    my $shipment2 = $v->create_shipment;
    is $v->count, 2, 'right recreate shipment';
    isnt $shipment, $shipment2, 'right compare object';
};

subtest 'has_shipment' => sub {
    my $v    = construct();
    my $bool = $v->has_shipment;
    is $bool, 0, 'right has not shipment';

    $v = construct( list => [ {} ] );
    $bool = $v->has_shipment;
    is $bool, 1, 'right has shipment';
};

subtest 'is_multiple' => sub {
    my $v    = construct();
    my $bool = $v->is_multiple;
    is $bool, 0, 'right not set shipments';

    $v = construct( list => [ {} ] );
    $bool = $v->is_multiple;
    is $bool, 0, 'right single shipment';

    $v = construct( list => [ {}, {} ] );
    $bool = $v->is_multiple;
    is $bool, 1, 'right multiple shipments';
};

subtest 'total_item_count' => sub {
    my $v = construct( list => [ { items => [ {}, {} ] }, { items => [ {}, {} ] } ] );
    is $v->total_item_count, 4, 'right total items';
};

subtest 'total_quantity' => sub {
    my $v = construct( list => [ { items => [ { quantity => 1 }, { quantity => 2 } ] } ] );
    is $v->total_quantity, 3, 'right total quantity';
};

subtest 'revert' => sub {
    my $v = construct();
    is $v->revert, undef, 'right not has shipment';

    $v = construct( list => [ { shipping_address => { postal_code => 12345 }, items => [ { quantity => 1 } ] } ] );
    $v->revert;
    my $data = $v->to_data;
    is $data->[0]->{shipping_address}->{postal_code}, 12345, 'right shipping_address in first element';
    cmp_deeply $data, [ { shipping_address => ignore(), items => [] } ], 'right revert';
};

done_testing();