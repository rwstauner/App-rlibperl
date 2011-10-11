# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package App::rlibperl;
# ABSTRACT: Execute perl prepending relative lib to @INC

1;

=for :stopwords executables

=head1 SYNOPSIS

Install this into a L<local::lib> directory
to simplify including the C<local::lib> when calling perl:

  # cron job:
  * * * * * /project/dir/bin/rlibperl -MProject::App -e 'run()'

  # program configuration file:
  command = /home/username/perl5/bin/rlibperl -MSome::Mod -e 'do { something; }'

If you're lazy (like me) you can use it in the shebang line:

  #!/home/username/perl5/bin/rlibperl

Then you don't need to add an explicit

  use lib '/home/username/perl5/lib/perl5';

before any of your other code.

It also uses the environment to find perl
similar to the common C<#!/usr/bin/env perl> trick
(using the common C<eval 'exec...'\n if 0> trick).

=head1 DESCRIPTION

The C<rlibperl> script simplifies the inclusion of
relative library directories with perl.

Upon execution the script will look for lib directories
relative to the location of the script
then re-invoke perl with all supplied command line arguments
and any found lib directories added to C<@INC>.

The script was designed to be installed via L<local::lib>
(though L<local::lib> is not required).
Once installed, executing the script is just like
executing perl except that it adds the local lib directories
to C<@INC> for you.

It also adds the directory of the script to C<$PATH>
like L<local::lib> does which enables C<system>/C<qx>/C<exec>/etc.
to find executables in that directory.

So this:

  $HOME/perl5/bin/rlibperl -MSome::Module -e 'do_something'

is roughly the equivalent of:

  PATH=$HOME/perl5/bin:$PATH perl \
     -I$HOME/perl5/lib/perl5 -MSome::Module -e 'do_something'

If that isn't useful enough (it probably isn't)
check out L<App::rbinperl> which automatically adds C<-S>
which makes it just as easy to execute another
script in that bin directory.

=head1 DIRECTORY STRUCTURES

C<rlibperl> will look for the following directory structures
relative to the directory in which it is located:

If the script is located in a directory named C<bin>
(or C<script> or C<scripts>)
it assumes a structure similar to L<local::lib>
and will first look for
C<../lib/perl5>:

  ${root}/bin/rlibperl
  ${root}/lib/perl5

If not found it will check for C<./lib>.

  ${root}/rlibperl
  ${root}/lib

(If C<rlibperl> is not located in a directory matching C</bin|scripts?/>
the order will be reversed: it will look for C<./lib> first.)

Lastly it will check for simply C<../lib>.

  ${root}/bin/rlibperl
  ${root}/lib

If you have another directory structure you think should be supported
please send suggestions!

=head1 BUGS AND LIMITATIONS

The initial use-case for C<rlibperl> was
installing via L<local::lib>
(or without it using something like C<cpanm --local-lib /other/dir>)
and calling like so:

  $ /path/to/local-lib/rlibperl -perl-args

(It may also be useful in a per-project setting,
though it's likely easier to make custom scripts
and/or use the unrelated L<rlib>.)

The following limitations exist when used in other situations,
however they are considered bugs and may be "fixed" at some point
(so their functionality should not be relied upon):

=begin :list

=item *

Installing this into a perl's default lib will end up duplicating
directories in C<@INC> and probably reverse the order of your search path.

This is a problem, but then installing C<rlibperl> into a directory
that is already in your C<@INC> isn't all that useful.

=item *

It currently always runs via the C<perl> in your C<$PATH>.
This is expected when run as:

  $ /local/lib/perl5/bin/rlibperl -args

But can be confusing if run as

  $ /other/perl /local/lib/perl5/bin/rlibperl -args

This is because the script uses the C<#!/bin/sh> + C<eval 'exec'> trick
(see example in L<perlrun>) which is more portable than
C<#!/usr/bin/env perl>, however perl has the "feature" of processing
shebangs which means it actually delegates to C</bin/sh> first
which proceeds to load the perl from the environment.

While this is not ideal and can be confusing,
specifiying the full paths to perl and C<rlibperl>
doesn't seem all that useful either:

  $ /other/perl /local/lib/perl5/bin/rlibperl -args

compared to:

  $ /other/perl -I/local/lib/perl5/lib/perl5 -args

=end :list

If you think the above situations I<would> be useful
please submit rationale (or B<patches>).

=head1 SEE ALSO

=begin :list

* L<App::rbinperl> - included

* L<local::lib> - The module that makes this one useful

* L<ylib> (C<perl -Mylib>) - Configurable additional lib directories

* L<Devel::Local> - An alternative to the above modules

=item *

L<rlib> - This module is not related to or dependent on L<rlib>
but it serves a similar purpose in a different situation.

=item *

L<App::local::lib::helper> - A more configurable alternative to this dist
that loads L<local::lib> and its environment variables.

The C<localenv> script installed by L<App::local::lib::helper>
may be more powerful as a shell tool,
but C<rlibperl> serves a few niches that C<localenv> does not,
including enabling shebang args and taint mode.

Use the tool that works for you.

=end :list

=cut
