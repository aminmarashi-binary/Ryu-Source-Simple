use strict;
use warnings;
no indirect;

use Test::More;
use Ryu::Source;
use IO::Async::Loop;
my $loop = IO::Async::Loop->new;

subtest 'Initialize' => sub {
    $loop->add(my $source = Ryu::Source);

    isa_ok $source, 'Ryu::Source', 'Source is initialized correctly';
};

subtest 'Can emit and receive items' => sub {
    is $received, 'item', 'Item is received';
};

subtest 'Items emitted are dropped if no one is listening' => sub {
    is $received, undef, 'Item will be dropped';
};

subtest 'Items are skipped properly' => sub {
    is_deeply \@items, [3, 4, 5], '1 and 2 are skipped';
};

subtest 'Items are returned with their indexes' => sub {
    is_deeply \@items, [map [$_, $_ - 1], 1..5], 'Items match expectation';
};

subtest 'Mapped items are returned' => sub {
    is_deeply \@items, \@expected, 'Are items are now prefixed';
};

subtest 'Filter returns the filtered items' => sub {
    is_deeply \@items, [1, 3, 5], 'Only odd numbers pass the filter';
};

subtest 'Distinct numbers are seen' => sub {
    is_deeply \@items, [1..5], 'All the numbers from 1 to 5 are seen once';
};

subtest 'Combined sources work' => sub {
    is_deeply \@items, [
        # Put the expected items here
        [5, 0],
        [3, 1],
    ], 'Make me pass';
};

subtest 'Combined sources work two each' => sub {
    # diag explain \@items;
    is_deeply \@items, [
        # Put the expected items here
        1, 5, [5, 0], 3, [3, 1]
    ], 'Make me pass';
};

done_testing();
1;
