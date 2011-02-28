#!/usr/bin/perl

use strict;
use warnings;

# What you need to do is find the greatest common divisor (GCD) and divide both
# values by that. The GCD is the highest number that evenly divides both
# numbers. So the GCD for 6 and 10 is 2, the GCD for 44 and 99 is 11.
# from: http://stackoverflow.com/questions/1186414/whats-the-algorithm-to-calculate-aspect-ratio-i-need-an-output-like-43-169

my $w = shift;
my $x = shift;
my $h = shift;

$h = $x unless $x eq 'x';

my $r = gcd($w, $h);

my $dw = $w / $r;
my $dh = $h / $r;

print 'Dimensions = ' . $w . ' x ' . $h . "\n";
print 'Gcd        = ' . $r . "\n";
print 'Aspect     = ' . $dw . ':' . $dh . "\n";
print 'Aspectx    = ' . $dw / $dh . ":1\n";

# greatest common divisor
sub gcd {
    $a = shift;
    $b = shift;

    return ($b == 0) ? $a : gcd ($b, $a % $b);
}
