#!/usr/bin/perl
use strict; use warnings;

# This script can be used to extract files of a specific type from the geocities tar archive.
# Use the folders from one of the primary directories (NUMBERS, LOWERCASE, or UPPERCASE) as
# input, and change $extension to any extension you can think of. This should reduce the risk
# extracting anything you don't want from the archives, as there's quite a lot of spam, junk
# and sketchy old .exe's. Note: the extensionless tar archives must first be extracted from the 
# .7z archives for this script to work. This script will not overwrite files that have already 
# been extracted.

my $extension = ".gif";

my $usage = "perl extract.pl ./geocities*\n";
die $usage unless @ARGV;

while (my $directory = shift (@ARGV)) {

    if ($directory =~ m/^\.\//) {
        $directory =~ s/^\.\///;
    } 

    my $filelist = `tar --list -f ./$directory/$directory | grep -P "$extension\$"`;
    print "$directory: ";

    if ($filelist eq "") {
        print "This archive contains no $extension\'s\n";
    }
    else {
        my @splitfilelist = split /^/, $filelist;
        foreach (@splitfilelist) {
            $_ =~ s/\n//g;
            $_ =~ s/ /\\\ /g;
            system "tar -xf ./$directory/$directory --skip-old-files -C ./$directory $_";
        }
        print "Successfully extracted $extension\'s\n";
    }
}
