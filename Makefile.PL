# Makefile.PL -- Makefile for Text::Filter
# Author          : Johan Vromans
# Last Modified By: Johan Vromans
# Last Modified On: Wed Feb 24 09:10:44 1999
# Update Count    : 3
# Status          : Stable

# Verify perl version.
require 5.000;

use ExtUtils::MakeMaker;

my @scripts = qw();

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
