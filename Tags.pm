package Plack::Component::Tags;

use base qw(Plack::Component);
use strict;
use warnings;

use CSS::Struct::Output::Raw;
use Encode qw(encode);
use Plack::Util::Accessor qw(author css encoding favicon generator title tags);
use Tags::HTML::Page::Begin;
use Tags::HTML::Page::End;
use Tags::Output::Raw;

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	# Process actions.
	$self->_process_actions($env);

	# Process 'Tags' for page.
	$self->_css;
	$self->_tags;
	$self->tags->finalize;
	return [
		200,
		[
			'content-type' => 'text/html; charset='.$self->encoding,
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
		));
	}

	if (! $self->css || ! $self->css->isa('CSS::Struct::Output')) {
		$self->css(CSS::Struct::Output::Raw->new);
	}

	if (! $self->encoding) {
		$self->encoding('utf-8');
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

	$self->_tags_middle;

	Tags::HTML::Page::End->new(
		'tags' => $self->tags,
	)->process;

	return;
}
1;

__END__

=pod

=encoding utf8

=head1 NAME

Plack::Component::Tags - Plack component for Tags.

=head1 SYNOPSIS

 package App;

 use base qw(Plack::Component::Tags);

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

 sub _process_action {
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

=head1 METHODS

=head2 C<author>

Author string to HTML head.
Default value is undef.

=head2 C<css>

CSS::Struct::Output object.
Default value is CSS::Struct::Output::Raw->new.

=head2 C<encoding>

Set encoding for output.
Default value is 'utf-8'.

=head2 C<favicon>

Link to favicon.
Default value is undef.

=head2 C<generator>

Generator string to HTML head.
Default value is undef.

=head2 C<title>

Title of page.
Default value is undef.

=head2 C<tags>

Tags::Output object.
Default value is

 Tags::Output::Raw->new(
         'xml' => 1,
         'no_simple' => ['textarea'],
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

=head1 EXAMPLE

 package App;

 use base qw(Plack::Component::Tags);
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

 # Output by GET to http://0:5000/:
 # <!DOCTYPE html>
 # <html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>My app</title></head><body>Hello world</body></html>

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

L<https://github.com/michal-josef-spacek/Plack-Component-Tags>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© Michal Josef Špaček 2021

BSD 2-Clause License

=head1 VERSION

0.01

=cut
