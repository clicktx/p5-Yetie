package t::pages::admin::product;

use Mojo::Base 't::pages::common';
use t::Util;
use Test::More;
use Test::Mojo;

sub t01_not_logedin_request : Tests() {
    my $self   = shift;
    my $t      = $self->t;
    my $routes = $self->app->routes->find('RN_admin_product')->children;

    $t->ua->max_redirects(0);

    my $data = { csrf_token => $self->csrf_token };
    foreach my $route ( @{$routes} ) {
        my $path = $self->make_path( $route, { product_id => 1 } );
        say $path;

        if ( $route->via ) {
            foreach my $method ( @{ $route->via } ) {

                # GET
                $t->get_ok($path)->status_is( 302, 'right redirect on ' . $path ) if $method eq 'GET';

                # POST
                $t->post_ok( $path, form => $data )->status_is( 302, 'right redirect on ' . $path )
                  if $method eq 'POST';
            }
        }
        else {
            # ANY
            $t->get_ok($path)->status_is( 302, 'right redirect on ' . $path );
            $t->post_ok( $path, form => $data )->status_is( 302, 'right redirect on ' . $path );
        }
    }

    $t->ua->max_redirects(1);
}

sub t02_login : Tests() { shift->admin_loged_in }

sub t03_request : Tests() {
    my $self      = shift;
    my $t         = $self->t;
    my $post_data = { csrf_token => $self->csrf_token };

    # index
    $t->get_ok('/admin/product/999')->status_is(404);

    # create
    $t->get_ok('/admin/product/create')->status_is(404);
    $t->post_ok( '/admin/product/create', form => $post_data )->status_is(200);

    # duplicate
    $t->get_ok('/admin/product/1/duplicate')->status_is(404);
    $t->post_ok( '/admin/product/1/duplicate',   form => $post_data )->status_is(200);
    $t->post_ok( '/admin/product/999/duplicate', form => $post_data )->status_is(404);

    # edit
    $t->get_ok('/admin/product/1/edit')->status_is(200);
    $t->get_ok('/admin/product/999/edit')->status_is(404);
    $t->post_ok( '/admin/product/1/edit',   form => $post_data )->status_is(200);
    $t->post_ok( '/admin/product/999/edit', form => $post_data )->status_is(404);

    # edit category
    $t->get_ok('/admin/product/1/edit/category')->status_is(200);
    $t->get_ok('/admin/product/999/edit/category')->status_is(404);
    $t->post_ok( '/admin/product/1/edit/category',   form => $post_data )->status_is(200);
    $t->post_ok( '/admin/product/999/edit/category', form => $post_data )->status_is(404);

    # delete
    $t->get_ok('/admin/product/3/delete')->status_is(404);
    $t->post_ok( '/admin/product/3/delete',   form => $post_data )->status_is(200);
    $t->post_ok( '/admin/product/999/delete', form => $post_data )->status_is(404);
}

__PACKAGE__->runtests;
