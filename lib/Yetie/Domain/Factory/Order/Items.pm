package Yetie::Domain::Factory::Order::Items;
use Mojo::Base 'Yetie::Domain::Factory';

sub cook {
    my $self = shift;

    $self->aggregate_collection( item_list => 'entity-order-item', $self->param('item_list') || [] );
}

1;
__END__

=head1 NAME

Yetie::Domain::Factory::Order::Items

=head1 SYNOPSIS

    my $entity = Yetie::Domain::Factory::Order::Items->new( %args )->create;

    # In controller
    my $entity = $c->factory('entity-order-items')->create(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Factory::Order::Items> inherits all attributes from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::Factory::Order::Items> inherits all methods from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Domain::Factory>
