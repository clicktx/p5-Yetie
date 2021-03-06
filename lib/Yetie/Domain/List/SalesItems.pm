package Yetie::Domain::List::SalesItems;
use Moose;
use namespace::autoclean;
extends 'Yetie::Domain::List::CartItems';

has '+_item_isa' => ( default => 'Yetie::Domain::Entity::SalesItem' );

sub to_order_data {
    return shift->reduce( sub { [ @{$a}, $b->to_order_data ], }, [] );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Yetie::Domain::List::SalesItems

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::List::SalesItems> inherits all attributes from L<Yetie::Domain::List::LineItems> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::List::SalesItems> inherits all methods from L<Yetie::Domain::List::LineItems> and implements
the following new ones.

=head2 C<to_order_data>

    my $order_data = $list->to_order_data;

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::List::LineItems>, L<Yetie::Domain::Entity::Item>, L<Yetie::Domain::List>
