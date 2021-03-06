package Yetie::Schema;
use Mojo::Base 'DBIx::Class::Schema';
use version; our $VERSION = version->declare('v0.0.1');

use Carp qw/croak/;
use Try::Tiny;
use Mojo::Util 'camelize';
use Data::Page::Navigation;
use DBIx::Sunny;
use Yetie::App::Core::DateTime;

our $TZ = Yetie::App::Core::DateTime->TZ;

has 'app';

__PACKAGE__->load_namespaces( default_resultset_class => 'ResultSet' );

sub connect {
    my ( $self, $dsn, $user, $password, $dbi_attributes, $extra_attributes ) = @_;

    $dbi_attributes->{RootClass}            = 'DBIx::Sunny';
    $dbi_attributes->{mysql_enable_utf8mb4} = 1;
    $dbi_attributes->{on_connect_do}        = q{SET NAMES utf8mb4};

    my @connect_info = ( $dsn, $user, $password, $dbi_attributes, $extra_attributes );
    return $self->SUPER::connect(@connect_info);
}

# This code is DBIx::Class::Schema::resultset
sub resultset {
    my ( $self, $source_name ) = @_;
    $self->throw_exception('resultset() expects a source name')
      unless defined $source_name;

    # Yetie uses a snake case.
    $source_name = camelize($source_name);
    return $self->source($source_name)->resultset;
}

sub sequence {
    my ( $self, $name ) = ( shift, camelize(shift) );
    warn '!!DEPRECATED method';

    my $rs = $self->resultset( $name . '::Sequence' );
    $rs->search->update( { id => \'LAST_INSERT_ID(id + 1)' } );
    $self->storage->last_insert_id;
}

sub txn_failed {
    my ( $self, $err ) = @_;

    if ( $err =~ /Rollback failed/ ) {

        # ロールバックに失敗した場合
        my $msgid = 'schema.rollback.failed';
        $self->app->logging('db')->fatal( $msgid, error => $err );
        $self->app->logging('error')->fatal( $msgid, error => $err );
        croak $err;
    }
    else {
        # 何らかのエラーによりロールバックした
        my $msgid = 'schema.do.rollback';
        $self->app->logging('db')->fatal( $msgid, error => $err );
        $self->app->logging('error')->fatal( $msgid, error => $err );
        croak $err;
    }
}

sub txn {
    my ( $self, $cb ) = @_;

    return try { $self->txn_do($cb) }
    catch { $self->txn_failed($_) };
}

sub TZ { return $TZ }

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema

=head1 SYNOPSIS

    # Change time zone
    use Yetie::Schema;
    $Yetie::Schema::TIME_ZONE = 'Asia/Tokyo';

=head1 DESCRIPTION

=head1 METHODS

L<Yetie::Schema> inherits all methods from L<DBIx::Class::Schema>.

=head2 C<connect>

    my $schema = Yetie::Schema->connect( $dsn, $user, $password );

=head2 C<resultset>

    $schema->resultset($source_name);

    # Snake case can also be used!
    $schema->resultset('foo');      # Yetie::Schema::ResultSet::Foo
    $schema->resultset('bar-buz');  # Yetie::Schema::ResultSet::Bar::Buz

This method is alias for L<DBIx::Class::Schema/resultset>.
But you can use the snake case for C<$source_name>.

=head2 C<sequence>

DEPRECATED

=head2 C<txn_failed>

    use Try::Tiny;
    ...
    try {
        $schema->txn_do($cb);
    } catch {
        $schema->txn_failed($_);
    };
    ...

Logging transaction error.

=head2 C<txn>

    my $result = $schema->txn( sub { ... } );

Return C<true> or exception.

Execute L<DBIx::Class::Schema/txn_do> in trap an exception.

For exceptions, does L</txn_failed>.

Return result

=head2 C<TZ>

    package Yetie::Schema::Result::Foo;

    column created_at => {
        data_type   => 'DATETIME',
        ...
        timezone    => Yetie::Schema->TZ,
    };

Return L<DateTime::TimeZone> object.
See L<Yetie::App::Core::DateTime/TZ>.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::Result>, L<Yetie::Schema::ResultSet>, L<DBIx::Class::Schema>
