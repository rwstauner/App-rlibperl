# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;

package App::rbinperl;
# ABSTRACT: Execute perl using relative lib and assuming -S

1;

=for :stopwords apache CGI FCGI linux login

=head1 SYNOPSIS

Simplify cron jobs or other places where you specify commands
to execute which don't have your full environment.

Instead of:

  * * * * * perl -I/home/username/perl5/lib/perl5 \
                   /home/username/perl5/bin/somescript

Do:

  * * * * * /home/username/perl5/bin/rbinperl somescript

This is even more useful in a shebang line
which is often limited to a single argument...

This won't work on linux:

  #!/usr/local/bin/perl -I/home/username/perl5/lib/perl5 -S plackup

This will:

  #!/home/username/perl5/bin/rbinperl plackup

This example can be handy in a shared hosting environment
where you install the modules you want using L<local::lib>
and then want to use L<plackup> to run your app
from apache as a CGI or FCGI script.

=head1 DESCRIPTION

The C<rbinperl> script simplifies the execution of
a perl script that depends on modules located in 
relative library directories.

This uses the same logic as L<App::rlibperl>
to prepend relative lib directories to C<@INC> and
additionally passes the C<-S> argument to perl.
This causes perl to search the C<$PATH>
(which now contains the directory where C<rbinperl> was found)
for the specified script.

=head1 EXAMPLE USAGE WITH local::lib

If you have installed C<App::MadeUpScript> (and C<App::rbinperl>)
via L<local::lib> your directory tree will look something like this:

  ${root}/bin/rbinperl
  ${root}/bin/made-up-script
  ${root}/lib/perl5/${modules}
  ${root}/lib/perl5/${archname}/${extras}
  ${root}/man/${docs}

When you're using a login shell with L<local::lib> enabled
you can just call C<made-up-script> from the shell
because your environment variables are configured such that
C<${root}/bin> is in your C<$PATH> and
C<${root}/lib/perl5> is in C<$PERL5LIB>.

However to run from any sort of detached process
the environment variables from L<local::lib> won't be available,
and you'd have to do this instead:

  $ perl -I${root}/lib/perl5 -S made-up-script

C<rbinperl> simplifies this by adding the relative lib directories
automatically and passing C<-S>:

  $ ${root}/bin/rbinperl made-up-script

=head1 BLAH BLAH BLAH

Honestly the script itself is much simpler than explaining
how it can be useful (if it even is useful).

=head1 SEE ALSO

=for :list
* L<App::rlibperl>

=cut
