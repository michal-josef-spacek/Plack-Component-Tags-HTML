package Plack::Component::Tags::HTML;

use base qw(Plack::Component);
use strict;
use warnings;

use CSS::Struct::Output::Raw;
use Encode qw(encode);
use Plack::Util::Accessor qw(author content_type css encoding
	favicon flag_begin flag_end generator psgi_app status_code title tags);
use Tags::HTML::Page::Begin;
use Tags::HTML::Page::End;
use Tags::Output::Raw;

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	# Process actions.
	$self->_process_actions($env);

	# PSGI application.
	if ($self->psgi_app) {
		my $app = $self->psgi_app;
		$self->psgi_app(undef);
		return $app;
	}

	# Process 'Tags' for page.
	$self->_css;
	$self->_tags;
	$self->tags->finalize;

	return [
		$self->status_code,
		[
			'content-type' => $self->content_type,
		],
		[$self->_encode($self->tags->flush(1))],
	];
}

sub prepare_app {
	my $self = shift;

	if (! $self->tags || ! $self->tags->isa('Tags::Output')) {
		$self->tags(Tags::Output::Raw->new(
			'xml' => 1,
			'no_simple' => ['textarea'],
			'preserved' => ['pre'],
		));
	}

	if (! $self->css || ! $self->css->isa('CSS::Struct::Output')) {
		$self->css(CSS::Struct::Output::Raw->new);
	}

	if (! $self->encoding) {
		$self->encoding('utf-8');
	}

	if (! $self->content_type) {
		$self->content_type('text/html; charset='.$self->encoding);
	}

	if (! $self->status_code) {
		$self->status_code(200);
	}

	if (! defined $self->flag_begin) {
		$self->flag_begin(1);
	}

	if (! defined $self->flag_end) {
		$self->flag_end(1);
	}

	$self->_prepare_app;

	return;
}

sub _css {
	my $self = shift;

	return;
}

sub _encode {
	my ($self, $string) = @_;

	return encode($self->encoding, $string);
}

sub _prepare_app {
	my $self = shift;

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	return;
}

sub _tags_middle {
	my $self = shift;

	return;
}

sub _tags {
	my $self = shift;

	if ($self->flag_begin) {
		Tags::HTML::Page::Begin->new(
			'author' => $self->author,
			'css' => $self->css,
			'charset' => $self->encoding,
			'favicon' => $self->favicon,
			'generator' => $self->generator,
			'lang' => {
				'title' => $self->title,
			},
			'tags' => $self->tags,
		)->process;
	}

	$self->_tags_middle;

	if ($self->flag_end) {
		Tags::HTML::Page::End->new(
			'tags' => $self->tags,
		)->process;
	}

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Plack::Component::Tags::HTML - Plack component for Tags with HTML output.

=head1 SYNOPSIS

 package App;

 use base qw(Plack::Component::Tags::HTML);

 sub _css {
        my $self = shift;
        $self->{'css'}->put(
                # Structure defined by CSS::Struct
        );
        return;
 }

 sub _prepare_app {
        my $self = shift;
        # Preparation of app, before Plack::Component::call().
        return;
 }

 sub _process_actions {
        my ($self, $env) = @_;
        # Process actions in Plack::Component::call() before output.
        return;
 }

 sub _tags_middle {
        my $self = shift;
        $self->{'tags'}->put(
                # Structure defined by Tags
        );
        return;
 }

=head1 DESCRIPTION

This component is helper for creating Plack application with Tags.
It is based on Plack::Component.

=head1 ACCESSOR METHODS

=head2 C<author>

Author string to HTML head.
Default value is undef.

=head2 C<content_type>

Content type for output.
Default value is 'text/html; charset=__ENCODING__'.

=head2 C<css>

CSS::Struct::Output object.
Default value is CSS::Struct::Output::Raw->new.

=head2 C<encoding>

Set encoding for output.
Default value is 'utf-8'.

=head2 C<favicon>

Link to favicon.
Default value is undef.

=head2 C<flag_begin>

Flag that means begin of html writing via L<Tags::HTML::Page::Begin>.
Example is in L<EXAMPLE2>.
Default value is 1.

=head2 C<flag_end>

Flag that means end of html writing via L<Tags::HTML::Page::End>.
Example is in L<EXAMPLE2>.
Default value is 1.

=head2 C<generator>

Generator string to HTML head.
Default value is undef.

=head2 C<psgi_app>

PSGI application to run instead of normal process.
Intent of this is change application in C<_process_actions> method.
Default value is undef.

=head2 C<status_code>

HTTP status code.
Default value is 200.

=head2 C<title>

Title of page.
Default value is undef.

=head2 C<tags>

Tags::Output object.
Default value is

 Tags::Output::Raw->new(
         'xml' => 1,
         'no_simple' => ['textarea'],
         'preserved' => ['pre'],
 ));

