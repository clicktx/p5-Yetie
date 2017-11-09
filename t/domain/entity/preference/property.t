use Mojo::Base -strict;
use Test::More;
use Test::Deep;

use_ok 'Yetie::Domain::Entity::Preference::Property';

my $data = {
    id            => 1,
    name          => 'pref1',
    value         => '',
    default_value => '11',
    title         => 'pref title',
    summary       => 'pref summary',
    position      => 500,
    group_id      => 1,
};

my $e = Yetie::Domain::Entity::Preference::Property->new($data);

subtest 'basic' => sub {
    isa_ok $e, 'Yetie::Domain::Entity';
};

subtest 'attributes' => sub {

    # can_ok $e, 'name';
    can_ok $e, 'value';
    can_ok $e, 'default_value';

    # can_ok $e, 'title';
    # can_ok $e, 'summary';
    can_ok $e, 'position';
    can_ok $e, 'group_id';
};

# subtest 'methods' => sub {
# };

done_testing();