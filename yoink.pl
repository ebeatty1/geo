#!/usr/bin/perl
use warnings; use strict; use File::Copy;

# Move all files that match a pattern from a directory and all subdirectories to a new folder
# without overwriting any files or triggering any errors in Bash. This is really only useful
# when dealing with massive numbers of files, as there are better ways to do this when dealing
# with fewer.

my $usage = "yoink.pl ./";
die $usage unless @ARGV;

my $extension = 'gif';
my $directory = shift (@ARGV);

print "Identifying \.$extension\'s\n";
open my $out, ">", "./list.temp" or die "Can't open list.temp\n";
print $out `find $directory -type f -iregex ".*\.$extension\$"`;
close $out;

my $filecount = `grep -c -P "\.$extension\$" ./list.temp`;
chomp $filecount;
print "There are $filecount \.$extension\'s in $directory and the subdirectories of $directory\n";

open my $in, "<", "./list.temp" or die "Can't open list.temp\n";
system "mkdir -p ./$extension/";
print "Copying all $filecount \.$extension\'s to \.\/$extension\/";

# This part ensures no files get overwritter by renaming files following a pattern that
# doesn't interfere with file extensions.
while (my $line = <$in>) {
    chomp $line;
    $line =~ m/([^\/]*$)/;
    my $filename = $1;
    
    my $suffix = 0;
    while (-e "./$extension/$filename") {
        $suffix++;
        if ($filename =~ m/\~\d+\~\.$extension$/) {
            $filename =~ s/\~\d+\~/\~$suffix\~/;
        }
        else {
            $filename =~ s/\.$extension//;
            $filename = $filename."\~$suffix\~"."\.$extension";
        }
    }
    move ("$line", "./$extension/$filename");
    print "Copied $line as $filename\n";
}
close $in;

system "rm ./list.temp";
