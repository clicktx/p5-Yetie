package Yetie::Service::Email;
use Mojo::Base 'Yetie::Service';

sub find_email {
    my ( $self, $email ) = @_;

    my $result = $self->resultset('Email')->find( { address => $email } );
    my $data = $result ? $result->to_data : { value => $email };
    return $self->factory('value-email')->construct($data);
}

1;
__END__

=head1 NAME

Yetie::Service::Email

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Service::Email> inherits all attributes from L<Yetie::Service> and implements
the following new ones.

=head1 METHODS

L<Yetie::Service::Email> inherits all methods from L<Yetie::Service> and implements
the following new ones.

=head2 C<find_email>

    my $domain_value = $service->find_email('foo@bar.baz');

Return L<Yetie::Domain::Value::Email> object.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Service>
