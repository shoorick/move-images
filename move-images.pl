#!/usr/bin/perl -wl

=head1 NAME

move-images - move images and group them together.

=head1 DESCRIPTION

Move images from memory card to HDD:
remove leading letters from its names, lowercase these names,
attempt to create subfolder named as I<year>/I<month>/I<day>
and move file into this subfolder and change file mode of moved file.

=head1 USAGE

    ./move-images [ options ] [ path-to-memory-card ]

=head1 TUNING

All parameters placed in lines from 12 to 17 can be changed to proper values.

=head1 AUTHOR

Alexander Sapozhnikov
L<< http://shoorick.ru/ >>
L<< E<lt>shoorick@cpan.orgE<gt> >>

=head1 LICENSE

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use File::Find;
use File::Path qw(make_path);
use File::Copy;
use Getopt::Long;
use Image::ExifTool qw(:Public);
use Desktop::Notify;

map { $_ = '' } my (
    $need_help, $need_manual, $verbose
);

GetOptions(
    'help|?'  => \$need_help,
    'manual'  => \$need_manual,
    'verbose' => \$verbose,
);

use Pod::Usage qw( pod2usage );
pod2usage('verbose' => 2)
    if $need_manual;
# print help message when required arguments are omitted
pod2usage(1)
    if $need_help;

# You can change these variables

my $PATH_SRC  = shift @ARGV || '/media/nikon'; # path to memory card
   $PATH_SRC .= '/DCIM';

my $PATH_DST  = $ENV{'HOME'} . '/photo'; # path to destination. Don't use ~ for your homedir
my $PRECISION = 2;    # 0 for year .. 5 for second
my $MODE      = 0644; # for chmod


# Don't touch the rest of file

find( \&wanted, $PATH_SRC );

# Say when ended
my $notify = Desktop::Notify->new();
my $notification = $notify->create(
    'summary' => 'Photos was moved',
    'body'    => 'You can unmount your memory card',
    'timeout' => 5000,
);
$notification->show();
$notification->close();

sub wanted {
    return unless /\.(3gp|avi|cr2|crw|dng|jpe?g|mov|nef|raf|raw|tiff?)/i;
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
