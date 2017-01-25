package Markets::Model::Data::Addon;
use Mojo::Base 'MojoX::Model';

sub configure {
    my $self = shift;
    my $db   = $self->app->db;

    my @rows = $db->search_by_sql(
        q{
            SELECT addons.id, addons.name, addons.is_enabled, GROUP_CONCAT(addons_hooks.hook_name) AS hooks , GROUP_CONCAT(addons_hooks.priority) AS priorities
            FROM addons
            LEFT JOIN addons_hooks on addons.id = addons_hooks.addon_id
            GROUP BY addons.id
        },
    );
    my $result = {};
    foreach my $row (@rows) {
        my $data = $row->get_columns;
        $result->{ $data->{name} } = {
            is_enabled => $data->{is_enabled},
            hooks      => [],
        };

        if ( $data->{hooks} ) {
            my @hooks      = split( /,/, $data->{hooks} );
            my @priorities = split( /,/, $data->{priorities} );
            foreach ( my $i = 0 ; $i < @hooks ; $i++ ) {
                $result->{ $data->{name} }->{config}->{hook_priorities}
                  ->{ $hooks[$i] } = $priorities[$i];
            }
        }
    }
    return $result;
}

1;

__END__

=head1 NAME

Markets::Model::Data::Addon

=head1 SYNOPSIS

App Controller.
Snake case or Package name.

    package Markets::Controller::Catalog::Example;
    use Mojo::Base 'Markets::Controller::Catalog';

    sub example {
        my $self = shift;

        my $data = $self->model('data-addon')->method;
        # or
        my $data = $self->model('Data::Addon')->method;
    }

=head1 DESCRIPTION

=head1 METHODS

=head2 configure

    # Loading indtalled Addons
    my $addon_config = $app->model('data-addon')->configure;

load addon preferences from DB.

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

L<Mojolicious::Plugin::Model> L<MojoX::Model>
