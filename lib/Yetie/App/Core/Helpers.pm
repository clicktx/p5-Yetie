package Yetie::App::Core::Helpers;
use Mojo::Base 'Mojolicious::Plugin';

use Carp                    ();
use Scalar::Util            ();
use Mojo::Util              ();
use Yetie::Util             ();
use Yetie::App::Core::Cache ();
use Yetie::Factory;

sub register {
    my ( $self, $app ) = @_;

    # Add attributes to App
    $app->attr( caches => sub { Yetie::App::Core::Cache->new } );

    # TagHelpers more
    $app->plugin('Yetie::App::Core::TagHelpers');

    $app->helper( __x_default_lang => sub { __x_default_lang(@_) } );
    $app->helper( addons           => sub { shift->app->addons(@_) } );
    $app->helper( cache            => sub { _cache(@_) } );
    $app->helper( cart             => sub { _cart(@_) } );
    $app->helper( continue_url     => sub { _continue_url(@_) } );
    $app->helper( cookie_session   => sub { shift->session(@_) } );
    $app->helper( date_time        => sub { shift->app->date_time(@_) } );
    $app->helper( factory          => sub { _factory(@_) } );
    $app->helper( is_admin_route   => sub { _is_admin_route(@_) } );
    $app->helper( is_get_request   => sub { _is_get_request(@_) } );
    $app->helper( is_logged_in     => sub { _is_logged_in(@_) } );
    $app->helper( j                => sub { _j(@_) } );
    $app->helper( pref             => sub { _pref(@_) } );
    $app->helper( prg_to           => sub { _prg_to(@_) } );
    $app->helper( 'reply.error'    => sub { _reply_error(@_) } );
    $app->helper( 'reply.message'  => sub { _reply_message(@_) } );
    $app->helper( resultset        => sub { shift->app->schema->resultset(@_) } );
    $app->helper( remote_address   => sub { _remote_address(@_) } );
    $app->helper( schema           => sub { shift->app->schema } );
    $app->helper( service          => sub { _service(@_) } );
    $app->helper( template         => sub { _template(@_) } );
    $app->helper( 'token.clear'    => sub { _token_clear(@_) } );
    $app->helper( 'token.get'      => sub { _token_get(@_) } );
    $app->helper( 'token.validate' => sub { _token_validate(@_) } );
}

sub __x_default_lang {
    my $c = shift;

    my $language = $c->language;
    $c->language( $c->pref('locale_language_code') );
    my $word = $c->__x(@_);
    $c->language($language);
    return $word;
}

sub _cache {
    my $c = shift;
    my ( $key, $value ) = @_;

    my $caches = $c->app->caches;
    return $caches if !$key;

    # Set cache
    my $is_cached = exists $caches->{cache}->{$key};
    if ($value) {
        $c->app->log->debug( q{Set new cache key:"} . $key . q{"} ) if !$is_cached;
        return $caches->set( $key => $value );
    }

    # Get cache
    $c->app->log->debug( q{Get cached data key:"} . $key . q{"} ) if $is_cached;
    return $caches->get($key);
}

sub _cart { return @_ > 1 ? $_[0]->stash( 'yetie.cart' => $_[1] ) : $_[0]->stash('yetie.cart') }

sub _continue_url {
    my ( $c, $arg ) = @_;

    # Set
    return $c->flash( continue_url => $arg ) if $arg;

    # Get
    my $default_continue_url = $c->is_admin_route ? 'rn.admin.dashboard' : 'rn.home';
    return $c->flash('continue_url') || $default_continue_url;
}

sub _factory {
    my $c = shift;

    my $factory = Yetie::Factory->new(@_);
    $factory->app( $c->app );
    return $factory;
}

sub _is_admin_route { return shift->isa('Yetie::Controller::Admin') ? 1 : 0 }

sub _is_get_request { return shift->req->method eq 'GET' ? 1 : 0 }

sub _is_logged_in {
    my $c = shift;

    my $method = $c->is_admin_route ? 'is_staff_logged_in' : 'is_customer_logged_in';
    return $c->server_session->$method ? 1 : 0;
}

sub _j { return Mojo::JSON::j( $_[1] ) }

sub _pref {
    my $c    = shift;
    my $pref = $c->cache('preferences');
    return @_ ? $pref->value(@_) : $pref;
}

sub _remote_address {
    my $c = shift;

    # NOTE: 'X-Real-IP', 'X-Forwarded-For'はどうする？
    my $remote_address = $c->tx->remote_address || 'unknown';
    return $remote_address;
}

sub _reply_error {
    my ( $c, %args ) = ( shift, @_ );

    my $status        = delete $args{status}        || '400';
    my $title         = delete $args{title}         || 'Bad Request';
    my $error_message = delete $args{error_message} || q{};

    # logging
    my %context = (
        method        => $c->req->method,
        url           => $c->req->url->to_string,
        title         => $c->__($title),
        error_message => $c->__($error_message),
    );
    $c->logging_error( 'reply.error', %context );

    my %options = (
        template      => 'error',
        status        => $status,
        title         => $title,
        error_message => $error_message,
    );
    return $c->render( %options, %args );
}

sub _prg_to {
    my ( $c, @args ) = ( shift, @_ );

    $c->res->code(303);
    return $c->redirect_to(@args);
}

sub _reply_message {
    my $c = shift;

    my %options = (
        status   => 200,
        template => 'message',
        title    => '',
        message  => '',
    );
    return $c->render( %options, @_ );
}

sub _service {
    my ( $c, $ns ) = ( shift, shift );

    $ns = Mojo::Util::camelize($ns) if $ns =~ /^[a-z]/;
    Carp::croak 'Service name is empty.' unless $ns;

    my $class = "Yetie::Service::" . $ns;
    Yetie::Util::load_class($class);
    return $class->new( $c, @_ );
}

