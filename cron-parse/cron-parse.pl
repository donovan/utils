#!/usr/bin/perl

# Schedule::Cron::Events is not in debian/ubuntu
# if you want to dh-make-perl it install
# $ sudo apt-get install libset-crontab-perl

use strict;
use warnings;

use Schedule::Cron::Events;

my $cron_line = shift;
$cron_line //= '23 4,16 * * *';

my $count = 20;

my $cron = new Schedule::Cron::Events($cron_line, Seconds => time() );
my ($sec, $min, $hour, $day, $month, $year);

print "The next $count events for the cron line '$cron_line' will be:\n\n";

for (1..$count) {
    # find the next execution time
    ($sec, $min, $hour, $day, $month, $year) = $cron->nextEvent;
    printf("Event %02d will start at %02d:%02d:%02d on %d-%02d-%02d\n", $_, $hour, $min, $sec, ($year+1900), ($month+1), $day);
}

$cron->resetCounter;
($sec, $min, $hour, $day, $month, $year) = $cron->previousEvent;
printf("\nThe last event started at %02d:%02d:%02d on %d-%02d-%02d\n", $hour, $min, $sec, ($year+1900), ($month+1), $day);
