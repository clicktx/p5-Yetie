package Markets::Core;
use Mojo::Base 'Mojolicious';
use DBI;
use Markets::Util;
use Markets::DB::Schema;
use Markets::Session::Store::Teng;
use Markets::Hook::Filter;
use File::Spec;
use File::Basename;

my $all_addons;

BEGIN {
    # @INC for Addons
    my $base_dir =
      File::Spec->catdir( dirname(__FILE__), '..', '..', 'addons' );
    $all_addons = Markets::Util::directories('addons');
    foreach my $path (@$all_addons) {
        push @INC, File::Spec->catdir( $base_dir, $path, 'lib' );
    }
}

has config_file => sub {
    my $mode = shift->mode;
    return "${mode}.conf";
};
has util => sub { Markets::Util->new };
has dbh => sub {
    my $self = shift;
    my $conf = $self->config->{db} or die "Missing configuration for db";
    my $dsn  = $self->dsn($conf);
    my $dbh  = DBI->connect( $dsn, { RaiseError => 1 } ) or die $DBI::errstr;
    say "connecting DB."; 
    say '$app->dbh => ' . $dbh . 'on Markets.pm'; 
    return $dbh;
};
has db => sub {
    say "+++++ load schema. +++++"; 
    Markets::DB::Schema->load(
        dbh       => shift->dbh,
        namespace => 'Markets::DB',
    );
};
has filters => sub { Markets::Hook::Filter->new };

sub add_filter {
    my ( $self, $name, $code, $conf ) = ( shift, shift, shift, shift // {} );
    $conf->{client} = caller;
    $self->filters->add_filter( $name, $code, $conf );
}

sub dsn {
    my ( $self, $conf ) = @_;
    my $dsn;
    if ( $ENV{TEST_MYSQL} ) {
        $dsn = $ENV{TEST_MYSQL};
    }
    else {
        $dsn =
            "DBI:$conf->{dbtype}:dbname=$conf->{dbname};"
          . "host=$conf->{host};port=$conf->{port};"
          . "user=$conf->{user};password=$conf->{password};";
    }
    return $dsn;
}

sub initialize_app {
    my $self = shift;

    my $config_path =
      $self->app->home->rel_file( 'config/' . $self->config_file );
    $self->plugin( Config => { file       => $config_path } );
    $self->plugin( Model  => { namespaces => ['Markets::Model'] } );

    # constants
    my $constants = $self->model('data-constant')->load;
    $constants->{LINK_NAME} = 'リンク先';          # ex)
    $constants->{ROOT_URL}  = 'http://google.com/';    # ex)

    foreach my $name ( keys %$constants ) {
        $self->helper( $name => sub { $constants->{$name} } );
    }
    $self->helper( LINK_NAME => sub { '上書き' } );    #override ok

    # [WIP] app config
    my $enable_addons_setting_from_db = {
        'MyAddon' => {
            before_compile_template => 300,
            before_xxx_action       => 500,
        },
    };
    $self->config(
        addons => {
            all     => $all_addons,
            enable  => $enable_addons_setting_from_db,
        }
    );

    # session
    my $rs = $self->db->resultset('sessions');
    $self->plugin(
        'Markets::Session' => {
            stash_key => 'markets_session',
            store     => Markets::Session::Store::Teng->new( resultset => $rs ),
            expires_delta => 3600,
        }
    );

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # helper
    $self->helper( markets_session => sub { shift->stash('markets_session') } );
}

1;
