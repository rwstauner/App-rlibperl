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
  @scripts
  catdir
  catfile
  get_inc
  make_file
  make_script
  named_tree
);

our @scripts = qw(
  rlibperl
  rbinperl
);

sub get_inc {
  my $perl = shift || $^X;
  local $ENV{PERL5LIB};
  return split(/\t/, qx/$perl -e "\$, = qq[\\t]; print \@INC;"/);
}

sub named_tree {
  my ($name) = @_;
  my $dir = tempdir( CLEANUP => 1 );

  my ($bin, $arch, $lib);
  if ( $name eq 'local::lib' ) {
    $bin  = [qw(bin)];
    $arch = [qw(lib perl5), $Config{archname}];
    $lib  = [qw(lib perl5)];
  }
  elsif ( $name eq 'parent' ) {
    $bin  = [qw(bin)];
    $lib  = [qw(lib)];
  }
  elsif ( $name eq 'same' ) {
    $lib  = [qw(lib)];
  }
  else {
    die qq[Don't know how to build tree for '$name'];
  }
  $bin ||= [];
  $arch ||= $lib;

  # $arch is a subdir (or equal to $lib)
  mkpath($_)
    for map { catdir($dir, @$_) } $bin, $arch;

  my $source = ['bin'];
  unshift @$source, 'blib'
    if -d 'blib';

  # TODO: $ext = '.pl' if $^O eq 'MSWin32' ?
  my %scripts = map { ($_ => catfile($dir, @$bin, $_)) }
    @scripts;

  copy( catfile(@$source, $_), $scripts{$_} )
    for keys %scripts;

  chmod 0755, values %scripts;

  return {
    root => $dir,
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
}
