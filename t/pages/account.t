use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;
use Data::Dumper;
use DDP;

my $t = Test::Mojo->new('App');

# pages
my @pages = qw(home orders wishlist);
foreach my $page (@pages) {
    $t->get_ok( '/account/' . $page, 'do not access, before loged-in' )->status_is(302);
}

subtest 'Login process' => sub {
    $t->get_ok('/account/wishlist')->status_is(302);
    $t->get_ok('/login');
    my $sid = _get_sid($t);
    ok $sid, 'right sid';

    # login
    my $tx         = $t->tx;
    my $csrf_token = $tx->res->dom->at('input[name="csrf_token"]')->{value};

    # access to wishlist
    $t->get_ok('/account/wishlist');

    # password failure
    $t->post_ok( '/login', form => { csrf_token => $csrf_token, customer_id => 'default' } )
      ->status_is( 200, 'password failure' );

    # accept and redirect to wishlist?
    $t->post_ok( '/login',
        form => { csrf_token => $csrf_token, customer_id => 'default', password => 'pass' } )
      ->status_is( 302, 'right accepr to redirect' )
      ->header_like( location => qr/wishlist/, 'right location after redirect' );

    my $sid_loged_in = _get_sid($t);
    isnt $sid, $sid_loged_in, 'right regenerate sid';

    # can access for all pages?
    foreach my $page (@pages) {
        $t->get_ok( '/account/' . $page )->status_is(200);
    }

    # logout
    $t->get_ok('/logout')->status_is(200);
    $t->get_ok('/account/home')->status_is(302);
    my $sid_new_session = _get_sid($t);
    isnt $sid_loged_in, $sid_new_session, 'right new sid';
};

done_testing();

sub _get_sid {
    my $t       = shift;
    my @cookies = $t->ua->cookie_jar->all;
    @cookies = @{ $cookies[0] } if ref $cookies[0] eq 'ARRAY';
    my ($sid_cookie) = grep { $_->name eq 'sid' } @cookies;
    return $sid_cookie->value if $sid_cookie;
    return 0;
}
