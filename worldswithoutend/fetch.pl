#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use WWW::Mechanize;
use File::Slurp;
use Term::ReadLine;

my $mech = WWW::Mechanize->new;

$mech->get('http://www.worldswithoutend.com/mbbs22/logon.asp');

$mech->submit_form(
    with_fields => {
        postusername => 'username',
        #postpassword => read_password('Password: '),
        postpassword => 'password',
    },
);

#write_file('test1.html', $mech->content);

$mech->get('http://www.worldswithoutend.com/lists_sf_masterworks.asp');

#write_file('test2.html', $mech->content);

sub read_password {
    my ($prompt) = @_;

    my $term = Term::ReadLine->new('worldswithoutend');

    die 'Need Term::ReadLine::Gnu installed' unless $term->ReadLine eq 'Term::ReadLine::Gnu';

    $term->{redisplay_function} = $term->{shadow_redisplay};
    my $password = $term->readline($prompt);
    $term->{redisplay_function} = undef;

    return $password;
}
