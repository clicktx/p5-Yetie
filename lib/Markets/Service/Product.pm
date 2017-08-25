package Markets::Service::Product;
use Mojo::Base 'Markets::Service';

has resultset => sub { shift->schema->resultset('Product') };

sub create_entity {
    my ( $self, $product_id ) = @_;

    # Sort primary category is first
    my $data = $self->resultset->search(
        { 'me.id' => $product_id },
        {
            order_by => { -desc              => 'is_primary' },
            prefetch => { product_categories => 'detail' },
        }
    )->hashref_first;

    # Ancestors(Primary category path)
    my $primary_category = $data->{product_categories}->[0];
    my $ancestors        = [];
    if ($primary_category) {
        $ancestors = $self->schema->resultset('Category')->get_ancestors_arrayref( $primary_category->{category_id} );

        # Delete needless data
        my $detail = $primary_category->{detail};
        delete $detail->{$_} for qw(lft rgt);
        push @{$ancestors}, $detail;
    }
    $data->{ancestors} = $ancestors;

    return $self->app->factory('entity-product')->create($data);
}

sub duplicate_product {
    my ( $self, $product_id ) = @_;

    my $entity = $self->create_entity($product_id);
    my $title  = $entity->title . ' ' . $self->controller->__x_default_lang('copy');
    my $i      = $self->resultset->search( { title => { like => $title . '%' } } )->count + 1;
    $entity->title( $title . $i );

    my $data = $entity->to_data;
    delete $data->{ancestors};

    my $result = $self->resultset->create($data);

    # Logging
    $self->app->admin_log->info( 'Duplicate product from ID:' . $product_id ) if $result;

    return $result;
}

sub get_primary_category_choices {
    my ( $self, $entity ) = @_;

    my @categories;
    $entity->product_categories->each(
        sub {
            my $ancestors = $self->schema->resultset('Category')->get_ancestors_arrayref( $_->id );
            my $title;
            foreach my $ancestor ( @{$ancestors} ) { $title .= $ancestor->{title} . ' > ' }
            $title .= $_->title;
            push @categories, [ $title, $_->category_id, checked => $_->is_primary ];
        }
    );
    return wantarray ? @categories : \@categories;
}

sub new_product {
    my $self = shift;

    my $title = $self->controller->__x_default_lang('New Product');
    my $i = $self->resultset->search( { title => { like => $title . '%' } } )->count;
    $title .= $i + 1;

    return $self->resultset->create( { title => $title } );
}

sub remove_product {
    my ( $self, $product_id ) = @_;

    my $product = $self->resultset->find($product_id);
    if ($product) {
        my $result = $product->delete;

        # Logging
        $self->app->admin_log->info( 'Removed product ID:' . $product_id ) if $result;

        return $result;
    }
    return;
}

1;
__END__

=head1 NAME

Markets::Service::Product

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Service::Product> inherits all attributes from L<Markets::Service> and implements
the following new ones.

=head1 METHODS

L<Markets::Service::Product> inherits all methods from L<Markets::Service> and implements
the following new ones.

=head2 C<create_entity>

    my $product = $app->service('product')->create_entity($product_id);

Return L<Markets::Domain::Entity::Product> object.

=head2 C<duplicate_product>

    my $result = $service->duplicate_product($product_id);

Duplicate from C<$product_id>.

Return L<Markets::Schema::Result::Product> object.

=head2 C<get_primary_category_choices>

    my $product_categories = $service->get_primary_category_choices($entity);
    my @product_categories = $service->get_primary_category_choices($entity);

Argument: L<Markets::Domain::Entity::Product> object.

Return: Array ou Array refference.

=head2 C<new_product>

    my $result = $service->new_product();

Return L<Markets::Schema::Result::Product> object.

=head2 C<remove_product>

    my $result = $service->remove_product($product_id);

Return L<Markets::Schema::Result::Product> object or undefined.

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

L<Markets::Service>
