#!/usr/bin/perl

# usage ./add-album.pl artist album hash

use warnings;
use strict;

use Data::Dumper;
use Storable;

my $store = 'tracks.db';

my $artist = shift;
my $album  = shift;
my $hash   = shift;

my $data = retrieve($store);

print Dumper($data);

if ($artist and $album and $hash) {

    print "adding $album by $artist with mb hash = $hash\n";

    my $index;
    my $count = 1;

    # get the next free index
    until ($index) {
        $index = $count unless $data->{$count};
        $count++;
    }

    $data->{$index}{hash}   = $hash;
    $data->{$index}{artist} = $artist;
    $data->{$index}{name}   = $album;

    store($data, $store) or die "Can't store data in $store\n";

}
