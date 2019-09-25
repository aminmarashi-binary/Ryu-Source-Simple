package Ryu::Source;

use strict;
use warnings;
no indirect;

# TODO: Add support for IO::Async::Notifier

# Just save all the args in $self
sub new {
    my ($class, %args) = @_;

    # Required to make the source finished (not covered in the first session)
    # defined $args{new_future} or die 'Please pass the new_future function';

    my $self = { %args };
    return bless $self, $class;
}

sub create_source {
    my ($self, %args) = @_;

    return __PACKAGE__->new(%args);
}

# Emit new items to the source
sub emit {
}

# Listen on items reaching the source
sub each {
}

# Skip a few items from the source
sub skip {
}

# Returns items and their index: [$item, $idx]
sub with_index {
}

# Similar to map function, changes a received item based on a coderef
sub map {
}

# Filter items based on a regex
sub filter {
}

# Return distinct values, duplicate values are dropped
sub distinct {
}

#############################################################################
# Need `completed` implementation. Will talk about them in the next session #
#############################################################################

# Returns a future which is done when the source is completed
sub completed {
}

# Completes the source
sub finish {
}

# Take n items from the source
sub take {
}

# Take first item from the source
sub first {
}

# Count the numbers received
sub count {
}

# Return an accumulative result, similar to reduce in List::Util
sub reduce {
}

# Returns all items as an array ref
sub as_arrayref {
}

# Every good source should clean after itself
sub cleanup {
}

1;
