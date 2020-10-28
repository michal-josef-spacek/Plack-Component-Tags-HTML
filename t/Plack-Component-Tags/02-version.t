use strict;
use warnings;

use Plack::Component::Tags;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::Component::Tags::VERSION, 0.01, 'Version.');
