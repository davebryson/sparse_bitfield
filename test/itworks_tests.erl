-module(itworks_tests).

-include_lib("eunit/include/eunit.hrl").

all_test() ->
    [
        test_changing_flag(),
        test_get_set_basic(),
        test_more_sets(),
        test_byte_length()
    ].

test_changing_flag() ->
    Index = 19,
    S1 = sparse_bitfield:new(),
    false = sparse_bitfield:get_bit(Index, S1),
    %% Set to true
    {ok, true, S2} = sparse_bitfield:set_bit(Index, true, S1),
    %% Try again but really not changed
    {ok, false, S2} = sparse_bitfield:set_bit(Index, true, S2),
    %% Still true
    true = sparse_bitfield:get_bit(Index, S2),
    %% Now flip to false and should change
    {ok, true, S3} = sparse_bitfield:set_bit(Index, false, S2),
    %% Check
    false = sparse_bitfield:get_bit(Index, S3),
    ok.

test_get_set_basic() ->
    S1 = sparse_bitfield:new(),
    false = sparse_bitfield:get_bit(0, S1),

    {ok, true, S2} = sparse_bitfield:set_bit(1, true, S1),

    false = sparse_bitfield:get_bit(0, S2),
    true = sparse_bitfield:get_bit(1, S2),
    false = sparse_bitfield:get_bit(0, S2),
    false = sparse_bitfield:get_bit(7, S2),
    false = sparse_bitfield:get_bit(8, S2),
    false = sparse_bitfield:get_bit(15, S2),
    false = sparse_bitfield:get_bit(16, S2),
    false = sparse_bitfield:get_bit(1000, S2),

    true = sparse_bitfield:get_bit(1, S2),
    {ok, false, S2} = sparse_bitfield:set_bit(1, true, S2),

    1 = sparse_bitfield:byte_length(S2),
    8 = sparse_bitfield:bit_length(S2),

    %% Flip
    {ok, true, S3} = sparse_bitfield:set_bit(1, false, S2),
    false = sparse_bitfield:get_bit(1, S3),

    1 = sparse_bitfield:byte_length(S3),
    8 = sparse_bitfield:bit_length(S3),
    ok.

test_more_sets() ->
    S0 = sparse_bitfield:new(),
    {ok, _, S1} = sparse_bitfield:set_bit(1, true, S0),
    {ok, _, S2} = sparse_bitfield:set_bit(1024, true, S1),
    {ok, _, S3} = sparse_bitfield:set_bit(2000, true, S2),
    {ok, _, S4} = sparse_bitfield:set_bit(3000, true, S3),
    {ok, _, S5} = sparse_bitfield:set_bit(100000, true, S4),

    true = sparse_bitfield:get_bit(1, S5),
    true = sparse_bitfield:get_bit(1024, S5),
    true = sparse_bitfield:get_bit(2000, S5),
    true = sparse_bitfield:get_bit(3000, S5),
    true = sparse_bitfield:get_bit(100000, S5),
    false = sparse_bitfield:get_bit(1000000, S5),

    376 = sparse_bitfield:byte_length(S4),
    376 * 8 = sparse_bitfield:bit_length(S4),
    ok.

test_byte_length() ->
    State = batch_set(7),
    1 = sparse_bitfield:byte_length(State),

    S1 = batch_set(15),
    2 = sparse_bitfield:byte_length(S1),

    S2 = batch_set(24),
    4 = sparse_bitfield:byte_length(S2).

batch_set(N) ->
    State = sparse_bitfield:new(),
    batch_set_n(N, State, 0).

batch_set_n(N, State, N) ->
    State;
batch_set_n(N, State, Count) ->
    {ok, _, S1} = sparse_bitfield:set_bit(N, true, State),
    batch_set_n(N, S1, Count + 1).
