#!/usr/bin/perl

##############################################################################
#
# Script:   fix-filenames.pl
#
# Author:   Donovan Jones <perl -MMIME::Base64 -le 'print decode_base64("bGludXhAZ2FtbWEubmV0Lm56")'>
#
# Description:
#
# This script cleans up filenames, somewhat like the detox utility.
# Written as detox didnt quite do what I wanted most of the time.
#

use strict;
use warnings;

use Pod::Usage;
use Getopt::Long qw(GetOptions);

use File::Find;
use File::Copy;
use Data::Dumper;
use File::Basename;

# Config variables
my $seperator = '.';
my $escaped_seperator = '\.';

# files you want trashed
my @junk = qw( Thumbs.db );

# TODO fix weird chars
# TODO command line switch to allow adding a prefix

my(%opt);

if(!GetOptions(\%opt, 'help|?', 'verbose|v', 'test|t')) {
    pod2usage(-exitval => 1,  -verbose => 0);
}

pod2usage(-exitstatus => 0, -verbose => 1) if $opt{help};

my $dir = shift;

my $data = {};

find(\&process_file, $dir);

sub process_file {
    my $path = $File::Find::name;
    if (-f $path) {
        print "path = $path\n" if $opt{verbose};
        my ($filename, $directories, $suffix) = fileparse($path, qr/\.[^.]*/);
        print "'$filename', '$directories', '$suffix'\n" if $opt{verbose};
        if ( grep { "${filename}${suffix}" eq $_ } @junk ) {
            print "unlink $path\n";;
            unlink $path unless $opt{test};
            return;
        }
        $filename = lc($filename);
        $suffix = lc($suffix);
        $filename =~ s{ \s+ }{$seperator}gmxs;
        $filename =~ s{ _ }{$seperator}gmxs;
        my @new_parts;
        foreach my $part ( split(/$escaped_seperator/, $filename) ) {
            # add your fixups here
            if ($part =~ m{ \A (xyz) \z }xms) {
                $part = '--' . $1 . '--' . $2;
            }
            if ($part eq 'foobar') {
                $part = 'barfoo';
            }
            print "got part = $part\n" if $opt{verbose};
            push @new_parts, $part;
        }
        my $new_name = join($seperator, @new_parts);
        my $new = $directories . $new_name . $suffix;
        if ($path eq $new) {
           print "skipping '$path' as there are no changes to make\n";
        }
        else {
            if (-f $new) {
                print "skipping '$path' as '$new' already exists)\n";
            }
            else {
                print "move($path, $new)\n";;
                unless ($opt{test}) {
                    move($path, $new) or die "move failed: $!";
                }
            }
        }
        print "-------------------------------------------\n" if $opt{verbose};
    }
}

exit 0;

__END__

=head1 NAME

fix-filenames.pl - fixup filenames

=head1 SYNOPSIS

  fix-filenames.pl [options] <path>

  Options:

   --help     detailed help message
   --verbose  extra verbosity
   --test     dont actually unlink or move any files

=head1 DESCRIPTION

This script renames files in a consistent way. Similar to the detox utility

=head1 OPTIONS

=over 4

=item B<--help>

Display this documentation.

=back

=cut
