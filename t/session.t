use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;

my $t   = Test::Mojo->new('App');
my $app = $t->app;

# use Mojo::Cookie::Response;
my $cookie = Mojo::Cookie::Request->new( name => 'sid', value => 'bar', path => '/' );
my $tx = Mojo::Transaction::HTTP->new();
$tx->req->cookies($cookie);

my $session = Markets::Session::ServerSession->new(
    tx            => $tx,
    store         => Markets::Session::Store::Dbic->new( schema => $app->schema ),
    transport     => MojoX::Session::Transport::Cookie->new,
    expires_delta => 3600,
);
my $sid     = $session->create;
my $cart_id = $session->cart_id;
my $cart    = $session->cart_session;

subtest 'create session' => sub {
    is ref $session, 'Markets::Session::ServerSession', 'right session object';
    is ref $cart,    'Markets::Session::CartSession',   'right cart object';

    ok $sid, 'created session';
    is_deeply $session->cart_session->data, {}, 'create new cart';
    $session->flush;

    is_deeply $session->cart_session->data, {}, 'cart data after flush';
    ok $cart_id, 'right session->cart_id';
    is $cart_id, $session->cart_session->cart_id, 'right cart_id';
    is $session->cart_session->cart_id, $session->cart_id, 'right cart_id';
};

subtest 'store for cart' => sub {
    my $store  = $session->store;
    my $result = $store->schema->resultset( $store->resultset_cart )->find($cart_id);
    $result = $store->schema->resultset( $store->resultset_cart )->find($cart_id);
    ok $result->data, 'schema: right cart data';
};

subtest 'load session' => sub {
    my $cookie = Mojo::Cookie::Request->new( name => 'sid', value => $sid, path => '/' );
    my $tx = Mojo::Transaction::HTTP->new();
    $session->tx($tx);
    $tx->req->cookies($cookie);
    is $session->load, $sid, 'loading session';
    is ref $session->cart_session->data, 'HASH', 'right cart data';
    is $session->cart_session->cart_id, $cart_id, 'right cart id';
};

subtest 'set session data' => sub {

    # set and unsaved
    $session->data( counter => 1 );
    $session->load;
    is $session->data('counter'), undef, 'right unsaved session data';

    # set and saved
    $session->data( counter => 1 );
    $session->flush;
    $session->load;
    is $session->data('counter'), 1, 'right saved session data';
};

subtest 'set cart data' => sub {

    # set and unsaved
    $cart->data( payment => ['buzz'] );
    $session->load;
    is $cart->data('payment'), undef, 'right unsaved cart data';

    # set and saved
    $session->cart_session->data( items => ['hoge'] );
    $session->flush;
    $session->load;
    is_deeply $session->cart_session->data('items'), ['hoge'], 'right saved cart data';

    $cart->data( payment => ['buzz'] );
    $session->flush;
    $session->load;
    is_deeply $cart->data('payment'), ['buzz'], 'right saved cart data';
};

subtest 'get cart data' => sub {
    $cart->data( items => [ {} ] );
    is_deeply $cart->data('items'),                    [ {} ], 'set data in the cart';
    is_deeply $session->data('cart')->{data}->{items}, [ {} ], 'right session data changed';
    $session->flush;
    $session->load;

    # from session
    is_deeply $session->cart_data, $cart->data, 'right cart data from DB';
    is_deeply $session->cart_data($cart_id), $cart->data, 'right cart data from DB';
    is $session->cart_data('cart_id_hoge'), undef, 'right cart data not found cart';
};

subtest 'change all cart data' => sub {
    $cart->data( { items => [], address => {} } );
    is_deeply $cart->data, { items => [], address => {} }, 'set all cart data';
    $session->flush;
    $session->load;
    is_deeply $cart->data, { items => [], address => {} }, 'reload cart data';
};

subtest 'remove cart data' => sub {
    $cart->flash('items');
    is_deeply $cart->data, { address => {} }, 'flash instracted cart data';
    $cart->flash;
    is_deeply $cart->data, {}, 'flash all cart data';

    $session->flush;
    $session->load;
    is_deeply $cart->data, {}, 'flash all cart data after reload session';
};

subtest 'change cart_id' => sub {
    my $new_cartid = 'aaabbbcccddd';
    $session->cart_id($new_cartid);
    is $session->cart_id, $new_cartid, 'right changed cart id';
    is $cart->cart_id,    $new_cartid, 'right changed cart id';

    $session->flush;
    $session->load;
    is $session->cart_id, $new_cartid, 'right changed cart id after reload';
    is $cart->cart_id,    $new_cartid, 'right changed cart id after reload';
};

subtest 'customer_id' => sub {
    my $customer_id = $session->data('customer_id');
    is $session->customer_id, $customer_id, 'right load customer_id';

    $session->customer_id('123456');
    is $session->customer_id, 123456, 'right changed customer_id';

    $session->flush;
    $session->load;
    is $session->customer_id, 123456, 'right changed customer_id';
};

subtest 'staff_id' => sub {
    my $staff_id = $session->data('staff_id');
    is $session->staff_id, $staff_id, 'right load staff_id';

    $session->staff_id('123456');
    is $session->staff_id, 123456, 'right changed staff_id';

    $session->flush;
    $session->load;
    is $session->staff_id, 123456, 'right changed staff_id';
};

subtest 'regenerate sid' => sub {
    my $sid     = $session->sid;
    my $cart_id = $session->cart_id;
    my %data    = %{ $session->data };
    my $new_sid = $session->regenerate_sid;
    isnt $sid, $new_sid, 'right regenerate sid';
    is $cart_id, $session->cart_id, 'right cart_id';

    my %new_data = %{ $session->data };
    is %data, %new_data, 'right session data';
    is $session->sid, $new_sid, 'right sid';

    $session->flush;
    $session->load($new_sid);
    is $session->sid, $new_sid, 'right reload sid';
    is %new_data, %{ $session->data }, 'right reload data';

    subtest 'remove session' => sub {
        $session->expire;
        $session->flush;
        is $session->load($new_sid), undef, 'removed session';
    };

    subtest 'remove cart' => sub {
        ok $session->remove_cart('not_found_cart') == 0, 'do not removed cart';
        is $session->remove_cart($cart_id), 1, 'removed cart';
    };
};

done_testing();
