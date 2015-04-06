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

=head1 OPTIONS

=over 4

=item B<-s>, B<--src>, B<--source>=C<PATH>

Use C<PATH> for source instead of (first-argument)/DCIM

=item B<-d>, B<--dst>, B<--destination>=C<PATH>

Use C<PATH> for destination instead of ~/photo/*

=item B<-p>, B<--precision>=C<LEVEL>

Set precision for grouping of photos.
Allowed values are from C<0> for year
through default value C<2> for day up to C<5> for second.

=item B<--chmod>=C<MODE>

Change mode of processed files to C<MODE>.

=item B<-k>, B<--keep-prefix>

Do not remove non-digital prefixes from names of files.

=item B<-?>, B<-h>, B<--help>

Print a brief help message and exit.

=item B<-m>, B<--man>, B<--manual>

Prints the manual page and exit.

=item B<-v>, B<--verbose>

Be verbose.

=back

=head1 LEGACY TUNING

Tuning by source code editing is B<deprecated> now.
Use options instead (see above).

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
    $need_help, $need_manual, $verbose,
    $path_src, $keep_prefix,
);
my $path_dst  = $ENV{'HOME'} . '/photo'; # path to destination. Don't use ~ for your homedir
my $precision = 2;    # 0 for year .. 5 for second
my $mode      = 0644; # for chmod

GetOptions(
    'help|?'  => \$need_help,
    'manual'  => \$need_manual,
    'verbose' => \$verbose,

    'precision:i'       => \$precision,
    'source|src:s'      => \$path_src,
    'destination|dst:s' => \$path_dst,
    'chmod:s'           => \$mode,
    'keep_prefix'       => \$keep_prefix,
);

use Pod::Usage qw( pod2usage );
pod2usage('verbose' => 2)
    if $need_manual;
# print help message when required arguments are omitted
pod2usage(1)
    if $need_help;

unless ( $path_src ) {
   $path_src  = shift @ARGV || '/media/nikon'; # path to memory card
   $path_src .= '/DCIM';
}

find( \&wanted, $path_src );

# Say when ended
my $notify = Desktop::Notify->new();
my $notification = $notify->create(
    'summary' => 'Photos was moved',
    'body'    => 'You can unmount your memory card',
    'timeout' => 5000,
);
$notification->show();
$notification->close();

exit;


sub wanted {
    return unless /\.(3gp|avi|cr2|crw|dng|jpe?g|mov|nef|raf|raw|tiff?)/i;
    my $new_name = lc $_;
       $new_name =~ s/^\D+// unless $keep_prefix;

    my $info = ImageInfo( $File::Find::name );
    my @date = split /\D+/, $info->{'DateTimeOriginal'};
      $#date = $precision;
    my $new_dir = join '/', $path_dst, @date;

    make_path $new_dir
        unless -d $new_dir;

    my $new_path = "$new_dir/$new_name";

    -d  $new_dir
    and move $File::Find::name, $new_path
    and chmod $mode, $new_path
    and print "$File::Find::name => $new_path";
} # sub wanted
