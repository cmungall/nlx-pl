#!/usr/bin/perl
while(<>) {
    s/ (oen|nlx_anat|nlx|birnlex|nifext):/ NIF_GrossAnatomy:$1_/g;
    print;
}
