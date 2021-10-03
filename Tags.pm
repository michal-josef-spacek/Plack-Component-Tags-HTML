package Plack::Component::Tags;

use base qw(Plack::Component);
use strict;
use warnings;

use CSS::Struct::Output::Raw;
use Plack::Util::Accessor qw(css generator title tags);
use Tags::HTML::Page::Begin;
use Tags::HTML::Page::End;
use Tags::Output::Raw;
use Unicode::UTF8 qw(encode_utf8);

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	# Process actions.
	$self->_process_actions($env);

	# Process 'Tags' for page.
	$self->_tags;
	$self->tags->finalize;
	return [
		200,
		[
			'content-type' => 'text/html; charset=utf-8',
		],
		[encode_utf8($self->tags->flush(1))],
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

	if (! $self->title) {
		$self->title(__PACKAGE__);
	}

	return;
}

sub _process_actions {
	my $self = shift;

	return;
}

sub _tags_middle {
	my $self = shift;

	return;
}

sub _tags {
	my $self = shift;

	Tags::HTML::Page::Begin->new(
		'css' => $self->css,
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
