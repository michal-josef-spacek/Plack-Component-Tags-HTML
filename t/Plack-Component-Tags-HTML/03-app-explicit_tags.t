use strict;
use warnings;

use English;
use Error::Pure::Utils qw(clean);
use Tags::Output::Raw;
use Test::MockObject;
use Test::More 'tests' => 10;
use Test::NoWarnings;

package App;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

package main;

use HTTP::Request::Common;
use Plack::Test;

# Test.
my $app = App->new(
	'flag_begin' => 0,
	'flag_end' => 0,
	'tags' => Tags::Output::Raw->new,
);
test_psgi($app, sub {
	my $cb = shift;

	my $res = $cb->(GET "/");
	is($res->code, 200, 'HTTP code (200).');
	is($res->header('Content-Type'), 'text/html; charset=utf-8', 'Content type (HTML).');
	is($res->content, '', 'Content (blank).');
});

# Test.
$app = App->new(
	'tags' => 'foo',
);
test_psgi($app, sub {
	my $cb = shift;

	# XXX This is not real response, fatal error.
	my $res = $cb->(GET "/");
	is($res->code, 500, 'HTTP code (500).');
	is($res->header('Content-Type'), 'text/plain', 'Content type (plain).');
	is($res->content, "Accessor 'tags' must be a 'Tags::Output' object.\n", 'Content (error).');
});

# Test.
$app = App->new(
	'tags' => Test::MockObject->new,
);
test_psgi($app, sub {
	my $cb = shift;

	# XXX This is not real response, fatal error.
	my $res = $cb->(GET "/");
	is($res->code, 500, 'HTTP code (500).');
	is($res->header('Content-Type'), 'text/plain', 'Content type (plain).');
	is($res->content, "Accessor 'tags' must be a 'Tags::Output' object.\n", 'Content (error).');
});
