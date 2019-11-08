#!/usr/bin/perl
use warnings; use strict; use File::Copy;
use Image::ExifTool qw(:Public);

# Takes a bunch of .gif files as input and sorts them into new directories based on whether or not the files contain more 
# than a single frame. Requires Image::ExifTool (install with cpan or cpanm) and File::Copy, which should be installed by 
# default.

my $usage = "perl filtergif.pl ./*\n";
die $usage unless @ARGV;

system "mkdir -p ./animated && mkdir -p ./static";

while (my $file = shift (@ARGV)) {
    my $info = ImageInfo($file);

    if (exists ($$info{FrameCount}) && $$info{FrameCount} >= 1) { 
        move ("$file", './animated/');
        next;
    } 
    move ("$file", './static/');
}
