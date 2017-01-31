package Markets::Model::Data::Base;
use Mojo::Base 'Markets::Model';
use Data::Dumper;

sub do {
    my ($self) = @_;
    my $db = $self->app->db;
    # say '$app->dbh => ' . $self->app->dbh . 'on Model::Data::Base'; 
    # say '$app->db => ' . $db; 
    # say $db->single(sessions => {sid => 1});
    # say "data->do";
}

1;
__END__

=head1 NAME

Markets::Model::Data::Base

=head1 SYNOPSIS

Your model

    package Markets::Model::Data::Base;
    use Mojo::Base 'Markets::Model';

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
Snake case or Module name.

    package Markets::Controller::Catalog::Example;
    use Mojo::Base 'Markets::Controller::Catalog';

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

L<Markets::Model> L<Mojolicious::Plugin::Model> L<MojoX::Model>
