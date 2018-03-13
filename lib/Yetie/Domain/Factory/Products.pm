package Yetie::Domain::Factory::Products;
use Mojo::Base 'Yetie::Domain::Factory';

sub cook {
    my $self = shift;

    my $product_list = $self->param('product_list');
    $self->aggregate_collection( product_list => 'entity-product', $product_list || [] );
}

1;
__END__

=head1 NAME

Yetie::Domain::Factory::Products

=head1 SYNOPSIS

    my $entity = Yetie::Domain::Factory::Products->new( %args )->create;

    # In controller
    my $entity = $c->factory('entity-products')->create(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Factory::Products> inherits all attributes from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::Factory::Products> inherits all methods from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Domain::Factory>
