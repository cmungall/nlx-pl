#!/usr/bin/perl
while(<>) {
    s/ (oen|nlx_anat|nlx|birnlex|nifext):/ NIFSTD:$1_/g;
    print;
}
