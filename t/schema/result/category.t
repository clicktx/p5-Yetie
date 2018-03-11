use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;

my $t      = Test::Mojo->new('App');
my $app    = $t->app;
my $schema = $app->schema;
my $rs     = $schema->resultset('Category');

subtest 'to_data' => sub {
    my $res  = $rs->find(1);
    my $data = $res->to_data;

    is_deeply $data,
      {
        id       => 1,
        level    => 0,
        root_id  => 1,
        title    => 'Sports',
        children => [
            {
                id       => 3,
                level    => 1,
                root_id  => 1,
                title    => 'Golf',
                children => [],
            },
            {
                id       => 4,
                level    => 1,
                root_id  => 1,
                title    => 'Soccer',
                children => [],
            },
        ],
      },
      'right data';

    $data = $res->to_data( { no_children => 1 } );
    is_deeply $data,
      {
        id      => 1,
        level   => 0,
        root_id => 1,
        title   => 'Sports',
      },
      'right option';
};

done_testing();
