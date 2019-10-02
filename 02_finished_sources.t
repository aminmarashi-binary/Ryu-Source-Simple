use strict;
use warnings;
no indirect;

use Test::More::Async;
use Ryu::Async;
use IO::Async::Loop;
use Future::AsyncAwait;
use feature qw(state);
# use Log::Any::Adapter qw(Stdout), log_level => 'TRACE';
my $loop = IO::Async::Loop->new;

sub create_source {
    $loop->add(our $ryu = Ryu::Async->new) unless $ryu;

    return $ryu->source;
}

subtest 'A source is created then receives items' => async sub {
    my $source = create_source();

    $loop->later(sub { $source->emit('item') });

    my $item;
    $source->each(sub {$item = shift});

    await $loop->delay_future(after => 0.1);

    is $item, 'item', 'A finished source does not receive any items';
};

subtest 'We can take some items from the source' => async sub {
    my $source = create_source();

    $loop->later(sub { $source->emit($_) for 1..5 });

    my @items = await $source->take(2)->as_list;

    is_deeply \@items, [1, 2], '1 and 2 are received';
};

subtest 'Count the items received' => async sub {
    my $source = create_source();

    $loop->later(sub { $source->emit($_) for 1..5 });

    my ($count) = await $source->take(3)->count->as_list;

    is $count, 3, 'Count matches the item taken from the source';
};

subtest 'Count the items received' => async sub {
    my $source = create_source();

    $loop->later(sub { $source->emit($_) for 1..5 });

    my ($count) = await $source->take(3)->count->as_list;

    is $count, 3, 'Count matches the item taken from the source';
};

done_testing();
1;
