# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package App::rlibperl;
# ABSTRACT: Execute perl prepending relative lib to @INC

1;

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
  use local::lib;

It also uses the environment to find perl
similar to the typical C<#!/usr/bin/env perl> trick.

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
like L<local::lib> does which enable C<system> commands to work.

So this:

  $HOME/perl5/bin/rlibperl -MSome::Module -e 'do_something'

Is roughly the equivalent of:

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

=head1 SEE ALSO

=begin :list

* L<App::rbinperl>

* L<local::lib>

* L<Devel::Local>

* L<ylib> (C<perl -Mylib>)

=item *

L<rlib>

Note that this module is not related to or dependent on L<rlib>
but it serves a similar purpose in a different situation.

=end :list

=cut
