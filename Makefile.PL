# Makefile.PL -- Makefile for Text::Filter
# Author          : Johan Vromans
# Last Modified By: Johan Vromans
# Last Modified On: Fri Mar 26 09:52:08 1999
# Update Count    : 10
# Status          : Stable

# Verify perl version.
require 5.000;

use ExtUtils::MakeMaker;

my @scripts = qw();

if ( $] < 5.005 ) {
    print STDERR <<EOD;

Module Text::Filter has been developed using Perl 5.005.
I expect it to work with your version of Perl ($]) as well.
Please let me know so I can adjust the requirements.

EOD
}

WriteMakefile
  (
   NAME         => 'Text::Filter',
   ($] >= 5.005)
    ? (AUTHOR	=> 'Johan Vromans (jvromans@squirrel.nl)',
       ABSTRACT	=> 'Base class for line based text processing modules',
      ) : (),
   VERSION_FROM => "lib/Text/Filter.pm",
   PREREQ_PM	=> { 'IO' => 0 },
   # EXE_FILES    => [ map { "scripts/$_" } @scripts ],
   # *.pm files will be picked up automatically from ./lib
 );
