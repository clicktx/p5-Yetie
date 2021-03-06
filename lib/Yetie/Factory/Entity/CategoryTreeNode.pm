package Yetie::Factory::Entity::CategoryTreeNode;
use Mojo::Base 'Yetie::Factory';

sub cook {
    my $self = shift;

    $self->aggregate( ancestors => 'list-category_trees', $self->param('ancestors') || [] );
    $self->aggregate( children  => 'list-category_trees', $self->param('children')  || [] );
}

1;
__END__

=head1 NAME

Yetie::Factory::Entity::CategoryTreeNode

=head1 SYNOPSIS

    my $entity = Yetie::Factory::Entity::CategoryTreeNode->new( %args )->construct();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Factory::Entity::CategoryTreeNode> inherits all attributes from L<Yetie::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Factory::Entity::CategoryTreeNode> inherits all methods from L<Yetie::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Factory>
