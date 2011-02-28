#!/usr/bin/perl

use strict;
use warnings;

use Net::Ping::External qw(ping);

my $target = shift;

my $state = ping(host => $target);

if ($state) {
    print "monitoring $target (currently up)\n";
}
else {
    print "monitoring $target (currently down)\n";
}

while (1) {
    sleep 5;
    my $alive = ping(host => $target);
    if ($alive == 0 and $state == 1) {
        system('notify-send', "$target just went down");
    }
    elsif ($alive == 1 and $state == 0) {
        system('notify-send', "$target just came up");
    }
    if ($alive) {
        print "$target is alive ($alive)\n";
    }
    else {
        print "$target is down ($alive)\n";
    }
    $state = $alive;
}
