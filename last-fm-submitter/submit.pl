#!/usr/bin/perl

# usage ./submit.pl 3

use warnings;
use strict;
use LWP::Simple;
use XML::LibXML;
use Data::Dumper;
use Net::LastFM::Submission;

my $data = {
    1 => {
        artist => 'Various',
        name => 'Trip Through Sound',
        hash => 'bd9e6277-8f0f-4522-94dd-83b453e72456',
    },
    2 => {
        artist => 'Luomuhappo',
        name => 'Pog-o-matic Pogómen 3000000',
        hash => '1129ac68-d969-4c49-b002-91f7c61620a6',
    },
    3 => {
        artist => 'Various',
        name => 'Trance of the Gods',
        hash => 'ff4a75f5-361a-4788-838c-a75f0f3f00ae',
    },
    4 => {
        artist => 'Prince Jammy & Black Uhuru',
        name => 'Uhuru In Dub',
        hash => '75fb1adb-451b-4362-a6c7-88924141aa21',
    },
    5 => {
        artist => 'Various',
        name => 'In The Red Zone: The Essential Collection Of Classic Dub',
        hash => '4fce3b35-e2ad-4305-a7e7-7a5089738e5b',
    },
    6 => {
        artist => 'Prem Joshua',
        name => 'Dance of Shakti',
        hash => 'e64dba5b-a9d1-4e45-8067-255e728bbc20',
    },
    7 => {
        artist => 'Various',
        name => 'KS01',
        hash => '8a2701c8-a8ef-484e-b6a7-bcbd77c8715c',
    },
    8 => {
        artist => 'X-Dream',
        name => 'Radio',
        hash => '9db64ee1-7039-43b2-8f40-1a637009141d',
    },
    9 => {
        artist => 'Alpha & Omega',
        name => 'Dub Philosophy',
        hash => '3231e959-746e-4cd7-abcf-a4e515efe95a',
    },
    10 => {
        artist => 'Manasseh meets The Equalizer',
        name => 'Dub the Millennium',
        hash => 'b225d0ba-aa10-4b95-9768-6fbb2a3ec193',
    },
    11 => {
        artist => 'Various',
        name => 'Tantrance 4: A Trip to Psychedelic Trance (disc 2)',
        hash => 'd25d914f-0d80-43ba-b8c4-4931019c3f91',
    },
    12 => {
        artist => 'Underworld',
        name => 'Dubnobasswithmyheadman',
        hash => '080ddf87-234f-4dfb-9c37-b57cf4a1c9e8',
    },
    13 => {
        artist => 'Various',
        name => 'It\'s All Gone Pete Tong (disc 2: Night)',
        hash => '09954627-32d0-4636-9269-80b0539699d6',
    },
    14 => {
        artist => 'Various',
        name => 'The Wizardry Of Oz',
        hash => '10a093c1-d99f-41c0-aba0-c88e7bc7326f',
    },
    15 => {
        artist => 'Total Eclipse',
        name => 'Violent Relaxation',
        hash => '99c352eb-daf5-4941-9ee9-83de137e8d09',
    },
    16 => {
        artist => 'Augustus Pablo',
        name => 'Dub Reggae and Roots From the Melodica King',
        hash => 'c9bf02b1-e6e4-4e50-851e-5101908607fd',
    },
    17 => {
        artist => 'Various',
        name => 'White Rhino',
        hash => '32c0ad64-1a71-4edc-bd39-fb3458d74273',
    },
    18 => {
        artist => 'Lee "Scratch" Perry and The Mad Professor',
        name => 'Mystic Warrior & Mystic Warrior Dub',
        hash => 'aac14b35-76f1-4aa7-9749-a8cbfc6960e9',
    },
    19 => {
        artist => 'Juno Reactor',
        name => 'Beyond the Infinite',
        hash => '1300a524-54ec-4f5a-b676-8a746136e25b',
    },
    20 => {
        artist => 'Various',
        name => 'Infinite Excursions 2: Sonic Halucinations',
        hash => 'b2ea10a9-7bea-4a47-a620-9719f520016b',
    },
    21 => {
        artist => 'Various',
        name => 'The Lords of Svek, Volume 1',
        hash => 'c4df8be6-0ebf-40e0-809f-067ea67576f8',
    },
    22 => {
        artist => 'Various',
        name => 'Techno Sessions (disc 1)',
        hash => 'f4091bb7-2646-4c1f-8c6a-524c87da12ed',
    },
    23 => {
        artist => 'Various',
        name => 'Pefecto Fluro Volume 1',
        hash => 'a49fead9-54f8-4e14-af53-950d12397d65',
    },
    24 => {
        artist => 'Depeche Mode',
        name => 'Remixes 81...04 (disc 3)',
        hash => '1960433e-c455-4861-b375-6792d3ca9a50',
    },
    25 => {
        artist => 'Scientist',
        name => 'King of Dub',
        hash => '3f44fc60-5788-4846-a78d-7bb6caee8828',
    },
    26 => {
        artist => 'Scientist',
        name => 'Heavyweight Dub Champion',
        hash => '8a16d7d4-fd66-423e-a0fc-84cd7bbd3f04',
    },
    27 => {
        artist => 'Various',
        name => 'Digital Extacy: A Mindtravelling Trance Experience',
        hash => '44da87b5-d206-49c3-a766-5d78a1d6d8a0',
    },
    27 => {
        artist => 'Depeche Mode',
        name => 'A Broken Frame',
        hash => '01ca78a3-0722-4c7b-971f-e174e5d2d1bc',
    },
};

my $num = shift;
my $end_time = shift;
$end_time = time unless $end_time;
my $xml;
my $submit = 1;

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
        'user'      => 'htaccess',
        'password'  => 'ldapx500',
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
