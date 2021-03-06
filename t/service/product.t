use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;
use Test::Exception;

my $t   = Test::Mojo->new('App');
my $app = $t->app;
use_ok 'Yetie::Service::Product';

subtest 'duplicate_product' => sub {
    my $c       = $app->build_controller;
    my $service = $c->service('product');
    my $rs      = $c->resultset('Product');

    my $last_id           = $rs->last_id;
    my $target_product_id = 1;
    my $orig              = $rs->find($target_product_id);

    $service->duplicate_product($target_product_id);
    my $result = $rs->find( $last_id + 1 );
    is $result->description, $orig->description, 'right description';
    is $result->price,       $orig->price,       'right price';
    like $result->title, qr/copy/, 'copy title';
    is $result->product_categories, $orig->product_categories, 'right product_categories';
};

subtest 'find_product' => sub {
    my $e = $app->service('product')->find_product(1);
    isa_ok $e, 'Yetie::Domain::Entity::Product';
    is $e->id, 1, 'right ID';

    $e = $app->service('product')->find_product(999);
    is $e->id, undef, 'right not found product';
};

subtest 'new_product' => sub {
    my $c       = $app->build_controller;
    my $service = $c->service('product');

    my $last_id = $c->resultset('Product')->last_id;
    my $product = $service->new_product;
    is $product->id, $last_id + 1, 'right create new product';
};

subtest 'remove_product' => sub {
    my $c       = $app->build_controller;
    my $service = $c->service('product');

    my $result  = $c->resultset('Product')->search( {}, { order_by => { -desc => 'id' } } );
    my $all     = $result->count;
    my $last_id = $result->first->id;
    my $product = $service->remove_product($last_id);
    is $product->id, $last_id, 'right remove product(id)';

    my $after = $c->resultset('Product')->search( {} )->count;
    is $after, $all - 1, 'right remove product(count)';
};

done_testing();

__END__
