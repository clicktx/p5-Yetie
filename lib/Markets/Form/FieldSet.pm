package Markets::Form::FieldSet;
use Mojo::Base -base;
use Mojo::Util qw/monkey_patch/;
use Tie::IxHash;
use Scalar::Util qw/weaken/;
use Carp qw/croak/;
use CGI::Expand qw/expand_hash/;
use Mojolicious::Controller;
use Mojo::Collection;
use Markets::Form::Field;

has controller => sub { Mojolicious::Controller->new };
has 'is_validated';

sub append {
    my ( $self, $field_key ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_key;

    no strict 'refs';
    ${"${class}::schema"}{$field_key} = +{@_};
}

sub checks { shift->_get_data( shift, 'validations' ) }

sub field_keys {
    my $self = shift;
    my $class = ref $self || $self;

    no strict 'refs';
    my @field_keys = keys %{"${class}::schema"};
    return wantarray ? @field_keys : \@field_keys;
}

sub field {
    my ( $self, $name ) = ( shift, shift );
    my $args = @_ > 1 ? +{@_} : shift || {};
    my $class = ref $self || $self;

    my $field_key = _replace_key($name);
    my $cache_key = $name eq $field_key ? $field_key : "$field_key=$name";
    return $self->{_field}->{$cache_key} if $self->{_field}->{$cache_key};

    no strict 'refs';
    my $attrs = $field_key ? ${"${class}::schema"}{$field_key} : {};
    my $field = Markets::Form::Field->new( field_key => $field_key, name => $name, %{$args}, %{$attrs} );
    $self->{_field}->{$cache_key} = $field;
    return $field;
}

sub filters { shift->_get_data( shift, 'filters' ) }

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    weaken $self->{controller};
    return $self;
}

sub import {
    my $class  = shift;
    my $caller = caller;

    no strict 'refs';
    no warnings 'once';
    push @{"${caller}::ISA"}, $class;
    tie %{"${caller}::schema"}, 'Tie::IxHash';
    monkey_patch $caller, 'has_field', sub { append( $caller, @_ ) };
    monkey_patch $caller, 'c', sub { Mojo::Collection->new(@_) };
}

sub param {
    my ( $self, $key ) = @_;
    $key =~ m/[a-zA-Z0-9]\[\]$/ ? $self->params->every_param($key) : $self->params->param($key);
}

sub params {
    my $self = shift;
    croak 'do not call "validate" method' unless $self->is_validated;
    return $self->{_validated_parameters} if $self->{_validated_parameters};

    my $v      = $self->controller->validation;
    my %output = %{ $v->output };

    # NOTE: scope parameterは別に保存していないので
    # 'user.name' フィールドを使う場合は 'user'フィールドを使うことが出来ない
    my $expand_hash = expand_hash( \%output );
    %output = ( %output, %{$expand_hash} );

    $self->{_validated_parameters} = Mojo::Parameters->new(%output);
    return $self->{_validated_parameters};
}

