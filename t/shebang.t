# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use lib 't/lib';
use App::rlibperl::Tester;
use Test::More;

plan skip_all => "Testing shebangs not supported on $^O"
  # this list could be much longer and more complicated
  if $^O !~ /
      linux
    | bsd
    | darwin
    | cygwin
    | solaris
  /x;

plan tests => scalar @structures;

foreach my $structure ( @structures ) {
  my $tree = named_tree( $structure );

  my $interp = 'sillyinterp';
  make_script([$tree->{bin}, $interp], <<SCRIPT);
#!$^X
use strict;
use warnings;
while(<>){
  print "bar." if /foo/;
  print "nertz." if /narf/;
}
SCRIPT

  # put script somewhere separate
  my $scriptdir = tempdir( UNLINK => 1 );
  my $script = make_script([$scriptdir, 'silly'], <<SCRIPT);
#!$tree->{rbinperl} sillyinterp
foo()
narf.
SCRIPT

  is(
    qx/$script/,
    'bar.nertz.',
    'rbinperl used as shebang to invoke custom interpreter'
  );
}