=head1 METHODS TO OVERWRITE

=head2 C<_css>

Method to set css via C<$self->{'css'}> object.
Argument is C<$self> only.

=head2 C<_prepare_app>

Method to set app preparation part. Called only once on start.
Argument is C<$self> only.

=head2 C<_process_actions>

Method to set app processing part. Called in each call before creating of
output. Argument is C<$self> and C<$env>.

=head2 C<_tags_middle>

Method to set tags via C<$self->{'tags'}> object.
Argument is C<$self> only.

=head1 METHODS IMPLEMENTED

=head2 C<call>

Inherited from L<Plack::Component>.
There is run of:

 $self->_process_actions($env);
 $self->_css;
 $self->_tags;

After it Generate and encode output from Tags to output with HTTP code.
HTTP status code is defined by C<status_code()> method and Content-Type is
defined by C<content_type> method.

=head2 C<prepare_app>

Initialize default values for:

 tags()
 css()
 encoding()
 content_type()
 status_code()

and run _prepare_app().

=head1 EXAMPLE1

 package App;

 use base qw(Plack::Component::Tags::HTML);
 use strict;
 use warnings;

 sub _tags_middle {
         my $self = shift;

         $self->{'tags'}->put(
                 ['d', 'Hello world'],
         );

         return;
 }

 package main;

 use Plack::Runner;

 my $app = App->new(
         'title' => 'My app',
 )->to_app;
 my $runner = Plack::Runner->new;
 $runner->run($app);

 # Output:
 # HTTP::Server::PSGI: Accepting connections at http://0:5000/

 # Output by HEAD to http://localhost:5000/:
 # 200 OK
 # Date: Sun, 31 Oct 2021 10:35:33 GMT
 # Server: HTTP::Server::PSGI
 # Content-Length: 166
 # Content-Type: text/html; charset=utf-8
 # Client-Date: Sun, 31 Oct 2021 10:35:33 GMT
 # Client-Peer: 127.0.0.1:5000
 # Client-Response-Num: 1

 # Output by GET to http://localhost:5000/:
 # <!DOCTYPE html>
 # <html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>My app</title></head><body>Hello world</body></html>

=head1 EXAMPLE2

 package App;

 use base qw(Plack::Component::Tags::HTML);
 use strict;
 use warnings;

 sub _tags_middle {
         my $self = shift;

         $self->{'tags'}->put(
                 ['d', 'Hello world'],
         );

         return;
 }

 package main;

 use Plack::Runner;

 my $app = App->new(
         'flag_begin' => 0,
         'flag_end' => 0,
         'title' => 'My app',
 )->to_app;
 my $runner = Plack::Runner->new;
 $runner->run($app);

 # Output by GET to http://localhost:5000/:
 # Hello world

=head1 DEPENDENCIES

L<CSS::Struct::Output::Raw>,
L<Encode>,
L<Plack::Component>,
L<Plack::Util::Accessor>,
L<Tags::HTML::Page::Begin>,
L<Tags::HTML::Page::End>,
L<Tags::Output::Raw>.

=head1 SEE ALSO

=over

=item L<Plack::Component>

Base class for PSGI endpoints

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Plack-Component-Tags-HTML>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© Michal Josef Špaček 2021

BSD 2-Clause License

=head1 VERSION

0.01

=cut
