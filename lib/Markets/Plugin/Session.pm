package Markets::Plugin::Session;
use Mojo::Base 'Mojolicious::Plugin';
use MojoX::Session;

sub register {
    my ( $self, $app, $args ) = @_;

    $args ||= {};

    my $stash_key = delete $args->{stash_key} || 'mojox-session';
    my $init = delete $args->{init};

    $app->hook(
        before_routes => sub {
            my $c = shift;
            say "hook! before_routes from plugin session";    # debug
            return if $c->stash->{'mojo.static'};

            my $session = MojoX::Session->new(%$args);
            $session->tx( $c->tx );
            $init->( $c, $session ) if $init;
            $c->stash( $stash_key => $session );

            $session->load;
            if ( $session->sid ) {
                say "   ... ented session expires time.";     # debug
                $session->extend_expires;
            }
            else {
                _create_session( $c, $session );
            }
            say "   ... sid: " . $session->sid;               # debug
        }
    );
    $app->hook(
        after_dispatch => sub {
            my $c = shift;

            say "hook! after_dispatch from plugin session";    # debug
            return if $c->stash->{'mojo.static'};

            say "   ... session flush";                        # debug
            $c->stash($stash_key)->flush;
        }
    );
}

sub _create_session {
    my ( $c, $session ) = @_;
    my $cookie = $c->cookie('landing_page');

    # cookieに対応している場合のみセッション生成する
    # cookieが無いときはlanding pageのurlを保存
    if ($cookie) {
        say "created new session.";                            # debug
        $session->data( 'landing_page' => $cookie );
        $session->create;
    }
    else {
        my $landing_page = $c->req->url->to_string;
        $c->cookie( 'landing_page' => $landing_page );
    }
}

1;
__END__

=head1 NAME

Markets::Plugin::Session - forked from Mojolicious::Plugin::Session

=head1 SYNOPSIS

    # Mojolicious::Lite
    plugin session =>
      {stash_key => 'mojox-session', store => 'dbi', expires_delta => 5};

    # Mojolicious
    $self->plugin(
        session => {
            stash_key     => 'mojox-session',
            store         => 'dbi',
            expires_delta => 5
        }
    );

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 C<stash_key>

    MojoX::Session instance will be saved in stash using this key.

=head1 SEE ALSO

L<Mojolicious::Plugin::Session>

L<MojoX::Session>

L<Mojolicious>

=cut



1;
