package Markets::Model::Data::Base;
use Mojo::Base 'MojoX::Model';
use DBI;
use Markets::DB;
use Teng::Schema::Loader;
use Data::Dumper;

sub do {
    my ($self) = @_;
    my $db = $self->app->db;
    say $db;
    say Dumper $db->single(session => {session_id => 1});
    say "data->do";
}

1;
__END__

=head1 NAME

Markets::Model::Data::Base

=head1 SYNOPSIS

Your model

    package Markets::Model::Data::Base;
    use Mojo::Base 'MojoX::Model';

    sub do {
      my ($self) = @_;
      say "do";
    }

Your app

    sub startup {
        my $self = shift;

        $self->plugin( Model => {
            namespaces   => ['Markets::Model', 'MyApp::CLI::Model'],
            base_classes => ['MyApp::Model'],
            default      => 'MyApp::Model::Pg',
            params => {Pg => {uri => 'postgresql://user@/mydb'}}
        });
        ...

App Controller.
Camel case or Module name.

    package Markets::Web::Controller::Example;
    use Mojo::Base 'Mojolicious::Controller';

    sub welcome {
        my $self = shift;

        # model
        $self->app->model('data-base')->do;
        # or
        $self->app->model('Data::Base')->do;
    }

=head1 DESCRIPTION

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

L<Mojolicious::Plugin::Model> L<MojoX::Model>