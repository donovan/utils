#!/usr/bin/perl

##############################################################################
#
# Script:   compare-paths.pl
#
# Author:   Donovan Jones <perl -MMIME::Base64 -le 'print decode_base64("bGludXhAZ2FtbWEubmV0Lm56")'>
#
# Description:
#
# TODO_DESCRIPTION
# This script compares the file names in two paths and tells you if there are any
# differences. It is dumb and simply compares names, it is not hashing the files
# and comparing them or even looking at the file size, on the plus side that
# means its fast.
#

use strict;
use warnings;

use Pod::Usage;
use Getopt::Long qw(GetOptions);

use File::Find;
use Data::Dumper;

my(%opt);

if(!GetOptions(\%opt, 'help|?', 'database|d=s')) {
    pod2usage(-exitval => 1,  -verbose => 0);
}

pod2usage(-exitstatus => 0, -verbose => 1) if $opt{help};

my $dir_1 = shift;
my $dir_2 = shift;

my $data = {};

find(\&process_file1, $dir_1);
find(\&process_file2, $dir_2);

sub process_file1 {
    my $file = $File::Find::name;
    if (-f $file) {
        $file =~ s{$dir_1}{}xms;
        $data->{$dir_1}{files}{$file}++;
    }
}
sub process_file2 {
    my $file = $File::Find::name;
    if (-f $file) {
        $file =~ s{$dir_2}{}xms;
        $data->{$dir_2}{files}{$file}++;
    }
}

print Dumper($data) if $opt{debug};

print "$dir_1\n";
foreach my $file (sort keys %{$data->{$dir_1}{files}}) {
    unless ($data->{$dir_2}{files}{$file}) {
        print "file $file only occurs in $dir_1\n";
    }
}
print "\n\n";

print "$dir_2\n";
foreach my $file (sort keys %{$data->{$dir_2}{files}}) {
    unless ($data->{$dir_1}{files}{$file}) {
        print "file $file only occurs in $dir_2\n";
    }
}
print "\n\n";

exit 0;

__END__

=head1 NAME

compare-paths.pl - compare two paths and show the differences

=head1 SYNOPSIS

  compare-paths.pl [options] <path1> <path2>

  Options:

   --help     detailed help message
   --debug    dump the raw data

=head1 DESCRIPTION

This script compares the file names in two paths and tells you if there are any
differences. It is dumb and simply compares names, it is not hashing the files
and comparing them or even looking at the file size, on the plus side that
means its fast.

=head1 OPTIONS

=over 4

=item B<--help>

Display this documentation.

=back

=cut
