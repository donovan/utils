#!/usr/bin/perl

# storable data should look like:
# my $= {
#    1 => {
#       artist => 'Various',
#       name => 'Trip Through Sound',
#       hash => 'bd9e6277-8f0f-4522-94dd-83b453e72456',
#    },
# };

# the hash is from http://musicbrainz.org and is used to retrieve the tracks

# usage ./submit.pl lfm_user lfm_pass album_number

use warnings;
use strict;

use LWP::Simple;
use XML::LibXML;
use Data::Dumper;
use Net::LastFM::Submission;
use Storable;

my $data = retrieve('tracks.db');

my $xml;

my $lfm_user = shift;
my $lfm_pass = shift;
my $num      = shift;
my $end_time = shift;
my $submit   = 1;

$end_time = time unless $end_time;

#1239442971
die "invalid timestamp: $end_time\n" unless ($end_time =~ m{ \d{10} }xms);

my $url = 'http://musicbrainz.org/ws/1/release/';
my $suffix = '?type=xml&inc=tracks';

unless (defined $data->{$num}) {
    print Dumper($data);
    exit;
}

my $fetch_url = $url . $data->{$num}{hash} . $suffix;

print "going to fetch $fetch_url\n";

unless (defined ($xml = get $fetch_url)) {
    die "could not get $fetch_url\n";
}

#print "page = $xml\n";

# Create a parser object
my $parser = XML::LibXML->new();
$parser->recover(1);

# Trap STDERR because the parser is quite verbose and annoying
my $dom;
{
    local *STDERR;
    open STDERR, '>', '/dev/null';
    # parse the page
    $dom = $parser->parse_html_string($xml);
}

# Check that we got a dom object back
die q{Parsing failed} unless defined $dom;

my $track_num = 1;
foreach my $track ( $dom->findnodes(q{//track-list/track}) ) {
    my ($title, $artist);
    foreach my $child ($track->childNodes) {
        my $name = $child->nodeName;
        if ($name eq 'title') {
            $title = $child->textContent;
            $data->{$num}{tracks}{$track_num}{title} = $child->textContent;
        }
        elsif ($name eq 'artist') {
            foreach my $grandchild ($child->childNodes) {
                my $name = $grandchild->nodeName;
                if ($name eq 'name') {
                    $artist = $grandchild->textContent;
                    $data->{$num}{tracks}{$track_num}{artist} = $grandchild->textContent;
                }
            }
        }
        elsif ($name eq 'duration') {
            $data->{$num}{tracks}{$track_num}{duration} = $child->textContent;
        }
    }
    print "$artist/$title\n";
    $track_num++;
}
print Dumper($data->{$num});

if ($submit) {
    my $submission = Net::LastFM::Submission->new(
        'user'      => $lfm_user,
        'password'  => $lfm_pass,
    );

    $submission->handshake;

    my $cumulative = 0;
    foreach my $track (reverse sort keys %{$data->{$num}{tracks}}) {
        my $artist = $data->{$num}{tracks}{$track}{artist} ||= $data->{$num}{artist};
        my $title = $data->{$num}{tracks}{$track}{title};
        my $secs = sprintf("%.0f", $data->{$num}{tracks}{$track}{duration} / 1000);
        my $sub_time = $end_time - $secs - $cumulative;
        print "submitng a = $artist n = $title d = $sub_time\n";
        unless (defined $artist and defined $title and defined $secs) {
            die "cannot submitt, do not have the required into\n";
        }
        $submission->submit(
            'artist' => $artist,
            'title'  => $title,
            'time'   => $sub_time, # 10 minutes ago
        );
        $cumulative += $secs;
    }
}
