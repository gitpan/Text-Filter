package Text::Filter;

# RCS Info        : $Id: TextFilter.pm,v 1.6 1999-03-19 14:37:40+01 jv Exp $
# Author          : Johan Vromans
# Last Modified By: Johan Vromans
# Last Modified On: Fri Mar 19 15:12:26 1999
# Update Count    : 29
# Status          : Released

=head1 NAME

Text::Filter - base class for objects that can read and write text lines

=head1 SYNOPSIS

A plethora of tools exist that operate as filters: they get data from
a source, operate on this data, and write possibly modified data to a
destination. In the Unix world, these tools can be chained using a
technique called pipelining, where the output of one filter is
connected to the input of another filter. Some non-Unix worlds are
reported to have similar provisions.

To create Perl modules for filter functionality seems trivial at
first. Just open the input file, read and process it, and write output
to a destination file. But for really reusable modules this approach
is too simple. A reusable module should not read and write files
itself, but rely on the calling program to provide input as well as to
handle the output.

C<Text::Filter> is a base class for modules that have in common
that they process text lines by reading from some source (usually a
file), manipulating the contents and writing something back to some
destination (usually some other file).

This module can be used on itself, but it is most powerfull when used
to derive modules from it. See section EXAMPLES for an extensive
example.

=head1 DESCRIPTION

The main purpose of the C<Text::Filter> class is to abstract out the
details out how input and output must be done. Although in most cases
input will come from a file, and output will be written to a file,
advanced modules require more detailed control over the input and
output. For example, the module could be called from another module,
in this case the callee could be allowed to process only a part of the
input. Or, a program could have prepared data in an array and wants to
call the module to process this data as if it were read from a file.
Also, the input stream provides a pushback functionality to make
peeking at the input easy.

C<Text::Filter> can be used on its own as a convenient input/output
handler. For example:

    use Text::Filter;
    my $filter = new Text::Filter (input = *STDIN, output = *STDOUT);
    my $line;
    while (defined ($line = $filter->readline)) {
        $filter->writeline ($line);
    }

Its real power shows when such a program is turned into a module for
optimal reuse.

When creating a module that is to process lines of text, it can be
derived from C<Text::Filter>, for example:

    package MyFilter;

    BEGIN {
	use vars qw(@ISA);
	@ISA = qw(Text::Filter);
    }

The constructor method must then call the new() method of the
C<Text::Filter> class to set up the base class. This is conveniently
done by calling SUPER::new(). A hash containing attributes must be
passed to this method, some of these attributes will be used by the
base class setup.

    sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	# ... fetch non-attribute arguments from @_ ...
	# Create the instance, using the attribute arguments.
	my $self = $class->SUPER::new (@_);

Finally, the newly created object must be re-blessed into the desired
class, and returned:

        # Rebless into the desired class.
	bless ($self, $class);
    }

When creating new instances for this class, attributes C<input> and
C<output> can be used to specify how input and output is to be
handled. Several possible values can be supplied for these attributes.

For C<input>:

=over

=item *

A scalar, containing a file name.
The named file will be opened,
input lines will be read using C<<>>.

=item *

A file handle (glob).
Lines will be read using C<<>>.

=item *

An instance of class C<IO::File>.
Lines will be read using C<<>>.

=item *

A reference to an array.
Input lines will be shift()ed from the array.

=item *

A reference to an anonymous subroutine.
This routine will be called to get the next line of data.

=back

For C<output>:

=over

=item *

A scalar, containing a file name.
The named file will be created automatically,
output lines will be written using print().

=item *

A file handle (glob).
Lines will be written using print().

=item *

An instance of class C<IO::File>.
Lines will be written using print().

=item *

A reference to an array.
Output lines will be push()ed into the array.
The array will be initialised to C<()> if necessary.

=item *

A reference to a scalar.
Output lines will be appended to the scalar.
The scalar will be initialised to C<""> if necessary.

=item *

A reference to an anonymous subroutine.
This routine will be called to append a line of text to the destination.

=back

Additional attributes can be used to specify actions to be performed
after the data is fetched, or prior to being written. For example, to
strip line endings upon input, and add them upon output.

=head1 CONSTRUCTOR

The constructor is called new() and takes a hash with attributes as
its parameter.

