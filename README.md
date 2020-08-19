move-images
===========

Move images and group them together

Description
-----------

Move images from removable memory card to HDD:
* remove leading letters from its names,
* lowercase these names,
* attempt to create subfolder named as `year`/`month`/`day`
* move file into this subfolder
* and then change file mode of moved file.

Usage
-----

    ./move-images.pl [ options ] [ path-to-memory-card ]

Options
-------

**-s**, **--src**, **--source**=`PATH`

Use `PATH` for source instead of (first-argument)/DCIM

**-d**, **--dst**, **--destination**=`PATH`

Use `PATH` for destination instead of ~/photo/*

**-p**, **--precision**=`LEVEL`

Set precision for grouping of photos.
Allowed values are from `0` for year
through default value `2` for day up to `5` for second.

**--chmod**=`MODE`

Change mode of processed files to `MODE`.

**-k**, **--keep-prefix**

Do not remove non-digital prefixes from names of files.

**-?**, **-h**, **--help**

Print a brief help message and exit.

**-m**, **--man**, **--manual**

Prints the manual page and exit.

**-v**, **--verbose**

Be verbose. Show names of processed files.

Author
------

Alexander Sapozhnikov
http://shoorick.ru/
<shoorick@cpan.org>

License
-------

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

See also
--------

https://github.com/shoorick/move-images
