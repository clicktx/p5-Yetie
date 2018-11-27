package Yetie::Domain::Entity::Address;
use Yetie::Domain::Base 'Yetie::Domain::Entity';
use Mojo::Util qw(encode);

my $attrs = [qw(country_code line1 line2 state city postal_code personal_name organization phone)];
has $attrs;
has hash => '';
has type => '';

has _locale_field_names => sub {
    {
        us => [qw(country_code personal_name organization line1 line2 city state postal_code phone)],
        jp => [qw(country_code personal_name organization postal_code state city line1 line2 phone)],
    };
};
has _locale_notation => sub {
    my $self = shift;

    my $country_name = {
        us => 'United States',
        jp => 'Japan',
    };
    my $country = $country_name->{ $self->country_code };

    # NOTE: templateでclass を追加できるようにしたい
    # Address::ViewFormat
    # $address->view('attr')  $address->attr
    # $address->view( \$scalar ) $scalar
    # $address->view( { class => [ 'attr1', 'attr2' ] } ) $address->attr1 . $address->attr2
    # <li class="<%=  %>"><%= $address->view($_) %></li>
    my $lines = {
        us => [
            qw(personal_name organization line2 line1),
            { main => [ 'city', \', ', 'state', \' ', 'postal_code' ] },
            qw(country_name phone)
        ],
        jp => [ qw(postal_code), [qw(state city line1)], qw(line2 organization personal_name country_name phone) ],
    };

    # use DDP;
    # p $lines->{us};

    return {
        us => [
            $self->personal_name, $self->organization, $self->line2, $self->line1,
            [ $self->city, ", ", $self->state, " ", $self->postal_code ],
            $country, $self->phone
        ],
        jp => [
            $self->postal_code,   $self->state . $self->city . $self->line1,
            $self->line2,         $self->organization,
            $self->personal_name, $country,
            $self->phone
        ],
    };
};

sub empty_hash_code { shift->hash_code('empty') }

sub equals {
    my ( $self, $address ) = @_;
    return $self->hash_code eq $address->hash_code ? 1 : 0;
}

sub field_names {
    my $self = shift;
    my $region = shift || 'us';
    $self->_locale_field_names->{$region} || $self->_locale_field_names->{us};
}

sub hash_code {
    my ( $self, $mode ) = ( shift, shift || '' );

    my $str = '';
    foreach my $attr ( @{$attrs} ) {
        my $value = $mode eq 'empty' ? '' : $self->$attr // '';
        $str .= '::' . encode( 'UTF-8', $value );
    }
    $str =~ s/\s//g;
    $self->SUPER::hash_code($str);
}

sub is_empty {
    my $self = shift;
    $self->hash_code eq $self->empty_hash_code ? 1 : 0;
}

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->hash( $self->hash_code );
    $self->is_modified(0);
    return $self;
}

sub notation {
    my $self = shift;

    my $country_code = $self->country_code;
    $self->_locale_notation->{$country_code} || $self->_locale_notation->{us};
}

sub to_data {
    my $self = shift;
    my $data = $self->SUPER::to_data;

    # Regenerate hash code
    $data->{hash} = $self->hash_code;
    return $data;
}

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Address

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Address> inherits all attributes from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<hash>

=head2 C<type>

=head1 METHODS

L<Yetie::Domain::Entity::Address> inherits all methods from L<Yetie::Domain::Entity> and implements
the following new ones.

=head2 C<empty_hash_code>

    my $hash_code = $address->empty_hash_code;

All data empty L</hash_code>.

=head2 C<equals>

    my $bool = $address->equals($other_address);

Compare L</hash_code>.

Return boolean value.

=head2 C<field_names>

Get form field names.

    my $field_names = $address->field_names($region);

    # Country Japan
    my $field_names = $address->field_names('jp');

Return Array reference.

Default region "us".

=head2 C<hash_code>

    my $hash_code = $address->hash_code;

Generate unique hash code from address information.

=head2 C<is_empty>

    my $bool = $address->is_empty;

Return boolean value.

=head2 C<new>

    my $address = Yetie::Domain::Entity->new( \%arg );

Generates a hash attribute at instance creation.

=head2 C<notation>

    my $notation = $address->notation;

Acquire notation method of address.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity>
