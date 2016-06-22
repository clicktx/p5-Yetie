package Markets::Template;
use Mojo::Base 'Mojo::Template';

use Carp 'croak';
use Mojo::ByteStream;
use Mojo::Exception;
use Mojo::Util qw(decode encode monkey_patch slurp);

use constant DEBUG => $ENV{MOJO_TEMPLATE_DEBUG} || 0;
use Data::Dumper;

sub render_file {
    my ( $self, $c, $path ) = ( shift, shift, shift );

    $self->name($path) unless defined $self->{name};
    my $template = slurp $path;

    #
    $c->app->plugins->emit_hook( prefilter_transform => $c, $path, \$template, );

    my $encoding = $self->encoding;
    croak qq{Template "$path" has invalid encoding}
      if $encoding && !defined( $template = decode $encoding, $template );

    return $self->render( $template, @_ );
}

1;

=encoding utf8

=head1 NAME

Markets::Template - Perl-ish templates

=head1 SYNOPSIS

  use Markets::Template;

  # Use Perl modules
  my $mt = Markets::Template->new;
  say $mt->render(<<'EOF');
  % use Time::Piece;
  <div>
    % my $now = localtime;
    Time: <%= $now->hms %>
  </div>
  EOF

  # Render with arguments
  say $mt->render(<<'EOF', [1 .. 13], 'Hello World!');
  % my ($numbers, $title) = @_;
  <div>
    <h1><%= $title %></h1>
    % for my $i (@$numbers) {
      Test <%= $i %>
    % }
  </div>
  EOF

  # Render with named variables
  say $mt->vars(1)->render(<<'EOF', {title => 'Hello World!'});
  <div>
    <h1><%= $title %></h1>
    %= 5 + 5
  </div>
  EOF

=head1 DESCRIPTION

forked from L<Mojo::Template> Mojolicious v6.64

L<Markets::Template> is a minimalistic, fast, and very Perl-ish template engine,
designed specifically for all those small tasks that come up during big
projects. Like preprocessing a configuration file, generating text from heredocs
and stuff like that.

See L<Mojolicious::Guides::Rendering> for information on how to generate
content with the L<Mojolicious> renderer.

=head1 SYNTAX

For all templates L<strict>, L<warnings>, L<utf8> and Perl 5.10
L<features|feature> are automatically enabled.

  <% Perl code %>
  <%= Perl expression, replaced with result %>
  <%== Perl expression, replaced with XML escaped result %>
  <%# Comment, useful for debugging %>
  <%% Replaced with "<%", useful for generating templates %>
  % Perl code line, treated as "<% line =%>" (explained later)
  %= Perl expression line, treated as "<%= line %>"
  %== Perl expression line, treated as "<%== line %>"
  %# Comment line, useful for debugging
  %% Replaced with "%", useful for generating templates

Escaping behavior can be reversed with the L</"auto_escape"> attribute, this is
the default in L<Mojolicious> C<.ep> templates, for example.

  <%= Perl expression, replaced with XML escaped result %>
  <%== Perl expression, replaced with result %>

L<Mojo::ByteStream> objects are always excluded from automatic escaping.

  % use Mojo::ByteStream 'b';
  <%= b('<div>excluded!</div>') %>

Whitespace characters around tags can be trimmed by adding an additional equal
sign to the end of a tag.

  <% for (1 .. 3) { %>
    <%= 'Trim all whitespace characters around this expression' =%>
  <% } %>

Newline characters can be escaped with a backslash.

  This is <%= 1 + 1 %> a\
  single line

And a backslash in front of a newline character can be escaped with another
backslash.

  This will <%= 1 + 1 %> result\\
  in multiple\\
  lines

You can capture whole template blocks for reuse later with the C<begin> and
C<end> keywords. Just be aware that both keywords are part of the surrounding
tag and not actual Perl code, so there can only be whitespace after C<begin>
and before C<end>.

  <% my $block = begin %>
    <% my $name = shift; =%>
    Hello <%= $name %>.
  <% end %>
  <%= $block->('Baerbel') %>
  <%= $block->('Wolfgang') %>

Perl lines can also be indented freely.

  % my $block = begin
    % my $name = shift;
    Hello <%= $name %>.
  % end
  %= $block->('Baerbel')
  %= $block->('Wolfgang')

L<Markets::Template> templates get compiled to a Perl subroutine, that means you
can access arguments simply via C<@_>.

  % my ($foo, $bar) = @_;
  % my $x = shift;
  test 123 <%= $foo %>

The compilation of templates to Perl code can make debugging a bit tricky, but
L<Markets::Template> will return L<Mojo::Exception> objects that stringify to
error messages with context.

  Bareword "xx" not allowed while "strict subs" in use at template line 4.
  2: </head>
  3: <body>
  4: % my $i = 2; xx
  5: %= $i * 2
  6: </body>

=head1 ATTRIBUTES

L<Markets::Template> implements the following attributes.

=head2 auto_escape

  my $bool = $mt->auto_escape;
  $mt      = $mt->auto_escape($bool);

Activate automatic escaping.

  # "&lt;html&gt;"
  Markets::Template->new(auto_escape => 1)->render("<%= '<html>' %>");

=head2 append

  my $code = $mt->append;
  $mt      = $mt->append('warn "Processed template"');

Append Perl code to compiled template. Note that this code should not contain
newline characters, or line numbers in error messages might end up being wrong.

=head2 capture_end

  my $end = $mt->capture_end;
  $mt     = $mt->capture_end('end');

Keyword indicating the end of a capture block, defaults to C<end>.

  <% my $block = begin %>
    Some data!
  <% end %>

=head2 capture_start

  my $start = $mt->capture_start;
  $mt       = $mt->capture_start('begin');