sub remove {
    my ( $self, $field_key ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_key;

    no strict 'refs';
    delete ${"${class}::schema"}{$field_key};
}

sub render_label {
    my $self = shift;
    my $name = shift;

    $self->field($name)->label_for;
}

sub render {
    my $self = shift;
    my $name = shift;

    my %attrs;
    my $value = $self->controller->req->params->param($name);
    $attrs{value} = $value if defined $value;

    my $field = $self->field( $name, %attrs );
    my $method = $field->type || 'text';
    $field->$method;
}

sub schema {
    my ( $self, $field_key ) = @_;
    my $class = ref $self || $self;

    no strict 'refs';
    my %schema = %{"${class}::schema"};
    return $field_key ? $schema{$field_key} : \%schema;
}

sub scope_param { shift->params->every_param(shift) }

sub validate {
    my $self  = shift;
    my $v     = $self->controller->validation;
    my $names = $self->controller->req->params->names;

    foreach my $field_key ( @{ $self->field_keys } ) {
        my $required = $self->schema->{$field_key}->{required};
        my $filters  = $self->filters($field_key);
        my $checks   = $self->checks($field_key);

        # multiple field: eg. parameter_name = "favorite_color[]"
        $field_key .= '[]' if $self->schema($field_key)->{multiple};

        # expanding field: e.g. field_key = "user.[].id" parameter_name = "user.0.id"
        if ( $field_key =~ m/\.\[\]/ ) {
            my @match = grep { my $name = _replace_key($_); $field_key eq $name } @{$names};
            foreach my $key (@match) {
                $required ? $v->required( $key, @{$filters} ) : $v->optional( $key, @{$filters} );
                _do_check( $v, $_ ) for @$checks;
            }
        }
        else {
            $required ? $v->required( $field_key, @{$filters} ) : $v->optional( $field_key, @{$filters} );
            _do_check( $v, $_ ) for @$checks;
        }
    }
    $self->is_validated(1);
    return $v->has_error ? undef : 1;
}

sub _do_check {
    my $v = shift;

    my ( $check, $args ) = ref $_[0] ? %{ $_[0] } : ( $_[0], undef );
    return $v->$check unless $args;

    return ref $args eq 'ARRAY' ? $v->$check( @{$args} ) : $v->$check($args);
}

sub _get_data {
    my ( $self, $field_key, $attr_name ) = @_;

    if ($field_key) {
        return ${ $self->schema }{$field_key} ? ${ $self->schema }{$field_key}->{$attr_name} || [] : undef;
    }
    else {
        my %data = map { $_ => $self->schema->{$_}->{$attr_name} || [] } @{ $self->field_keys };
        return \%data || {};
    }
}

sub _replace_key { my $arg = shift; $arg =~ s/\.\d/.[]/g; $arg; }

1;
__END__

=encoding utf8

=head1 NAME

Markets::Form::Field

=head1 SYNOPSIS

    # Your form field class
    package Markets::Form::Type::User;
    use Markets::Form::FieldSet;

    has_field 'name' => ( %args );
    ...

    # In controller
    my $fieldset = $c->form_set('user');

    if ( $fieldset->validate ){
        $c->render( text => 'thanks');
    } else {
        $c->render( text => 'validation failure');
    }


=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 C<controller>

    my $controller = $fieldset->controller;
    $fieldset->controller( Mojolicious::Controller->new );

Return L<Mojolicious::Controller> object.

=head2 C<is_validated>

    my $bool = $fieldset->is_validated;

Return boolean value.

=head1 FUNCTIONS

=head2 C<c>

    my $collection = c(1, 2, 3);

Construct a new array-based L<Mojo::Collection> object.

=head2 C<has_field>

    has_field 'field_name' => ( type => 'text', ... );

=head1 METHODS

=head2 C<append>

    $fieldset->append( 'field_name' => ( %args ) );

=head2 C<checks>

    # Return array refference
    # [ 'validation1', 'validation2', ... ]
    my $checks = $fieldset->checks('email');

    # Return hash refference
    # { field_key => [ 'validation1', 'validation2', ... ], field_key2 => [ 'validation1', 'validation2', ... ] }
    my $checks = $fieldset->checks;

=head2 C<field_keys>

    my @field_keys = $fieldset->field_keys;

    # Return array refference
    my $field_keys = $fieldset->field_keys;

=head2 C<field>

    my $field = $fieldset->field('field_name');

Return L<Markets::Form::Field> object.
Object once created are cached in "$fieldset->{_field}->{$field_key}".

=head2 C<filters>

    # Return array refference
    # [ 'filter1', 'filter2', ... ]
    my $filters = $fieldset->filters('field_key');

    # Return hash refference
    # { field_key => [ 'filter1', 'filter2', ... ], field_key2 => [ 'filter1', 'filter2', ... ] }
    my $filters = $fieldset->filters;

=head2 C<param>

    # Return scalar
    my $param = $fieldset->param('name');

    # Return array refference
    my $param = $fieldset->param('favorite[]')

The parameter is a validated values.
This method should be called after the "validate" method.

=head2 C<params>

    my $validated_params = $fieldset->params;

Return L<Mojo::Parameters> object.
All parameters are validated values.
This method should be called after the "validate" method.

=head2 C<remove>

    $fieldset->remove('field_name');

=head2 C<render_label>

    $fieldset->render_label('email');

Return code refference.

=head2 C<render>

    $fieldset->render('email');

Return code refference.

=head2 C<schema>

    my $schema = $fieldset->schema;

    my $field_schema = $fieldset->schema('field_key');

Return hash refference. Get a field definition.

=head2 C<scope_param>

    my $scope = $fieldset->scope_param('user');

Return hash refference or array refference.
The parameter is a validated values.
This method should be called after the "validate" method.

Get expanded parameter. SEE L<CGI::Expand/expand_hash>

=head2 C<validate>

    my $bool = $fieldset->validate;
    say 'Validation failure!' unless $bool;

Return boolean. success return true.

=head1 SEE ALSO

=cut