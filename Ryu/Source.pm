package Ryu::Source;

use strict;
use warnings;
no indirect;

# TODO: Add support for IO::Async::Notifier

# Just save all the args in $self
sub new {
    my ($class, %args) = @_;

    # Required to make the source finished (not covered in the first session)
    die 'Please pass the new_future function' unless defined $args{new_future};

    my $self = { callbacks => [], %args };
    return bless $self, $class;
}

# Create a new instance of source, mostly used internally
sub create_source {
    my ($self, %args) = @_;

    my $new_source = __PACKAGE__->new(
        new_future => $self->{new_future},
        %args,
    );

    push $self->{children}->@*, $new_source;

    return $new_source;
}

# Emit new items to the source
sub emit {
    my ($self, $item) = @_;

    $_->($item) for $self->{callbacks}->@*;
}

# Listen on items reaching the source
# ->each(sub {warn shift})
sub each {
    my ($self, $code) = @_;

    push $self->{callbacks}->@*, $code;

    return $self;
}

# Skip a few items from the source
sub skip {
    my ($self, $count) = @_;

    my $new_source = $self->create_source();

    $self->each(sub {
        my $item = shift;
        $new_source->emit($item) unless $count-- > 0;
    });

    return $new_source;
}

# Returns items and their index: [$item, $idx]
sub with_index {
    my ($self) = @_;

    my $new_source = $self->create_source();

    my $count = 0;
    $self->each(sub {
        my $item = shift;
        $new_source->emit([ $item, $count++ ]);
    });

    return $new_source;
}

# Similar to map function, changes a received item based on a coderef
sub map {
    my ($self, $code) = @_;

    my $new_source = $self->create_source();

    $self->each(sub {
        my $item = shift;
        $new_source->emit($code->($item));
    });

    return $new_source;
}

# Filter items based on a regex
sub filter {
    my ($self, $code) = @_;

    my $new_source = $self->create_source();

    $self->each(sub {
        my $item = shift;
        $new_source->emit($item) if $code->($item);
    });

    return $new_source;
}

# Return distinct values, duplicate values are dropped
sub distinct {
    my ($self, $code) = @_;

    my $new_source = $self->create_source();

    my %seen;
    $self->each(sub {
        my $item = shift;
        $new_source->emit($item) unless $seen{$item}++;
    });

    return $new_source;
}

#############################################################################
# Need `completed` implementation. Will talk about them in the next session #
#############################################################################

# create a new future using the function in Ryu::Async
sub new_future {
    my ($self, %args) = @_;

    my $new_future = $self->{new_future} or die 'Please use Ryu::Async->source';

    return $new_future->(%args);
}

# Returns a future which is done when the source is completed
sub completed {
    my $self = shift;

    $self->{completed} //= $self->new_future(label => 'completed')
    ->on_ready(sub {
        $self->cleanup;
    });
}

# Clean things up after finish
sub cleanup {
    my $self = shift;

    $_->finish for $self->{children}->@*;
}

# Completes the source
sub finish {
    my $self = shift;

    $self->completed->done;
}

# Take first item from the source
sub first {
    my $self = shift;

    my $new_source = $self->create_source();

    my %seen;
    $self->each(sub {
        my $item = shift;
        $new_source->emit($item);
        $self->finish;
    });

    return $new_source;
}

# Returns all items as a list
sub as_list {
    my $self = shift;

    my $new_source = $self->create_source();

    my @items;
    $self->each(sub {
        push @items, shift;
    });

    return $self->completed->transform(done => sub {@items});
}

# Take n items from the source
sub take {
}

# Count the numbers received
sub count {
}

# Return an accumulative result, similar to reduce in List::Util
sub reduce {
}

1;
