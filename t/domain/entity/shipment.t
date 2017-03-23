use Mojo::Base -strict;
use Test::More;
use Mojo::Collection qw/c/;

use_ok 'Markets::Domain::Entity::Shipment';
my $shipment = Markets::Domain::Entity::Shipment->new(
    {
        address => 'Tokyo',
    }
);

isa_ok $shipment, 'Markets::Domain::Entity::Shipment';
can_ok $shipment, 'items';
can_ok $shipment, 'address';
can_ok $shipment, 'item_count';

is $shipment->hash_code,  '963dd210cc93a4597038ceabe0fe93b258a362b9', 'right hash_code';
is $shipment->id, '963dd210cc93a4597038ceabe0fe93b258a362b9', '';

my $shipment2 = Markets::Domain::Entity::Shipment->new(
    {
        address => 'Osaka',
    }
);

is $shipment->is_equal($shipment),  1, 'right equal item';
is $shipment->is_equal($shipment2), 0, 'right not equal item';

done_testing();
