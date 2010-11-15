#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
use XML::LibXML;
use Data::Dumper;

my @lists = qw(
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

my $books = {};

foreach my $list (@lists) {
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
    foreach my $node ( $dom->findnodes(q{//tr/td[3]/table/tr/td/div[@class='awardslisting']/p}) ) {
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

#print Dumper($books) . "\n";

foreach my $book (reverse sort { $books->{$a}{count} <=> $books->{$b}{count} } keys %$books) {
    next if $books->{$book}{count} < 2;
    print "$books->{$book}{count}: $book - $books->{$book}{author}\n";
}
