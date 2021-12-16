#!/usr/bin/env perl

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
# TODO