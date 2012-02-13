#!/usr/bin/perl
##############################################################################
#
# Script:   watch-dns-ttl.pl
#
# Author:   Donovan Jones <git@gamma.net.nz>
#
# Description:
#
# Check A Record and TTL against publicly accissible recursive resolvers
#

use 5.010;
use strict;
use warnings;

use Pod::Usage;
use Getopt::Long qw(GetOptions);

use Net::DNS;

my(%opt);

if(!GetOptions(\%opt, 'help|?',)) {
    pod2usage(-exitval => 1,  -verbose => 0);
}

pod2usage(-exitstatus => 0, -verbose => 1) if $opt{help};

my $target = shift;

# recursive resolvers
my @servers = qw(
    128.107.241.185
    156.154.70.1
    156.154.71.1
    199.2.252.10
    204.117.214.10
    204.97.212.10
    208.67.220.220
    208.67.222.222
    4.2.2.1
    4.2.2.2
    4.2.2.3
    4.2.2.4
    4.2.2.5
    64.102.255.44
    64.81.45.2
    64.81.79.2
    66.93.87.2
    8.8.4.4
    8.8.8.8
);

my $host_count = @servers;

my $clear = `tput clear`;
my $home  = `tput home`;

my %checks = (
    a   => 'A',
    ttl => 'TTL',
);

# work out max Name for padding
my $name_length = 0;
foreach my $server (@servers) {
    my $length = length($server);
    $name_length = $length if $name_length < $length;
}
$name_length++;

my $lines = {};
my $index = 0;

while (1) {
    my $current_server = $servers[$index];

    my $data = {};
    ($data->{a}, $data->{ttl}) = get_a_record($current_server, $target);

    print $clear;
    print $home;

    # HEADINGS
    my $header_line = sprintf("%-${name_length}s", 'NAMESERVER');
    $header_line .= '     ';
    foreach my $check (keys %checks) {
        $header_line .= sprintf('%-20s', $checks{$check});
    }
    print $header_line . "\n";
    print '-' x ($name_length + 35), "\n";

       # print out all the targets
    my $count = 0;
    foreach my $host (@servers) {

        my $line;
        if ($host eq $current_server) {
            $line = sprintf("%-${name_length}s", $host);
            $line .= ' ==> ';
            foreach my $check (keys %checks) {
                $line .= sprintf('%-20s', $data->{$check});
            }
            $lines->{$host} = $line;
            $lines->{$host} =~ s/==>/   /;
        }
        else {
            $line = $lines->{$host} // sprintf("%-${name_length}s", $host);
        }

        print $line . "\n";

        $count++;

    }

    # update the index
    if ($index == $host_count - 1) {
        $index = 0;
    }
    else {
        $index++;
    }

}

sub get_a_record {

    my ($server,$target) = @_;

    my ($a,$ttl);

    my $res = Net::DNS::Resolver->new(
        nameservers => [$server],
        recurse     => 1,
    );
    my $query = $res->search($target, 'A');

    if ($query) {
        foreach my $rr ($query->answer) {
            if ($rr->type eq 'A') {
                $a   = $rr->rdatastr;
                $ttl = $rr->ttl;
            }
        }
    }

    $a   //= '-';
    $ttl //= '-';

    return ($a, $ttl);
}

exit 0;

__END__

=head1 NAME

watch-dns-ttl.pl - A script designed to check the A record and TTL of a target
against a list of publicly accessible recursive resolvers. Useful when
switching DNS records and you want to see what servers are handing out

=head1 SYNOPSIS

  watch-dns-ttl.pl [options]

  Options:

   --help     detailed help message

=head1 DESCRIPTION

A script designed to check the A record and TTL of a target against a list of
publicly accessible recursive resolvers.

=head1 OPTIONS

=over 4

=item B<--help>

Display this documentation.

=back

=cut
