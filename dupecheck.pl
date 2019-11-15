#!/usr/bin/perl
use warnings; use strict;

# Identify and remove duplicate copies of files from a directory. Duplicates are, for now,
# identified via sha256 checksum. This script takes a directory as input.

my $usage = "dupecheck.pl ./";
die $usage unless @ARGV;

my $extension = 'gif';
my $directory = shift (@ARGV);

print "Identifying \.$extension\'s\n";
open my $fileout, ">", "./files.temp" or die "Can't open files.temp\n";
print $fileout `find $directory -type f -iregex ".*\.$extension\$"`;
close $fileout;

my $filecount = `wc -l ./files.temp`;
chomp ($filecount);
$filecount =~ /(^\d+)/;
$filecount = $1;

print "Calculating checksums\n";
open my $filein, "<", "./files.temp" or die "Can't open files.temp\n";
open my $checkout, ">", "./checksums.temp" or die "Can't open checksum.temp\n";

while (my $line = <$filein>) {
    chomp ($line);
    # Escape problematic characters
    $line =~ s/\\/\\\\/g;
    $line =~ s/\&/\\\&/g;
    $line =~ s/\(/\\\(/g;
    $line =~ s/\)/\\\)/g;
    $line =~ s/\'/\\\'/g;
    $line =~ s/\$/\\\$/g;
    $line =~ s/ /\\\ /g;
    print $checkout `sha256sum $line`;    
}
close $filein;
close $checkout;

print "Identifying and removing duplicates\n";
open my $checkin, "<", "./checksums.temp" or die "Can't open checksums.temp\n";
my %checkhash;
my $dupecounter = 0;
while (my $line = <$checkin>) {
    chomp ($line);
    $line =~ m/(.{64})\s\s(.*)/;
    my $checksum = $1;
    my $filename = $2;

    # Escape problematic characters
    $filename =~ s/\\/\\\\/g;
    $filename =~ s/\&/\\\&/g;
    $filename =~ s/\(/\\\(/g;
    $filename =~ s/\)/\\\)/g;
    $filename =~ s/\'/\\\'/g;
    $filename =~ s/\$/\\\$/g;
    $filename =~ s/ /\\\ /g;

    if (exists($checkhash{$checksum})) {
        $dupecounter++;
        system "rm $filename";
    }
    else {
        $checkhash{$checksum} = undef; 
    }
}
close $checkin;

print "$dupecounter out of $filecount $extension files were removed as dupes\n";

system "rm ./files.temp";
system "rm ./checksums.temp";
