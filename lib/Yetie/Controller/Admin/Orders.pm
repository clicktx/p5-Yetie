package Yetie::Controller::Admin::Orders;
use Mojo::Base 'Yetie::Controller::Admin';

sub index {
    my $self = shift;

    my $form = $self->form_set();
    $self->init_form();

    # return $self->render() unless $form->has_data;
    $form->validate;

    my $conditions = {
        where    => '',
        order_by => '',
        page_no  => $form->param('p') || 1,
        rows     => 5,
    };

    my $rs     = $self->app->schema->resultset('Sales::Order::Shipment');
    my $orders = $rs->search_sales_list($conditions);

    # content entity
    my $content = $self->app->factory('entity-content')->create(
        {
            # title      => $xx->title,
            # breadcrumb => $xx->breadcrumb,
            pager  => $orders->pager,
            params => $form->params,
        }
    );

    $self->stash(
        content => $content,
        orders  => $orders,
    );
    $self->render();
}

1;
