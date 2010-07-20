#!/usr/bin/perl -wl

use strict;
use File::Find;
use File::Path qw(make_path);
use File::Copy;
use Image::ExifTool qw(:Public);

# You can change these variables

my $PATH_SRC  = '/media/NIKON D40/DCIM'; # path to memory card
my $PATH_DST  = $ENV{'HOME'} . '/photo'; # path to destination. Don't use ~ for your homedir
my $PRECISION = 2;    # 0 for year .. 5 for second
my $MODE      = 0644; # for chmod

# Don't touch the rest of file

find( \&wanted, $PATH_SRC );

sub wanted {
    return unless /\.jpg/i;
    my $new_name = lc $_;
       $new_name =~ s/^\D+//;

    my $info = ImageInfo( $File::Find::name );
    my @date = split /\D+/, $info->{'DateTimeOriginal'};
      $#date = $PRECISION;
    my $new_dir = join '/', $PATH_DST, @date;

    make_path $new_dir
        unless -d $new_dir;

    my $new_path = "$new_dir/$new_name";

    -d  $new_dir
    and move $File::Find::name, $new_path
    and chmod $MODE, $new_path
    and print "$File::Find::name => $new_path";
} # sub wanted

=head1 DESCRIPTION

Move images from memory card to HDD:
remove leading letters from its names, lowercase these names,
attempt to create subfolder named as I<year>/I<month>/I<day>
and move file into this subfolder and change file mode of moved file.

=head1 USAGE

 ./move-images

=head1 TUNING

All parameters placed in lines from 11 to 14 can be changed to proper values.

=head1 AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru/ >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=head1 LICENSE

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
