#!./perl -w

use Text::Filter;
require "t/testfilter.pl";

my $i = 0;
my $f;
my @catch = ();

my $expect =
  "Red Hat Linux release 5.2 (Apollo)\n".
  "Kernel 2.2.1 on an i686\n".
  "Mandatory\n";

print "1..6\n";

# Quickie.
@catch = ();
Grepper::grepper ("t/testfile",
		  sub { push (@catch, shift) },
		  qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 1\n");

# File -> code
@catch = ();
$f = new Grepper
  input => "t/testfile",
  output => sub { push (@catch, shift) };
$f->grep(qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 2\n");

# code -> code, chomp
my @inp = @catch;
@catch = ();
$f = new Grepper
  input => sub { shift(@inp) },
  input_postread => 'chomp',
  output => sub { push (@catch, shift(@_)."\n") };
$f->grep(qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 3\n");

# code -> code, newline
@inp = @catch;
chomp (@inp);
@catch = ();
$f = new Grepper
  input => sub { shift(@inp) },
  output_prewrite => 'newline',
  output => sub { push (@catch, shift(@_)) };
$f->grep(qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 4\n");

# array -> array
@inp = @catch;
@catch = ();
$f = new Grepper
  input => \@inp,
  output => \@catch;
$f->grep(qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 5\n");

# File -> array
@catch = ();
local (*FD);
open (FD, "t/testfile");
$f = new Grepper
  input => *FD,
  output => \@catch;
$f->grep(qr/a/);
print STDOUT ((join('',@catch) eq $expect) ? "" : "not ", "ok 6\n");

