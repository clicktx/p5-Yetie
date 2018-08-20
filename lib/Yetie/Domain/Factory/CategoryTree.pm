package Yetie::Domain::Factory::CategoryTree;
use Mojo::Base 'Yetie::Domain::Factory';

sub cook {
    my $self = shift;

    # children
    $self->aggregate_collection( children => 'entity-category_tree', $self->{children} );
}

1;
__END__

=head1 NAME

Yetie::Domain::Factory::CategoryTree

=head1 SYNOPSIS

    my $entity = Yetie::Domain::Factory::CategoryTree->new( %args )->create;

    # In controller
    my $entity = $c->factory('entity-category_tree')->create(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Factory::CategoryTree> inherits all attributes from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::Factory::CategoryTree> inherits all methods from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Domain::Factory>