The following attributes are recognized and used by the constructor,
all others are ignored.

The constructor will return a blessed hash containing all the original
attributes, plus some new attributes. The names of the new attributes
all start with C<_filter_>, the new attributes should I<not> be touched.

=over 4

=item input

This designates the input source. The value must be a scalar
(containing a file name), a file handle (either a glob or an instance
of class C<IO::File>), an array reference, or a reference to a
subroutine, as described above.

If a subroutine is specified, it must return the next line to be
processed, and C<undef> at end.

=item input_postread

This attribute can be used to select an action to be performed after
the data has been read.
Its prime purpose is to handle line endings (e.g. remove a trailing newline).

The value can be 'none' or 0 (no action), 'chomp' or 1 (standard
chomp() operation), an array reference, or a reference to a
subroutine. Default value is 0 (no chomping).

If the value is a reference to a subroutine, this will be called with
the text line that was just read as its only argument, and it must
return the new contents of the text line..

=item output

This designates the output. The value must be a scalar
(containing a file name), a file handle (either a glob or an instance
of class C<IO::File>), or a reference to a subroutine, as described
above.

Note: when a file name is passed, a 'C<>>' will be prepended if necessary.

=item output_prewrite

This attribute can be used to select an action to be performed just
before the data is added to the output.
Its prime purpose is to handle line endings (e.g. add a trailing newline).
The value can be 'none' or 0 (no action) , 'newline' or 1 (append the
value of C<$/> to the line), or a reference to a subroutine. Default
value is 0 (no action).

If the value is 'newline' or 1, and the value of C<$/> is C<"">
(paragraph mode), two newlines will be added.

If the value is a reference to a subroutine, this will be called with
the text line as its only argument, and it must return the new
contents of the line to be output.

=back

=head1 INSTANCE METHODS

=over

=item $filter->readline

If there is anything in the pushback buffer, this is returned and the
pushback buffer is marked empty.

Otherwise, returns the next line from the input stream, or C<undef> if
there is no more input.

=item $filter->pushback ($line)

Pushes a line of text back to the input stream.
Returns the line.

=item $filter->peek

Peeks at the input.
Short for pushback(readline()).

=item $filter->writeline ($line)

Adds C<$line> to the output stream.

=item $filter->set_input ($input [ , $postread ])

Sets the input method to C<$input>.
If the optional argument C<$postread> is defined, sets the input line
postprocessing strategy as well.

=item $filter->set_output ($output, [ $prewrite ])

Sets the output method to C<$output>.
If the optional argument C<$prewrite> is defined, sets the output line
preprocessing strategy as well.

=back

=head1 EXAMPLE

This is an example of how to use the C<Text::Filter> class.

It implements a module that provides a single instance method: grep(),
that performs some kind of grep(1)-style function (how surprising!).

A class method grepper() is also provided for easy access to do 'the
right thing' in the most common case.

    package Grepper;

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
	# The superclass constructor will take care of handling
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

=head1 AUTHOR AND CREDITS

Johan Vromans (jvromans@squirrel.nl) wrote this module.

=head1 COPYRIGHT AND DISCLAIMER

This program is Copyright 1998,1999 by Squirrel Consultancy. All
rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of either: a) the GNU General Public License as
published by the Free Software Foundation; either version 1, or (at
your option) any later version, or b) the "Artistic License" which
comes with Perl.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See either the
GNU General Public License or the Artistic License for more details.

=cut

use strict;

BEGIN {
    require 5.005;
    use vars qw($VERSION);
    ($VERSION) = '$Revision: 1.6 $ ' =~ /: ([\d.]+)/;
}

use IO;
use Carp;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Create the object out of the attributes.
    my $self = { @_ };
    bless ($self, $class);

    # Handle the input and output attributes, if specified.
    my $att;
    $self->set_input  ($att, $self->{input_postread})
      if defined ($att = $self->{input});
    $self->set_output ($att, $self->{output_prewrite})
      if defined ($att = $self->{output});

    # Return the object.
    $self;
}

sub set_input {
    my ($self, $handler, $postread) = @_;
    my $input;

    if ( ref($handler) ) {
	if ( $handler =~ /=/ && $handler->isa("IO::File") ) {
	    $input = sub { scalar <$handler> };
	}
	elsif ( ref($handler) eq 'CODE' ) {
	    $input = $handler;
	}
	elsif ( ref($handler) eq 'ARRAY' ) {
	    $input = sub { shift (@$handler) };
	}
    }
    elsif ( $handler =~ /^\*/ ) {
	$input = sub { scalar <$handler> };
    }
    else {
	my $fd;
	$fd = new IO::File ($handler)
	  or croak ("Error opening $handler: $!");
	$input = sub { scalar <$fd> };
    }

    croak ("Unrecognized value for 'input' attribute: ".
	   $handler) unless defined $input;

    $self->{_filter_input} = $input;

    my $posthandler;
    if ( defined ($postread) ) {
	if ( ref($postread) && ref($postread) eq 'CODE' ) {
	    $posthandler = $postread;
	}
	elsif ( $postread eq 'none' || $postread eq '0' ) {
	}
	elsif ( $postread eq 'chomp' || $postread eq '1' ) {
	    $posthandler = '';
	}
	else {
	    croak ("Unrecognized value for 'input_postread' attribute: ".
		   $postread);
	}
    }
    $self->{_filter_postread} = $posthandler;
    $self->{_filter_pushback} = [];
    $self;
}

sub set_output {
    my ($self, $handler, $prewrite) = @_;
    my $output;

    if ( ref($handler) ) {
	if ( $handler =~ /=/ && $handler->isa("IO::File") ) {
	    $output = sub { print $handler (shift) };
	}
	elsif ( ref($handler) eq 'ARRAY' ) {
	    $output = sub { push (@$handler, shift) };
	    @$handler = () unless defined @$handler;
	}
	elsif ( ref($handler) eq 'SCALAR' ) {
	    $output = sub { $$handler .= shift };
	    $$handler = "" unless defined $$handler;
	}
	elsif ( ref($handler) eq 'CODE' ) {
	    $output = $handler;
	}
    }
    elsif ( $handler =~ /^\*/ ) {
	$output = sub { print $handler (shift) };
    }
    else {
	$handler = ">" . $handler unless $handler =~ /^>/;
	my $fd;
	$fd = new IO::File ($handler)
	  or croak ("Error opening $handler: $!");
	$output = sub { print $fd (shift) };
    }

    croak ("Unrecognized value for 'output' attribute: " . $handler)
      unless defined $output;

    $self->{_filter_output} = $output;

    my $prehandler;
    if ( defined $prewrite ) {
	if ( ref($prewrite) && ref($prewrite) eq 'CODE' ) {
	    $prehandler = $prewrite;
	}
	elsif ( $prewrite eq 'none' || $prewrite eq '0' ) {
	}
	elsif ( $prewrite eq 'newline' || $prewrite eq '1' ) {
	    $prehandler = '';
	}
	else {
	    croak ("Unrecognized value for 'output_prewrite' attribute: ".
		   $prewrite);
	}
    }
    $self->{_filter_prewrite} = $prehandler;

    $self;
}

sub readline {
    my ($self) = shift;

    return shift (@{$self->{_filter_pushback}})
      if @{$self->{_filter_pushback}} > 0;

    my $line;
    my $input = $self->{_filter_input};
    return undef unless defined ($line = $input->());

    my $postread = $self->{_filter_postread};
    return $line unless defined $postread;
    return $postread->($line) if $postread ne '';
    chomp $line;
    $line;
}

sub pushback {
    my ($self, $line) = @_;
    push (@{$self->{_filter_pushback}}, $line);
    $line;
}

sub peek {
    my ($self) = @_;
    return $self->{_filter_pushback}->[0]
      if @{$self->{_filter_pushback}} > 0;
    $self->pushback ($self->readline);
}

sub get_input {
    my $self = shift;
    $self->{_filter_input};
}

sub writeline {
    my ($self, $line) = @_;
    my $prewrite = $self->{_filter_prewrite};
    if ( defined $prewrite ) {
	if ( $prewrite ne '' ) {
	    $line = $prewrite->($line);
	}
	elsif ( defined $/ ) {
	    # Add the line terminator.
	    # In paragraph mode, just add two newlines.
	    $line .= ($/ eq '' ? "\n\n" : $/);
	}
    }
    $self->{_filter_output}->($line);
}

sub get_output {
    my $self = shift;
    $self->{_filter_output};
}

1;
