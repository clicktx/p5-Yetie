package Yetie::Domain::Value::Price;
use MooseX::Types::Common::Numeric qw/PositiveOrZeroNum/;
use Math::Currency;
use Carp qw(croak);

use Moose;
use overload
  '""'     => sub { $_[0]->amount },
  '+'      => \&add,
  fallback => 1;
extends 'Yetie::Domain::Value';

with 'Yetie::Domain::Role::Types';

has '+value' => (
    isa     => PositiveOrZeroNum,
    default => 0,
);
has currency_code => (
    is      => 'ro',
    isa     => 'CurrencyCode',
    default => 'USD',
);
has is_tax_included => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

sub add {
    my $self = shift;
    my $num = shift || 0;

    croak 'unable to perform arithmetic on different currency types' if ref $num && ref $num ne __PACKAGE__;
    return $self->clone( value => $self->amount->copy->badd($num)->as_float );
}

sub amount {
    my $self = shift;
    return Math::Currency->new( $self->value, $self->currency_code );
}

sub to_data {
    my $self = shift;

    return {
        value           => $self->value,
        currency_code   => $self->currency_code,
        is_tax_included => $self->is_tax_included,
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Yetie::Domain::Value::Price

=head1 SYNOPSIS

=head1 DESCRIPTION

    my $price = Yetie::Domain::Value::Price->new( value => 100, currency_code => 'USD', is_tax_included => 0 );

    # Overloading, returns new instance
    my $p2 = $price + 1;

    # Objects work too
    my $p7 = $price + $price;

=head1 ATTRIBUTES

L<Yetie::Domain::Value::Price> inherits all attributes from L<Yetie::Domain::Value> and implements
the following new ones.

=head2 C<currency_code>

Default "USD"

=head2 C<value>

PositiveNum only.

=head2 C<is_tax_included>

Return boolean value.

Default false.

=head1 METHODS

L<Yetie::Domain::Value::Price> inherits all methods from L<Yetie::Domain::Value> and implements
the following new ones.

=head2 C<add>

    my $price2 = $price->add(1);
    my $price3 = $price->add($price);

=head2 C<amount>

Return L<Math::Currency> object.

=head1 OPERATOR

L<Yetie::Domain::Value::Price> overloads the following operators.

=head2 C<stringify>

    my $amount = "$price";

Alias for L</amount>.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Value>
