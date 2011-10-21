# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use lib 't/lib';
use App::rlibperl::Tester;
use Test::More;

{
  my $dir = tempdir( CLEANUP => 1 );
  my $parent = make_script([$dir, 'parent'], <<SCRIPT);
#!$PERL
print "parent";
do \$ARGV[0] if \@ARGV;
SCRIPT

  my $child  = make_script([$dir, 'child' ], <<SCRIPT);
#!$parent
print "child";
SCRIPT

  plan skip_all => "Nested shebangs not supported on $^O"
    unless qx/$child/ eq "parentchild";
}

plan tests => scalar @structures;

foreach my $structure ( @structures ) {
  my $tree = named_tree( $structure );

  make_file([$tree->{lib}, 'Silly_Interp.pm'], <<MOD);
package # no_index
  Silly_Interp;
sub parse {
  local \$_ = shift;
  return "bar." if /foo/;
  return "nertz." if /narf/;
}
1;
MOD

  my $interp = 'sillyinterp';
  make_script([$tree->{bin}, $interp], <<SCRIPT);
#!$PERL
use strict;
use warnings;
use Silly_Interp;
while(<>){
  print Silly_Interp::parse(\$_);
}
SCRIPT

  # put script somewhere separate
  my $scriptdir = tempdir( CLEANUP => 1 );
  my $script = make_script([$scriptdir, 'silly'], <<SCRIPT);
#!$tree->{rbinperl} sillyinterp
foo()
narf.
SCRIPT

  is(
    qx/$script/,
    'bar.nertz.',
    "rbinperl used as shebang to invoke custom interpreter for '$structure'"
  );
}
