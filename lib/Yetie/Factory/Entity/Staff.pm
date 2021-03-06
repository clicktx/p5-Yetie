package Yetie::Factory::Entity::Staff;
use Mojo::Base 'Yetie::Factory';

sub cook {
    my $self = shift;

    # password
    $self->aggregate( password => 'value-password', $self->{password} );
}

1;
__END__

=head1 NAME

Yetie::Factory::Entity::Staff

=head1 SYNOPSIS

    my $entity = Yetie::Factory::Entity::Staff->new( %args )->construct();

    # In controller
    my $entity = $c->factory('entity-staff')->construct(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Factory::Entity::Staff> inherits all attributes from L<Yetie::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Factory::Entity::Staff> inherits all methods from L<Yetie::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Factory>
