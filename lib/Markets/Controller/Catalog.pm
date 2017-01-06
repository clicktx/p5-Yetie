package Markets::Controller::Catalog;
use Mojo::Base 'Markets::Controller';

sub is_logged_in {
    my $self = shift;
    $self->db_session->data('customer_id') ? 1 : 0;
}

1;
__END__

=head1 NAME

Markets::Controller::Catalog - Controller base class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Controller::Catalog> inherits all attributes from L<Markets::Controller> and
implements the following new ones.

=head1 METHODS

L<Markets::Controller::Catalog> inherits all methods from L<Markets::Controller> and
implements the following new ones.

=head2 is_logged_in

=head1 SEE ALSO

L<Markets::Controller>

L<Mojolicious::Controller>

L<Mojolicious>

=cut