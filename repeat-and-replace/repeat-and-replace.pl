#!/usr/bin/perl

use strict;
use warnings;

use IO::Prompt;

# to use this script you need to add a line like:
# alias r='fc -ln -1 | /path/to/repeat-and-replace.pl'
# to your ~/.bashrc

# you can then repeat the last command and replace the first arg eg:
# $ git diff filename
# $ r add
# executing 'git add filename'

# TODO
# add interactive support so you need to press enter before executing command
# add print/echo support where it just echos the command
# add support for more than one replacement arg
# add foo=bar replacement syntax

my ($replace, $num, $remove, $interactive, $print, @other_args);

#replace is always first
$replace = shift;

# get the rest of the args
while (@ARGV) {
    my $arg = shift @ARGV;
    $num = $arg if $arg =~ m{ \A \d+ \z }xms;
    if ($arg =~ m{ \A - (\d+) \z }xms) {
        $remove = $1;
    }
    elsif ($arg =~ m{ \A - i \z }xms) {
        $interactive++;
    }
    elsif ($arg =~ m{ \A - p \z }xms) {
        $print++;
    }
}

# the default is to replace the first argument with replace
$num ||= 1;

while (<>) {
    chomp;
    my @args = split;
    $args[$num] = $replace;
    splice @args, $remove, 1 if $remove;
    my $cmd = join(" ", @args);
    if ($interactive) {
        while( prompt "next: " ) {
            print "You said '$_'\n";
        }
        #print "got $ret\n";
        #if (prompt("execute '$cmd' y/n ", -y)) {
        #    system(@args) == 0 or die "system @args failed: $?";
        #}
        #else {
        #    print "ok, bye\n";
        #}
    }
    elsif ($print) {
        print "$cmd\n";
    }
    else {
        print "executing '$cmd'\n";
        system(@args) == 0 or die "system @args failed: $?";
    }
}
