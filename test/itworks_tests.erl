-module(itworks_tests).

-include_lib("eunit/include/eunit.hrl").

get_set_basic_test() ->
    S1 = sparse_bitfield:new(),
    false = sparse_bitfield:get_bit(0, S1),

    {ok, S2} = sparse_bitfield:set_bit(1, true, S1),
    false = sparse_bitfield:get_bit(0, S2),
    true = sparse_bitfield:get_bit(1, S2),
    false = sparse_bitfield:get_bit(0, S2),
    false = sparse_bitfield:get_bit(7, S2),
    false = sparse_bitfield:get_bit(8, S2),
    false = sparse_bitfield:get_bit(15, S2),
    false = sparse_bitfield:get_bit(16, S2),
    false = sparse_bitfield:get_bit(1000, S2),

    1 = sparse_bitfield:byte_length(S2),
    8 = sparse_bitfield:bit_length(S2),

    %% Flip
    {ok, S3} = sparse_bitfield:set_bit(1, false, S2),
    false = sparse_bitfield:get_bit(1, S3),

    1 = sparse_bitfield:byte_length(S3),
    8 = sparse_bitfield:bit_length(S3),
    ok.

more_sets_test() ->
    S0 = sparse_bitfield:new(),
    {ok, S1} = sparse_bitfield:set_bit(1, true, S0),
    {ok, S2} = sparse_bitfield:set_bit(1024, true, S1),
    {ok, S3} = sparse_bitfield:set_bit(2000, true, S2),
    {ok, S4} = sparse_bitfield:set_bit(3000, true, S3),
    {ok, S5} = sparse_bitfield:set_bit(100000, true, S4),

    true = sparse_bitfield:get_bit(1, S5),
    true = sparse_bitfield:get_bit(1024, S5),
    true = sparse_bitfield:get_bit(2000, S5),
    true = sparse_bitfield:get_bit(3000, S5),
    true = sparse_bitfield:get_bit(100000, S5),
    false = sparse_bitfield:get_bit(1000000, S5),

    376 = sparse_bitfield:byte_length(S4),
    376 * 8 = sparse_bitfield:bit_length(S4),
    ok.

what_test() ->
    S1 = sparse_bitfield:new(),
    {ok, S2} = sparse_bitfield:set_bit(4, true, S1),
    false = sparse_bitfield:get_bit(0, S2),
    false = sparse_bitfield:get_bit(1, S2),
    false = sparse_bitfield:get_bit(2, S2),
    false = sparse_bitfield:get_bit(3, S2),
    true = sparse_bitfield:get_bit(4, S2),
    false = sparse_bitfield:get_bit(5, S2),
    false = sparse_bitfield:get_bit(6, S2),
    false = sparse_bitfield:get_bit(7, S2),
    ok.

range_test() ->
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
    {ok, S1} = sparse_bitfield:set_bit(N, true, State),
    batch_set_n(N, S1, Count + 1).
