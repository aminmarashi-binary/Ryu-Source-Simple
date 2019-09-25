package Ryu::Source;

use strict;
use warnings;
no indirect;

# Add support for IO::Async::Notifier

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
    my ($self, $item) = @_;

    return unless defined $self->{listeners};

    $_->($item) for $self->{listeners}->@*;
}

# Listen on items reaching the source
sub each {
    my ($self, $code) = @_;

    push $self->{listeners}->@*, $code;

    return $self;
}

# Skip a few items from the source
sub skip {
    my ($self, $count) = @_;

    return $self unless $count;

    my $source = $self->create_source(label => 'skip');

    $self->each(sub {
        $source->emit(shift) unless $count-- > 0;
    });

    return $source;
}

# Returns items and their index: [$item, $idx]
sub with_index {
    my $self = shift;

    my $source = $self->create_source(label => 'with_index');

    my $idx = 0;
    $self->each(sub {
        my $item = shift;
        $source->emit([$item, $idx++]);
    });

    return $source;
}

# Similar to map function, changes a received item based on a coderef
sub map {
    my ($self, $code) = @_;

    my $source = $self->create_source(label => 'map');

    $self->each(sub {
        my $item =shift;
        $source->emit($code->($item));
    });

    return $source;
}

# Filter items based on a regex
sub filter {
    my ($self, $code) = @_;

    my $source = $self->create_source(label => 'filter');

    $self->each(sub {
        my $item = shift;
        $source->emit($item) if $code->($item);
    });

    return $source;
}

# Return distinct values, duplicate values are dropped
sub distinct {
    my ($self, $code) = @_;

    my $source = $self->create_source(label => 'distinct');

    my %seen;
    $self->each(sub {
        my $item = shift;
        $source->emit($item) unless $seen{$item}++;
    });

    return $source;
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
