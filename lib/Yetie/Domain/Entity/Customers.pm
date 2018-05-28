package Yetie::Domain::Entity::Customers;
use Yetie::Domain::Base 'Yetie::Domain::Entity::Page';

has customer_list => sub { Yetie::Domain::Collection->new };

sub each { shift->customer_list->each(@_) }

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Customers

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Customers> inherits all attributes from L<Yetie::Domain::Entity::Page> and implements
the following new ones.

=head2 C<customer_list>

    my $collection = $customers->customer_list;

Return L<Yetie::Domain::Collection> object.

=head1 METHODS

L<Yetie::Domain::Entity::Customers> inherits all methods from L<Yetie::Domain::Entity::Page> and implements
the following new ones.

=head2 C<each>

    $customers->each(...);

    # Longer version
    $customers->customer_list->each(...);

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity::Page>, L<Yetie::Domain::Entity>
