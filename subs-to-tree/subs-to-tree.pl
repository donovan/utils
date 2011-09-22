#!/usr/bin/perl

use strict;
use warnings;

use Storable qw(dclone);
use Data::Dump qw(dump);
use List::MoreUtils qw(uniq);
use Data::TreeDumper;

# produce a subroutine call graph tree
# credit for the transform sub to Khisanth on #perl-help on irc.perl.org

$Data::TreeDumper::Useascii = 0;

my $calls = {};

my %local_sub;

while (<>) {
    next unless my ($name) = /^sub (\S+)/;
    $local_sub{$name}++;
    while (<>) {
        last if /^}/;
        next unless my @funcs = /(\w+)\(/g;
        push @{$calls->{$name}}, @funcs;
    }
}

#dump $calls;

my $data = {};

foreach my $sub (keys %$calls) {
    $data->{$sub} = [];
    foreach my $call (@{$calls->{$sub}}) {
        push @{$data->{$sub}}, $call if $local_sub{$call};
    }
}

print "existing:\n";
dump $data;
dump ( transform($data) );
print DumpTree(transform($data), $ARGV, DISPLAY_ADDRESS => 0) ;

sub transform {
    my $input = shift;

    # keep track of what nodes exist, an alternative is to traverse the whole
    # graph for every input node
    my %registry;

    # return value
    my %roots;

    foreach my $key ( keys %$input ) {

        my $branch = $registry{ $key };

        unless ( $branch ) {
            # tentative root
            $branch = $roots{$key} = $registry{$key} = {};
        }

        foreach my $leaf ( uniq @{$input->{$key}} ) {

            if ( $roots{ $leaf } ) {
                # turned out not to be a root
                delete $roots{ $leaf };
                $branch->{ $leaf } = $registry{ $leaf }
            }
            elsif ( $registry{ $leaf } ) {
                # existing leaf
                # to get a graph instead of a tree remove the call to dclone
                $branch->{ $leaf } = dclone( $registry{ $leaf } );
            }
            else {
                # not a root and not a leaf so it has to be new
                $branch->{ $leaf } = $registry{ $leaf } = {}
            }
        }

    }

    return \%roots;
}
