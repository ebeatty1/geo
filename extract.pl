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

# The following variable is equivalent to 128 KiB, the normal size of the Linux system variable
# MAX_ARG_STRLEN. This and the following variable based on it are used to keep Bash from 
# giving 'Argument list too long' errors, which result in aborted extractions.
my $maxlenbytes = 131072;

# The following calculation makes the assumptions that all characters are encoded in UTF-8 at 
# the max possible size (4 bytes) and that the base command (see below) is 74 characters in length.
# Base Command: "tar -xf ./geocities-X-Y/geocities-X-Y --skip-old-files -C ./geocities-X-Y "
my $maxlenchars = int (($maxlenbytes / 4) - 74);

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
        $filelist =~ s/ /\\\ /g;
        $filelist =~ s/\n/ /g;
        if (length ($filelist) <= $maxlenchars) {
            print "Extracting $extension\'s with a single command ($maxlenchars > ".length ($filelist).")\n";
            system "tar -xf ./$directory/$directory --skip-old-files -C ./$directory $filelist";
        }
        else {
            print "Extracting $extension\'s with multiple commands ($maxlenchars < ".length ($filelist).")\n";
            my $listlen = $maxlenchars;

            while (length ($filelist) > $maxlenchars) {
                my $subfilelist = substr $filelist, 0, $listlen;
                if ($subfilelist =~ m/\\\ $/) {
                    $listlen = $listlen - 1;
                }
                elsif ($subfilelist =~ m/\s$/) {   
                    system "tar -xf ./$directory/$directory --skip-old-files -C ./$directory $subfilelist";
                    $filelist = substr $filelist, $listlen;
                    $listlen = $maxlenchars;
                }
                else {
                    $listlen = $listlen - 1;
                }
            }
            system "tar -xf ./$directory/$directory --skip-old-files -C ./$directory $filelist";
        }
    }
}
