use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;
use Scalar::Util ();

my $t   = Test::Mojo->new('App');
my $app = $t->app;

# routes
my $r = $app->routes->namespaces( ['Yetie::Controller'] );
$r->get('/good')->to('test#good');
$r->get('/not_found')->to('test#not_found');
$r->get('/buged')->to('test#buged');
$r->get('/construct')->to('test#construct');
$r->get('/methods')->to('test#methods');

subtest 'Service Layer basic' => sub {
    $t->get_ok('/good')->json_is(
        {
            service    => "Yetie::Service::Test",
            app        => "App",
            controller => "Yetie::Controller::Test",
            is_weak    => 1,
        }
    );
    $t->get_ok('/good')->json_is(
        {
            service    => "Yetie::Service::Test",
            app        => "App",
            controller => "Yetie::Controller::Test",
            is_weak    => 1,
        }
    );
    $t->get_ok('/not_found')->status_is(500);
    $t->get_ok('/buged')->status_is(500);
    $t->get_ok('/construct')->status_is(200);
    $t->get_ok('/methods')->status_is(200);
};

done_testing();

package Yetie::Controller::Test;
use Mojo::Base 'Yetie::Controller::Catalog';
use Test::More;

sub good {
    my $c       = shift;
    my $service = $c->service('test');
    my $is_weak = Scalar::Util::isweak $service->{controller} ? 1 : 0;

    return $c->render(
        json => {
            service    => ref $service,
            app        => ref $service->app,
            controller => ref $service->controller,
            is_weak    => $is_weak,
        }
    );
}

sub not_found {
    my $c       = shift;
    my $service = $c->service('test-not-fonnd');
}

sub buged {
    my $c       = shift;
    my $service = $c->service('buged');
}

sub construct {
    my $c = shift;
    my $service = $c->service( 'test', baz => 1, qux => 2 );
    isa_ok $service, 'Yetie::Service';

    is $service->baz, 1, 'right attribute accesser';
    is $service->{qux}, 2, 'right attribute';

    return $c->render( json => {} );
}

sub methods {
    my $c       = shift;
    my $service = $c->service('test');

    isa_ok $service->schema, 'Yetie::Schema';
    can_ok $service, 'c';
    can_ok $service, 'factory';
    can_ok $service, 'pref';
    can_ok $service, 'resultset';
    can_ok $service, 'service';
    can_ok $service, 'schema';
    isa_ok $service->service('test')->controller->server_session, 'Yetie::App::Core::Session::ServerSession';

    return $c->render( json => {} );
}
