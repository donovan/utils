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
use 5.010;
use strict;
use warnings;

use Pod::Usage;
use Getopt::Long qw(GetOptions);
#use LWP::Simple;
use XML::LibXML;
use Data::Dumper;
use WWW::Mechanize;
#use File::Slurp;
use Term::ReadLine;

my(%opt);

if(!GetOptions(\%opt, 'help|?', 'debug|d', 'type|t=s', 'list|l=s')) {
    pod2usage(-exitval => 1,  -verbose => 0);
}

pod2usage(-exitstatus => 0, -verbose => 1) if $opt{help};

my @lists_to_fetch;

my @lists = qw(
    women_winners
    classics_of_sf
    sf_masterworks
    fantasy_masterworks
    isfdb_balanced
    yearsbestsf
    locus_bestsf
    top_noms
    pringle_sf
);

# work out which list we want
if ($opt{list}) {
    if ($opt{list} eq 'all') {
        @lists_to_fetch = @lists;
    }
    elsif ( grep { $opt{list} eq $_ } @lists ) {
        push @lists_to_fetch, $opt{list};
    }
    else {
        die 'please choose a valid list from this list: ' . join(', ', @lists);
    }
}
else {
    # should we defualt to all?
    push @lists_to_fetch, 'sf_masterworks';
}

my $books = {};

my $mech = WWW::Mechanize->new;

$mech->get('http://www.worldswithoutend.com/mbbs22/logon.asp');

$mech->submit_form(
    with_fields => {
        postusername => 'username',
        #postpassword => read_password('Password: '),
        postpassword => 'password',
    },
);

foreach my $list (@lists_to_fetch) {

    my $url = 'http://www.worldswithoutend.com/lists_' . $list . '.asp';

    print "fetching $url\n";
    $mech->get($url);

    my $page = $mech->content;

    die "Couldn't get $url!" unless defined $page;

    # Create a parser object
    my $parser = XML::LibXML->new();
    $parser->recover(1);

    # Trap STDERR because the parser is quite verbose and annoying
    my $dom;
    {
        local *STDERR;
        open STDERR, '>', '/dev/null';
        # parse the page
        $dom = $parser->parse_html_string($page);
    }

    # Check that we got a dom object back
    die q{Parsing failed} unless defined $dom;

    foreach my $title_node ( $dom->findnodes(q{//div[@class='awardslisting']/p[@class='title']}) ) {

        # get the related nodes
        my $author_node = $title_node->nextNonBlankSibling();
        my $top_node    = $title_node->parentNode->parentNode->parentNode->previousNonBlankSibling()->previousNonBlankSibling()->firstChild;
        my $color_node  = $title_node->parentNode->parentNode->parentNode->parentNode->parentNode;

        # get the node contents
        my $title  = $title_node->textContent;
        next if $title eq '';
        my $top    = $top_node->textContent;
        my $author = $author_node->textContent;
        my $color  = $color_node->getAttribute('bgcolor');

        # get the number and date out the top node
        #84. (1955)
        my ($number, $date);
        if ( $top =~ m{ ( \d{1,3} ) \. \s+ \( ( \d{4} ) \) }xms ) {
            $number = $1;
            $date   = $2;
        }
        $books->{$list}{$number}{title}  = $title;
        $books->{$list}{$number}{author} = $author;
        $books->{$list}{$number}{date}   = $date;

        # work out if the book has been read based on the color
        if ($color eq '#ffffff' or $color eq '#fffab8') {
            $books->{$list}{$number}{read} = 0;
            $books->{$list}{totals}{unread}++;
            $books->{$list}{totals}{total}++;
        }
        elsif ($color eq '#cef0bd' or $color eq '#c7e1fd') {
            $books->{$list}{$number}{read} = 1;
            $books->{$list}{totals}{read}++;
            $books->{$list}{totals}{total}++;
        }
        else {
            die "we got an unrecognised color, please fix";
        }
    }
}

print Dumper($books) . "\n" if $opt{debug};

print "\n-------------------------------------------------\n";

# default report = summary?
foreach my $list (keys %$books) {
    $books->{$list}{totals}{read} = 0 unless $books->{$list}{totals}{read};
    $books->{$list}{totals}{unread} = 0 unless $books->{$list}{totals}{unread};
    my $percentage_read   = sprintf("%.0f", ( $books->{$list}{totals}{read}   / $books->{$list}{totals}{total} ) * 100 );
    my $percentage_unread = sprintf("%.0f", ( $books->{$list}{totals}{unread} / $books->{$list}{totals}{total} ) * 100 );
    print $list . ', total = ' . $books->{$list}{totals}{total} . ' read = ' . $books->{$list}{totals}{read} . ' (' . $percentage_read . '%) unread = ' . $books->{$list}{totals}{unread} . '(' . $percentage_unread . "%)\n";
}


sub read_password {
    my ($prompt) = @_;

    my $term = Term::ReadLine->new('worldswithoutend');

    die 'Need Term::ReadLine::Gnu installed' unless $term->ReadLine eq 'Term::ReadLine::Gnu';

    $term->{redisplay_function} = $term->{shadow_redisplay};
    my $password = $term->readline($prompt);
    $term->{redisplay_function} = undef;

    return $password;
}

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
