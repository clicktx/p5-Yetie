package MyAddon;
use Mojo::Base 'Mojolicious::Plugin';

use Data::Dumper;

sub register {
    my ( $self, $app ) = @_;

    $app->helper( my_addon => sub { "MyAddon, Say!" } );

    # use prefilter_transform
    $app->add_filter(
        prefilter_transform => sub {
            my ( $c, $path, $template ) = @_;
            # say $c, $path, $template;
        },
        # option
        {
            priority => 300,      #default 100
            config   => 'aaa',
        }
    );
    $app->add_filter(
        prefilter_transform => sub {
            my ( $c, $path, $template ) = @_;
            # say $c, $path, $template;
        },
        # option
        {
            priority => 10,      #default 100
            config   => 'aaa',
        }
    );

    $app->add_filter(
        prefilter_transform => sub {
            my ( $c, $path, $template ) = @_;
            say "prefilter_transform.";

            if ( $path =~ m|admin/index/welcome| ) {
                say "template is admin/index/welcome +++++++++++++++";

                # say "------------ orig";
                # say ${$template};
                # say "------------ orig";

                # helper $app->dom
                my $dom = $c->app->dom->parse( ${$template} );

                # say "start ================================>  Markets::DOM";
                # say $dom;
                # say "end <================================  Markets::DOM";
                # say Dumper $dom;

                # say Dumper $dom;
                $dom->find('h2')
                  ->first->replace('<h2>MyAddon Mojolicious</h2>');
                $dom->find('h1')
                  ->first->replace('<h1>Admin mode from MyAddon</h1>');
                my $h2 = $dom->at('#admin-front')->content;
                $dom->at('#admin-front')->content( $h2 . ' / add text' );

                ${$template} = $dom;

            }

            # elsif ( $mt->{name} =~ m|layouts/default| ) {
            #     say "template id default/layouts/default";
            # } else {
            #     say "don't match";
            #     say $mt->{name};
            # }
        }
    );

    # after_render はhtml生成後に実行されるので毎回処理が走る
  # $app->hook(
  #     after_render => sub {
  #         my ( $c, $output, $format ) = @_;
  #
  #         # say $c->dumper( $c->tx );
  #
  #         say 'route: ' . $c->stash('controller') . '#' . $c->stash('action');
  #
  #         my $dom = Mojo::DOM->new( ${$output} );
  #         $dom->find('h2')->first->replace('<h2>MyAddon Mojolicious</h2>');
  #         my $h2 = $dom->at('#admin-front')->text;
  #         $dom->at('#admin-front')->content( $h2 . 'boo' );
  #         ${$output} = $dom;
  #     }
  # );
}

1;