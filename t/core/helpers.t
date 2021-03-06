use Mojolicious::Lite;
plugin 'Yetie::App::Core::Helpers';

any '/continue_none' => sub {
    my $c = shift;
    return $c->redirect_to('/continue_redirect');
};
any '/continue_foobar' => sub {
    my $c = shift;
    $c->continue_url('foobar');
    return $c->redirect_to('/continue_redirect');
};
any '/continue_redirect' => sub {
    my $c = shift;
    return $c->render( json => { continue_url => $c->continue_url } );
};

any '/req' => sub {
    my $c = shift;
    return $c->render( json => { req => $c->is_get_request } );
};

any '/prg' => sub {
    my $c = shift;
    return $c->prg_to('/');
};

use t::Util;
use Test::More;
use Test::Mojo;

subtest 'continue_url' => sub {
    my $t = Test::Mojo->new;
    $t->ua->max_redirects(1);
    $t->get_ok('/continue_none')->json_is( { continue_url => 'rn.home' } );
    $t->get_ok('/continue_foobar')->json_is( { continue_url => 'foobar' } );
};

subtest 'is_get_request' => sub {
    my $t = Test::Mojo->new;
    $t->get_ok('/req')->json_is( { req => 1 } );
    $t->post_ok('/req')->json_is( { req => 0 } );
};

subtest 'prg_to' => sub {
    my $t = Test::Mojo->new;
    $t->get_ok('/prg')->status_is(303);
    $t->post_ok('/prg')->status_is(303);
};

#########################################
# Use App tests
#########################################
subtest 'cache' => sub {
    my $t = Test::Mojo->new('App');
    my $c = $t->app->build_controller;

    isa_ok $c->cache, 'Mojo::Cache';
    is $c->cache('foo'), undef, 'right no cache';

    $c->cache( 'foo' => 1 );
    is $c->cache('foo'), 1, 'right add cache';

    $c->cache( 'foo' => 5 );
    is $c->cache('foo'), 5, 'right replace cache';

    $c->cache( 'bar' => 7 );
    is $c->cache('bar'), 7, 'right other cache';
};

subtest 'is_admin_route' => sub {
    my $t = Test::Mojo->new('App');
    my $r = $t->app->routes->namespaces( ['Yetie::Controller'] );
    $r->get('/customer_route')->to('customer#route');
    $r->get('/staff_route')->to('staff#route');

    $t->get_ok('/customer_route')->json_is( { route => 0 } );
    $t->get_ok('/staff_route')->json_is( { route => 1 } );
};

subtest 'is_logged_in' => sub {
    my $t = Test::Mojo->new('App');
    my $r = $t->app->routes->namespaces( ['Yetie::Controller'] );
    $r->get('/customer_loggedin')->to('customer#loggedin');
    $r->get('/staff_loggedin')->to('staff#loggedin');

    $t->get_ok('/customer_loggedin')->json_is( { is_logged_in => 0 } );
    $t->get_ok('/staff_loggedin')->json_is( { is_logged_in => 0 } );
};

subtest 'token' => sub {
    my $t = Test::Mojo->new('App');
    my $r = $t->app->routes->namespaces( ['Yetie::Controller'] );
    $r->get('/token/:action')->to('token#');

    $t->get_ok('/token/get')->status_is(200);
    $t->get_ok('/token/validate')->status_is(200);
    $t->get_ok('/token/clear')->status_is(200);
};

done_testing();

# controllers
package Yetie::Controller::Customer;
use Mojo::Base 'Yetie::Controller::Catalog';

sub loggedin {
    my $c = shift;
    return $c->render( json => { is_logged_in => $c->is_logged_in } );
}

sub route {
    my $c = shift;
    return $c->render( json => { route => $c->is_admin_route } );
}

package Yetie::Controller::Staff;
use Mojo::Base 'Yetie::Controller::Admin';

sub loggedin {
    my $c = shift;
    return $c->render( json => { is_logged_in => $c->is_logged_in } );
}

sub route {
    my $c = shift;
    return $c->render( json => { route => $c->is_admin_route } );
}

package Yetie::Controller::Token;
use Mojo::Base 'Yetie::Controller::Catalog';
use Test::More;

sub get {
    my $c = shift;

    my $token = $c->token->get;
    ok $token, 'right get token';
    is $token, $c->token->get, 'right equal token';
    is $c->server_session->data('token'), $token, 'right store token for session';
    return $c->render( json => {} );
}

sub validate {
    my $c = shift;

    my $token = $c->token->get;
    $c->param( token => $token );
    my $bool = $c->token->validate;
    ok $bool, 'right success token';

    $c->param( token => 'foo' );
    $bool = $c->token->validate;
    ok !$bool, 'right faile token';

    $c->param( token => '' );
    ok $c->token->validate($token), 'right success token(argument)';
    ok !$c->token->validate('foo'), 'right faile token(argument)';

    return $c->render( json => {} );
}

sub clear {
    my $c = shift;

    $c->token->clear;
    ok !$c->server_session->data('token'), 'right delete token for session';
    return $c->render( json => {} );
}

__END__
