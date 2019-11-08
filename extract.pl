#!/usr/bin/perl
use strict; use warnings;

# This script can be used to extract files of a specific type from the geocities tar archive.
# Use the folders from one of the primary directories (NUMBERS, LOWERCASE, or UPPERCASE) as
# input, and change $extension to any extension you can think of. This should reduce the risk
# extracting things you don't want from the archives, as there's quite a lot of spam, junk
# and sketchy old .exe's. Note: the extensionless tar archives must first be extracted from the 
# .7z archives for this script to work. 

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
        $filelist =~ s/\n/ /g;
        system "tar -xf ./$directory/$directory -C ./$directory $filelist";
        print "Successfully extracted $extension\'s\n";
    }
}