Keyword indicating the start of a capture block, defaults to C<begin>.

  <% my $block = begin %>
    Some data!
  <% end %>

=head2 code

  my $code = $mt->code;
  $mt      = $mt->code($code);

Perl code for template if available.

=head2 comment_mark

  my $mark = $mt->comment_mark;
  $mt      = $mt->comment_mark('#');

Character indicating the start of a comment, defaults to C<#>.

  <%# This is a comment %>

=head2 compiled

  my $compiled = $mt->compiled;
  $mt          = $mt->compiled($compiled);

Compiled template code if available.

=head2 encoding

  my $encoding = $mt->encoding;
  $mt          = $mt->encoding('UTF-8');

Encoding used for template files, defaults to C<UTF-8>.

=head2 escape

  my $cb = $mt->escape;
  $mt    = $mt->escape(sub {...});

A callback used to escape the results of escaped expressions, defaults to
L<Mojo::Util/"xml_escape">.

  $mt->escape(sub {
    my $str = shift;
    return reverse $str;
  });

=head2 escape_mark

  my $mark = $mt->escape_mark;
  $mt      = $mt->escape_mark('=');

Character indicating the start of an escaped expression, defaults to C<=>.

  <%== $foo %>

=head2 expression_mark

  my $mark = $mt->expression_mark;
  $mt      = $mt->expression_mark('=');

Character indicating the start of an expression, defaults to C<=>.

  <%= $foo %>

=head2 line_start

  my $start = $mt->line_start;
  $mt       = $mt->line_start('%');

Character indicating the start of a code line, defaults to C<%>.

  % $foo = 23;

=head2 name

  my $name = $mt->name;
  $mt      = $mt->name('foo.mt');

Name of template currently being processed, defaults to C<template>. Note that
this value should not contain quotes or newline characters, or error messages
might end up being wrong.

=head2 namespace

  my $namespace = $mt->namespace;
  $mt           = $mt->namespace('main');

Namespace used to compile templates, defaults to C<Markets::Template::SandBox>.
Note that namespaces should only be shared very carefully between templates,
since functions and global variables will not be cleared automatically.

=head2 prepend

  my $code = $mt->prepend;
  $mt      = $mt->prepend('my $self = shift;');

Prepend Perl code to compiled template. Note that this code should not contain
newline characters, or line numbers in error messages might end up being wrong.

=head2 replace_mark

  my $mark = $mt->replace_mark;
  $mt      = $mt->replace_mark('%');

Character used for escaping the start of a tag or line, defaults to C<%>.

  <%% my $foo = 23; %>

=head2 tag_start

  my $start = $mt->tag_start;
  $mt       = $mt->tag_start('<%');

Characters indicating the start of a tag, defaults to C<E<lt>%>.

  <% $foo = 23; %>

=head2 tag_end

  my $end = $mt->tag_end;
  $mt     = $mt->tag_end('%>');

Characters indicating the end of a tag, defaults to C<%E<gt>>.

  <%= $foo %>

=head2 tree

  my $tree = $mt->tree;
  $mt      = $mt->tree([['text', 'foo'], ['line']]);

Template in parsed form if available. Note that this structure should only be
used very carefully since it is very dynamic.

=head2 trim_mark

  my $mark = $mt->trim_mark;
  $mt      = $mt->trim_mark('-');

Character activating automatic whitespace trimming, defaults to C<=>.

  <%= $foo =%>

=head2 unparsed

  my $unparsed = $mt->unparsed;
  $mt          = $mt->unparsed('<%= 1 + 1 %>');

Raw unparsed template if available.

=head2 vars

  my $bool = $mt->vars;
  $mt      = $mt->vars($bool);

Instead of a list of values, use a hash reference with named variables to pass
data to templates.

  # "works!"
  Markets::Template->new(vars => 1)->render('<%= $test %>!', {test => 'works'});

=head1 METHODS

L<Markets::Template> inherits all methods from L<Mojo::Base> and implements the
following new ones.

=head2 parse

  $mt = $mt->parse('<%= 1 + 1 %>');

Parse template into L</"tree">.

=head2 process

  my $output = $mt->process;
  my $output = $mt->process(@args);
  my $output = $mt->process({foo => 'bar'});

Process previously parsed template and return the result, or a
L<Mojo::Exception> object if rendering failed.

  # Parse and process
  say Markets::Template->new->parse('Hello <%= $_[0] %>')->process('Bender');

  # Reuse template (for much better performance)
  my $mt = Markets::Template->new;
  say $mt->render('Hello <%= $_[0] %>!', 'Bender');
  say $mt->process('Fry');
  say $mt->process('Leela');

=head2 render

  my $output = $mt->render('<%= 1 + 1 %>');
  my $output = $mt->render('<%= shift() + shift() %>', @args);
  my $output = $mt->render('<%= $foo %>', {foo => 'bar'});

Render template and return the result, or a L<Mojo::Exception> object if
rendering failed.

  # Longer version
  my $output = $mt->parse('<%= 1 + 1 %>')->process;

  # Render with arguments
  say Markets::Template->new->render('<%= $_[0] %>', 'bar');

  # Render with named variables
  say Markets::Template->new(vars => 1)->render('<%= $foo %>', {foo => 'bar'});

=head2 render_file

  my $output = $mt->render_file('/tmp/foo.mt');
  my $output = $mt->render_file('/tmp/foo.mt', @args);
  my $output = $mt->render_file('/tmp/bar.mt', {foo => 'bar'});

Same as L</"render">, but renders a template file.

=head1 DEBUGGING

You can set the C<MOJO_TEMPLATE_DEBUG> environment variable to get some
advanced diagnostics information printed to C<STDERR>.

  MOJO_TEMPLATE_DEBUG=1

=head1 SEE ALSO

L<Mojo::Template>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut
