package Grepper;

# This is an example of how to use the Text::Filter class.
#
# It implements a module that provides a single instance method: grep,
# that performs some kind of grep(1)-style function (how surprising!).
#
# A class method 'grepper' is also provided for easy access to do 'the
# right thing'.

use strict;

use Text::Filter;

# Setup.
BEGIN {
    use vars qw(@ISA);
    @ISA = ();

    # This class exports static method, so we need Exporter:
    use Exporter;
    use vars qw(@EXPORT);
    @EXPORT = qw(grepper);
    push (@ISA, qw(Exporter));

    # This class derives from Text::Filter.
    push (@ISA, qw(Text::Filter));
}

# Constructor. Major part of the job is done by the superclass.
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Create a new instance by calling the superclass constructor.
    my $self = $class->SUPER::new(@_);
    # Note that the superclass constructor will take care of handling
    # the input and output attributes, and setup everything for
    # handling the IO.

    # Bless the object into the desired class.
    bless ($self, $class);

    # And return it.
    $self;
}

# Instance method, just an example. No magic.
sub grep {
    my $self = shift;
    my $pat = shift;
    my $line;
    while ( defined ($line = $self->readline) ) {
	$self->writeline ($line) if $line =~ $pat;
    }
}

# Class method, for convenience.
# Usage: grepper (<input file>, <output file>, <pattern>);
sub grepper {
    my ($input, $output, $pat) = @_;

    # Create a Grepper object.
    my $grepper = new Grepper (input => $input, output => $output);

    # Call its grep method.
    $grepper->grep ($pat);
}

1;
