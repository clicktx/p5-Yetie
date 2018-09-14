package Yetie::Domain::List::Shipments;
use Yetie::Domain::Base 'Yetie::Domain::List';

sub total_item_size {
    shift->list->map( sub { $_->items->each } )->size;
}

1;
__END__

=head1 NAME

Yetie::Domain::List::Shipments

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::List::Shipments> inherits all attributes from L<Yetie::Domain::List> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::List::Shipments> inherits all methods from L<Yetie::Domain::List> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity::Item>, L<Yetie::Domain::List>
