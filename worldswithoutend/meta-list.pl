#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use DBI;

my $db_name = 'database/lists.sqlite3';

my $dbh = DBI->connect( "dbi:SQLite:$db_name" ) or die "Cannot connect to $db_name: $DBI::errstr";

my $book_ids = $dbh->selectall_arrayref('
    SELECT r.book_id,b.name,a.name AS author,l.score FROM records r INNER JOIN lists l ON r.list_id=l.list_id INNER JOIN books b on r.book_id=b.book_id INNER JOIN authors a ON b.author_id=a.author_id
', { Slice => {} } );

my $books = {};

foreach my $book ( @$book_ids ) {
    $books->{$book->{book_id}}{score} += $book->{score};
    $books->{$book->{book_id}}{name}   = $book->{name};
    $books->{$book->{book_id}}{author} = $book->{author};
}

foreach my $book_id (reverse sort {$books->{$a}{score} <=> $books->{$b}{score}} keys %$books) {
    next if $books->{$book_id}{score} < 30;
    print "$books->{$book_id}{name} ($book_id) - $books->{$book_id}{author} => $books->{$book_id}{score}\n";
}