sub _template {
    my $c = shift;
    return @_ ? $c->stash( template => shift ) : $c->stash('template');
}

sub _token_clear {
    my $c = shift;

    my $session = $c->server_session;
    $session->clear('token');
    $session->flush;
    return;
}

sub _token_get {
    my $c = shift;

    my $session = $c->server_session;
    my $token   = $session->data('token');
    return $token if $token;

    # Create new token
    $token = Yetie::Util::create_token();
    $session->data( token => $token );
    $session->flush;
    return $token;
}

sub _token_validate {
    my $c = shift;

    my $target_token = shift || $c->param('token');
    return $c->token->get eq $target_token ? 1 : 0;
}

1;
__END__

=head1 NAME

Yetie::App::Core::Helpers - Default helpers plugin for Yetie

=head1 DESCRIPTION

=head1 HELPERS

L<Yetie::App::Core::Helpers> implements the following helpers.

=head2 C<__x_default_lang>

    my $translation = $c->__x_default_lang($word);

Word translation using L<Mojolicious::Plugin::LocaleTextDomainOO/__x> in the default language.

The default language uses C<locale_language_code> preference.

=head2 C<addons>

    my $addons = $c->addons;

Alias for $app->addons;

=head2 C<cache>

    my $cache = $c->cache;

Return L<Yetie::App::Core::Cache> object.

    # Get cache
        my $foo = $c->cache('foo');

        # Longer version
        my $foo = $c->cache->get('foo');

    # Set cache
        $c->cache( foo => 'bar' );

        # Longer version
        $c->cache->set( foo => 'bar' );

    # Clear all caches
    $c->cache->clear_all;

SEE L<Yetie::App::Core::Cache>

=head2 C<cart>

    my $cart = $c->cart;
    $c->cart($cart);

=head2 C<continue_url>

    my $continue_url = $c->continue_url;
    my $c->continue_url('foo');

    # Longer version
    my $continue_url = $c->flash('continue_url');
    $c->flash( continue_url => 'foo' );

Get/Set to flash data with keyword "continue_url".

Default url: C<rn.admin.dashboard> or C<rn.home>

=head2 C<cookie_session>

    $c->cookie_session( key => 'value' );
    my $value = $c->cookie_session('key');

Alias for $c->session;

=head2 C<date_time>

    my $date_time = $c->date_time;

    # Longer version
    $c->app->date_time;

Alias for $app->date_time;

=head2 C<factory>

    my $factory = $c->factory('entity-something');

Return L<Yetie::Factory> Object.

=head2 C<is_get_request>

    my $bool = $c->is_get_request;

Return boolean value.

=head2 C<is_logged_in>

    my $bool = $c->is_logged_in;
    if ($bool){ say "Logged in" }
    else { say "Not logged in" }

Return boolean value.

=head2 C<j>

    # { "foo":"bar" }
    $c->j( { foo => "bar" } );

    # in template
    <%== j { a => 1}  >

See L<Mojo::JSON/j>

=head2 C<resultset>

    my $resultset = $c->resultset('Foo::Bar');
    my $resultset = $c->resultset('foo-bar');

Return L<Yetie::Schema::ResultSet> object.

=head2 C<pref>

    # Get preference entity
    my $entity_preference = $c->pref;

    # Getter
    my $hoge = $c->pref('hoge');

    # Setter
    $c->pref( hoge => 'fizz', fuga => 'bazz' );

Get/Set preference.

=head2 C<prg_to>

    $c = $c->prg_to('named', foo => 'bar');
    $c = $c->prg_to('named', {foo => 'bar'});
    $c = $c->prg_to('/index.html');
    $c = $c->prg_to('http://example.com/index.html');

    # Longer version
    $c->res->code(303);
    $c->redirect_to('some_route');

Post/Redirect/Get(PRG)

Prepare a 303 redirect response with Location header,
takes the same arguments as L<Mojolicious::Plugin::Helpers/redirect_to>.

=head2 C<reply-E<gt>error>

    $c->reply->error( status => 401, title => 'foo', error_message => 'bar' );

Render the error template.

Default status code C<400>.

=head2 C<reply-E<gt>message>

    $c->reply->message( title => 'foo', message => 'bar' );

Render the message template.

Default status code C<200>.

=head2 C<schema>

    my $schema = $c->schema;

Return L<Yetie::Schema> object.

=head2 C<service>

    # Your service
    package Yetie::Service::Cart;

    sub calculate {
        my $self = shift;
        my $c = $self->controller;
        ...
    }

    # Your controller
    $c->service('cart')->calculate(...);
    $c->helpers->service('cart')->calculate(...);


Service Layer accessor.

=head2 C<template>

    my $template = $c->template;
    $c->template('hoge/index');

Get/Set template.

Alias for $c->stash(template => 'hoge/index');

=head2 C<token-E<gt>clear>

    $c->token->clear;

Delete token from data("token") in L<Yetie::App::Core::Session::ServerSession>.

=head2 C<token-E<gt>get>

    my $token = $c->token->get;

Get token from data("token") in L<Yetie::App::Core::Session::ServerSession>, and generate one if none exists.

token are L<Yetie::Util/create_token>.

=head2 C<token-E<gt>validate>

    my $bool = $c->token->validate;
    my $bool = $c->token->validate('foobar');

    if ($bool) { say 'Succeed' }
    else { say 'Failed' }

Validate token.

Default target token C<app-E<gt>controller-E<gt>param('token')>

Return boolean value.

=head1 AUTHOR

Yetie authors.
