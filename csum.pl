#!/usr/bin/env perl

use strict;
use warnings;

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
my ($candidates, $target);

# TODO: add -h command line option to print usage information

while (<STDIN>) {
   chomp;
   push @$candidates, $_ if (!/^\s*$/); #skip blank lines
}

$target = shift @$candidates; 
print "\ntarget order price:\n    $target\n";
print "\nmenu item candidates:\n    ";
print join("\n    ",@$candidates) . "\n";

# TODO: add input validation subroutine and exit with message on error

$target =~ s/\D//g; #convert price to integer
@$candidates = map { [ split(",", $_) ] } @$candidates; #split candidate name,price 
map { $_->[1] =~ s/\D//g } @$candidates; #and convert price to integer

print "\norders matching the target price:\n";
rsum( $candidates, $target, 0, [] ); #print menu item combinations whose total is target

sub rsum {
    # rsum: recursive subroutine to print subsets of candidates whose total is target
    # $candidates: array of candidate arrays [ <item name>, <item price in cents>]
    # $target: target sum - format <target total cost in cents>
    # $index: index of current candidate
    # $sublist: array of current sublist
    my ( $candidates, $target, $index, $sublist ) = @_;

    # TODO: add recursion level limit and exit when exceeded

    if ( $target == 0 ) { #match found
        # TODO: improve output format: include item count rather than repeating items
        my $subset = join(', ', map {$_->[0]} @$sublist);
        print "    $subset\n";
        return;
    }

    if ( $target < 0 ) { #match not found
        return;
    }

    for (my $i = $index; $i < @$candidates; $i++) { #check for match
        push @$sublist, $candidates->[$i]; # add candidate to list
        rsum( $candidates, $target - $candidates->[$i]->[1], $i, $sublist ); #keep looking 
        pop @$sublist; #remove last candidate and keep looking
    }
}
