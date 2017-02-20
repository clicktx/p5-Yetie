package Markets::Controller::Catalog::Account;
use Mojo::Base 'Markets::Controller::Catalog';

sub authorize {
    my $self = shift;
    say "authorize";    #debug
    my $referer = $self->current_route;
    my $redirect_url = $self->url_for('RN_customer_login')->query( ref => $referer );
    $self->redirect_to($redirect_url) and return 0 unless $self->service('customer')->is_logged_in;
    return 1;
}

sub login {
    my $self   = shift;
    my $params = $self->req->params;

    $self->render( ref => $params->param('ref') );
}

# TODO: $session->data()を直接使わないようにする
sub login_authen {
    my $self    = shift;
    my $params  = $self->req->params;
    my $session = $self->server_session;

    my $is_valid = $params->param('password');
    if ($is_valid) {
        my $customer_id = 1;
        $self->service('customer')->login($customer_id);

        my $redirect_route = $params->param('ref') || 'RN_customer_home';
        return $self->redirect_to($redirect_route);
    }
    else {
        say "don't loged in.";    #debug
    }
    $self->render( template => 'account/login', ref => $params->param('ref') );
}

sub logout {
    my $self = shift;

    my $session = $self->server_session;
    $self->model('account')->remove_session($session);
}

sub home {
    my $self = shift;
}

sub orders {
    my $self = shift;
}

sub wishlist {
    my $self = shift;
}

1;
