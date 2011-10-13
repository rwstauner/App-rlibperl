#!/usr/bin/env perl
# vim: set ts=2 sts=2 sw=2 expandtab smarttab:

use strict;
use warnings;
use FindBin; # core
use File::Spec::Functions qw( catdir catfile splitdir ); # core

my $vars = {
  rlibperl => {
    abstract => 'Execute perl prepending relative lib to @INC',
    argv => q<@ARGV>,
  },
  rbinperl => {
    abstract => 'Execute perl using relative lib and assuming -S',
    argv => q<'-S', @ARGV>,
  },
};
$vars->{$_}{name} = $_ for keys %$vars;

# we need this more than once
our @lines = <DATA>;

my $bin = do {
  my @dir = splitdir($FindBin::Bin);
  pop @dir;
  catdir(@dir, 'bin');
};

sub generate_script {
  my ($name) = shift;
  my $other = (grep { $_ ne $name } keys %$vars)[0];

  my $file = catfile($bin, $name);
  open(my $fh, '>', $file) or die "open '$file' failed: $!";

  for( @lines ){
    # don't overwrite the line, we need it again
    (my $line = $_) =~
      s/\{\{(other:)?(\w+)\}\}/$vars->{ $1 ? $other : $name }->{ $2 }/ge;
    print $fh $line;
  }
}

generate_script($_) for keys %$vars;

__DATA__
#!/usr/bin/env perl
# vim: set ts=2 sts=2 sw=2 expandtab smarttab filetype=perl:
# PODNAME: {{name}}
# ABSTRACT: {{abstract}}

use strict;
use warnings;
use FindBin;    # core
use File::Spec::Functions qw( catdir catpath splitdir splitpath ); # core
use Config;     # core

# __FILE__ can be relative, use FindBin to make sure we get enough path to go up

# FindBin::Bin is a dir, so set $no_file to true for reliability
my ($vol, $dirs, $file) = splitpath($FindBin::Bin, 1);
my @base = splitdir($dirs);
my @inc;

# this looks more complicated than it really is

  my $bin = pop @base;

  # ./lib
  my @sets = [ [$bin, qw(lib)] ];

  # local::lib uses ../lib/perl5
  my $local_lib = [
    [qw(lib perl5)],
  ];

  # the most likely structure is bin/../lib
  # but if we're not in a bin/ it might be a project root
  # so look for ./lib before looking for ../lib

  $bin =~ /^(bin|scripts?)$/i
    ? unshift(@sets, $local_lib)
    :    push(@sets, $local_lib);

  # if those fail try ../lib (project-specific bin/)
  push @sets, [ [qw(lib)] ];

  # should we be looking for $archname to determine the order we check?
  # should we be looking for ./lib/perl5 ? [ map { [ $bin, @$_ ] } @$local_lib ]
  # should we be looking for blib?  (blib/lib, blib/arch)?

  my %current = map { ($_ => 1) } @INC; # uniq
  LIB: foreach my $set ( @sets ){
    @inc =
      grep { -d $_ && !exists($current{$_}) }
      map  { catpath($vol, catdir(@base, @$_), '') }
        @$set;
    last LIB if @inc;
  }

# see perldoc description of perlvar $^X
my $perl = $Config{perlpath};
if ($^O ne 'VMS') {
  $perl .= $Config{_exe}
    unless $perl =~ m/$Config{_exe}$/i;
}

# put current bin in path so perl -S will find it
$ENV{PATH} = $FindBin::Bin . $Config{path_sep} . $ENV{PATH};

@inc = map { $_ = Win32::GetShortPathName($_); s-\\-/-g; $_ } @inc if $^O eq 'MSWin32';

# re-invoke perl with the the lib dirs prepended
my @exec = ($perl, (map { '-I' . $_ } @inc), {{argv}});

# exec() seems unreliable on windows... system() seems to work
if( $^O eq 'MSWin32' ){
  system { $exec[0] } @exec;
}
else {
  exec { $exec[0] } @exec;
}

# IDEA: similar to ylib, could read a ~/.file for extra paths to include, possibly multiple keyed on location of script

=head1 SEE ALSO

=for :list
* L<App::{{name}}> for documentation
* L<App::{{other:name}}> {{other:abstract}}
