#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
use XML::LibXML;
use Data::Dumper;

my $books = {};

my $url = 'http://www.worldswithoutend.com/lists_sf_masterworks.asp';

print "fetching $url\n";
my $page = get($url);

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

    # get the node contents
    my $title  = $title_node->textContent;
    my $top    = $top_node->textContent;
    my $author = $author_node->textContent;

    # get the number and date out the top node
    #84. (1955)
    my ($number, $date);
    if ( $top =~ m{ ( \d{1,3} ) \. \s+ \( ( \d{4} ) \) }xms ) {
        $number = $1;
        $date   = $2;
    }
    $books->{$number}{title}  = $title;
    $books->{$number}{author} = $author;
    $books->{$number}{date}   = $date;
}

print Dumper($books) . "\n";
