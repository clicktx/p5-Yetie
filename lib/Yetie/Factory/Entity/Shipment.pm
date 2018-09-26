package Yetie::Factory::Entity::Shipment;
use Mojo::Base 'Yetie::Factory';

sub cook {
    my $self = shift;

    # Aggregate items
    $self->aggregate( items => ( 'list-cart_items', $self->param('items') || [] ) );

    # shipping_address
    $self->aggregate( shipping_address => ( 'entity-address', $self->{shipping_address} || {} ) );
}

1;
__END__

=head1 NAME

Yetie::Factory::Entity::Shipment

=head1 SYNOPSIS

    my $entity = Yetie::Factory::Entity::Shipment->new( %args )->construct();

    # In controller
    my $entity = $c->factory('entity-shipment')->construct(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Factory::Entity::Shipment> inherits all attributes from L<Yetie::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Factory::Entity::Shipment> inherits all methods from L<Yetie::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Factory>