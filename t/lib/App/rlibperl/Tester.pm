# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
package # no_index
  App::rlibperl::Tester;

use strict;
use warnings;
use Config;        # core
use FindBin;       # core
use File::Copy qw( copy ); # core
use File::Spec::Functions qw( catfile catdir ); # core
use File::Path qw( mkpath );  # core
use File::Temp qw( tempdir ); # core
use Exporter;      # core

our @ISA    = qw( Exporter );
our @EXPORT = qw(
  %Config
  $PERL
  $ARCHNAME
  @scripts
  @structures
  catdir
  catfile
  get_inc
  make_file
  make_script
  named_tree
  tempdir
);

our @scripts = qw(
  rlibperl
  rbinperl
);

our @structures = qw(
  local::lib
  same
  parent
);

# find 'perl' in $PATH; if not found use $^X.
our ($PERL, $ARCHNAME) = system(qw(perl -e 1)) == 0
  ? ('perl', scalar qx/perl -MConfig -e "print \$::Config{archname}"/)
  : ($^X, $Config{archname});

chomp($ARCHNAME); # just in case

sub get_inc {
  my $perl = shift || $PERL;
  local $ENV{PERL5LIB};
  return split(/\t/, qx/$perl -e "\$, = qq[\\t]; print \@INC;"/);
}

sub named_tree {
  my ($name) = @_;
  my $dir = tempdir( CLEANUP => 1 );

  my %subdirs;
  if ( $name eq 'local::lib' ) {
    $subdirs{bin}  = [qw(bin)];
    $subdirs{arch} = [qw(lib perl5), $ARCHNAME];
    $subdirs{lib}  = [qw(lib perl5)];
  }
  elsif ( $name eq 'parent' ) {
    $subdirs{bin}  = [qw(bin)];
    $subdirs{lib}  = [qw(lib)];
  }
  elsif ( $name eq 'same' ) {
    $subdirs{lib}  = [qw(lib)];
  }
  else {
    die qq[Don't know how to build tree for '$name'];
  }
  $subdirs{bin}  ||= [];
  $subdirs{arch} ||= $subdirs{lib};

  $subdirs{$_} = catdir($dir, @{$subdirs{$_}})
    for keys %subdirs;

  mkpath([values %subdirs]);

  my $source = ['bin'];
  # is there a reason to get them out of blib/script ?

  # TODO: $ext = '.pl' if $^O eq 'MSWin32' ?
  my %scripts = map { ($_ => catfile($subdirs{bin}, $_)) }
    @scripts;

  copy( catfile(@$source, $_), $scripts{$_} )
    for keys %scripts;

  chmod 0755, values %scripts;

  return {
    root => $dir,
    %subdirs,
    %scripts,
  };
}

sub make_file {
  my ($path, $text) = @_;
  my $file = ref($path) eq 'ARRAY' ? catfile(@$path) : $path;
  open my $fh, '>', $file
    or die "Failed to open $file for writing: $!";
  print $fh $text
    or die "Failed to write to $file: $!";
  close $fh
    or die "Failed to close $file: $!";
  return $file;
}

sub make_script {
  my $file = make_file(@_);
  chmod 0755, $file;
  return $file;
}

1;
