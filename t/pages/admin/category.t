package t::pages::admin::category;

use Mojo::Base 't::pages::common';
use t::Util;
use Test::More;
use Test::Mojo;

sub t00_login : Tests() { shift->admin_loged_in }

sub t01_index : Tests() {
    my $self = shift;
    my $t    = $self->t;

    $t->get_ok('/admin/category')->status_is(200);

    my $post_data = {
        csrf_token => $self->csrf_token,
        title      => 'foo',
        parent_id  => undef,
    };
    $t->post_ok( '/admin/category', form => $post_data )->status_is( 200, 'right create new category' );
    $t->post_ok( '/admin/category', form => $post_data )->status_is( 409, 'right title same name exists' );
}

__PACKAGE__->runtests;