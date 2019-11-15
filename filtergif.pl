#!/usr/bin/perl
use warnings; use strict; use File::Copy;
use Image::ExifTool qw(:Public);

# Takes a bunch of .gif files as input and sorts them into new directories based on whether or 
# not the files contain more than a single frame. Requires Image::ExifTool (install with cpan 
# or cpanm) and File::Copy, which should be installed by default.

my $usage = "perl filtergif.pl ./\n";
die $usage unless @ARGV;

my $directory = shift (@ARGV);
system "mkdir -p ./animated && mkdir -p ./static";

print "Identifying \.gif\'s\n";
open my $out, ">", "./list.temp" or die "Can't open list.temp\n";
print $out `find $directory -type f -regex ".*\.gif\$"`;
close $out;

my $filecount = `grep -c -P "\.gif\$" ./list.temp`;
chomp $filecount;
print "There are $filecount \.gif\'s in $directory";

open my $in, "<", "./list.temp" or die "Can't open list.temp\n";
print "Moving all $filecount \.gif\'s";

while (my $line = <$in>) {
    chomp ($line);
    my $info = ImageInfo($line);

    if (exists ($$info{FrameCount}) && $$info{FrameCount} >= 1) { 
        copy ("$line", './animated/');
        next;
    } 
    copy ("$line", './static/');
}
close $in;
system "rm ./list.temp";
