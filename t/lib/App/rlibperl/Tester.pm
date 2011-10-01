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
  named_tree
);

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
    qw( rlibperl rbinperl );

  copy( catfile(@$source, $_), $scripts{$_} )
    for keys %scripts;

  print qx/ls -alFR $dir/;
  return {
    root => $dir,
    %scripts,
  };
}
