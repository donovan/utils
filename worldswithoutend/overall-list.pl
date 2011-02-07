#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
use XML::LibXML;
use Data::Dumper;

my @award_lists = qw(
    nebula
    hugo
    bsfa
    locus-sf
    locus-f
    campbell
    bfs
    wfa
    pkd
    clarke
);

my @other_lists = qw(
    classics_of_sf
    sf_masterworks
    fantasy_masterworks
    isfdb_balanced
    locus_bestsf
    pringle_sf
);

my $books = {};

foreach my $list (@award_lists) {
    my $url = 'http://worldswithoutend.com/books_' . $list . '_index.asp?Page=1&PageLength=100';

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

    my $last_title;
    foreach my $node ( $dom->findnodes(q{//div[@class='awardslisting']/p}) ) {
        my $content = $node->textContent;
        my $class = $node->getAttribute('class');
        $content =~ s{ \A \s+ }{}xms;
        $content =~ s{ \s+ \z }{}xms;
        if ($content) {
            #print "content = '$content' class = '$class'\n";
            if ($class eq 'title') {
                $books->{$content}{count}++;
                $last_title = $content;
            }
            elsif ($class eq 'author') {
                $books->{$last_title}{author} = $content;
            }
        }
    }
}

foreach my $list (@other_lists) {

    my $url = 'http://www.worldswithoutend.com/lists_' . $list . '.asp';

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
        my $color_node  = $title_node->parentNode->parentNode->parentNode->parentNode->parentNode;

        # get the node contents
        my $title  = $title_node->textContent;
        next if $title eq '';
        my $top    = $top_node->textContent;
        my $author = $author_node->textContent;
        my $color  = $color_node->getAttribute('bgcolor');

        $books->{$title}{count}++;
        $books->{$title}{author} = $author;
    }
}
#print Dumper($books) . "\n";

foreach my $book (reverse sort { $books->{$a}{count} <=> $books->{$b}{count} } keys %$books) {
    next if $books->{$book}{count} < 4;
    print "$books->{$book}{count}: $book - $books->{$book}{author}\n";
}
