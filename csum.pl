#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'recursion';
# csum.pl: print menu item combinations whose total matches the target price
#
# usage: perl csum.pl < <input file>
#     <input file> format:
#         <target price>
#         <menu item 0>
#         ...
#         <menu item n>
#     <menu item> format:
#         <item name>,<item price>
#     <price> format: $<dollars>.<cents>
#
my ($file) = @ARGV;

unless (
       $file
    && $file ne '-h' # DONE: add -h command line option to print usage information
) {
    die "usage: $0 <input file>\n";
}

my $candidates = [];
my @combos     = ();
my $fh         = undef;
my $target     = 0;

unless (open($fh, '<', $file)) {
    die "Could not read file $file: $!\n";
}

while (<$fh>) {
   chomp;
   push @$candidates, $_ if (!/^\s*$/); #skip blank lines
}

close $fh;

$target = shift @$candidates;

print qq{
target order price:
    $target

menu item candidates:
    } . join("\n    ",@$candidates) . "\n";

# TODO: add input validation subroutine and exit with message on error

@$candidates = map { [ split(",", $_) ] } @$candidates; #split candidate name,price

map { $_->[1] =~ s/\D//g } @$candidates; #and convert price to integer
$target       =~ s/\D//g; #convert price to integer
my $n         = $#$candidates;

rsum($target, 0, {}); #find menu item combinations whose total is target

print "\norders matching the target price:\n";
# DONE: improve output format: include item count rather than repeating items
my $combono = 0;
# print orders!
foreach my $combo (@combos) {
    print ++$combono . ': ';
    print join(', ',
        map { '(' . $combo->{$_} . ') ' . $_ }
            grep { $combo->{$_} } sort { $a cmp $b } keys %$combo) . " \n";
}

sub rsum {
    # rsum: recursive subroutine to create target price orders
    # $candidates: array of candidate arrays [ <item name>, <item price in cents>]
    # $target: target sum - format <target total cost in cents>
    # $index: index of current candidate
    # $subhash: hash of running orders
    my ($target, $index, $subhash) = @_;

    # TODO: add recursion level limit and exit when exceeded

    if ($target > 0) {
        foreach my $cand (@$candidates[$index..$n]) {
           # DONE: improve output format: include item count rather than repeating items
           #    this change also makes this script run over 10X faster!!!
           $subhash->{ $cand->[0] } += 1;
           
           rsum( $target - $cand->[1], $index++, $subhash); #keep looking

           $subhash->{ $cand->[0] } -= 1;
        }
    } elsif ($target == 0) {
        push @combos, { %$subhash };
    }
}
