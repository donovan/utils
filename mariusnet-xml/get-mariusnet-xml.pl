#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
use XML::LibXML;
use Data::Dump qw(dump);

my $url = 'http://www.mariusnet.com/mnetdata/ServerStatus.xml';
my $page;

unless (defined ($page = get $url)) {
        die "could not get $url\n";
}

# Create a parser object
my $parser = XML::LibXML->new();
$parser->recover(1);

# Trap STDERR because the parser is quite verbose and annoying
my $dom;
{
    local *STDERR;
    open STDERR, '>', '/dev/null';
    # parse the page
    $dom = $parser->parse_string($page);
}

# Check that we got a dom object back
die q{Parsing failed} unless defined $dom;


#  <currentplayers>
#    <player>
#      <clienttype>Myth: SB</clienttype>
#      <roomname>Shiver</roomname>
#      <playername>Blorg</playername>
#      <login>blorg</login>
#      <playerid>23819</playerid>
#      <primarycolors>0F0229</primarycolors>
#      <secondarycolors>4C4802</secondarycolors>
#      <rankicon>13</rankicon>
#      <icon>30</icon>
#      <afk>0</afk>
#      <ingame>1</ingame>
#    </player>

my $count = {};
my $players = [];
my $games = [];

foreach my $player ( $dom->findnodes(q{//currentplayers/player}) ) {
    my $ref = {};
    foreach my $node ($player->nonBlankChildNodes()) {
        my $content = $node->textContent;
        my $tag = $node->localname;
        $ref->{$tag} = $content;
    }
    push @{ $players }, $ref;
}

foreach my $game ( $dom->findnodes(q{//currentgames/game}) ) {
    my $ref = {};
    foreach my $node ($game->nonBlankChildNodes()) {
        my $content = $node->textContent;
        my $tag = $node->localname;
        $ref->{$tag} = $content;
    }
    push @{ $games }, $ref;
}

foreach my $player (@{ $players }) {
    next unless $player->{clienttype} eq 'Myth: SB';
    $count->{player}++;
    if ($player->{ingame}) {
        $count->{ingame}++;
    }
    else {
        $count->{inlobby}++;
    }
}

foreach my $game (@{ $games }) {
    next unless $game->{clienttype} eq 'Myth: SB';
    $count->{games}++;
    if ($game->{running}) {
        if ($game->{coop}) {
            $count->{game_running_coop} += $game->{currentplayers};
        }
        else {
            $count->{game_running_multi} += $game->{currentplayers};
        }
    }
    else {
        if ($game->{coop}) {
            $count->{game_waiting_coop} += $game->{currentplayers};
        }
        else {
            $count->{game_waiting_multi} += $game->{currentplayers};
        }
    }
    if ($game->{hostobserver}) {
        if ($game->{coop}) {
            $count->{hostobserver_coop}++;
        }
        else {
            $count->{hostobserver_multi}++;
        }
    }
}

print dump($games) . "\n";
print dump($players) . "\n";
print dump($count) . "\n";

#print $dom->toString();

