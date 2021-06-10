%%% @doc
%%% Space efficient way to track the location of bytes
%%% @end
-module(sparse_bitfield).

-export([
    new/0,
    set_bit/3,
    get_bit/2,
    byte_length/1,
    bit_length/1,
    calculate_index_in_page/2
]).

%% Make big enough to handle larger page sizes
-define(IDX_SIZE, 16).

-type state() :: {MemoryPager :: module(), ByteLength :: pos_integer()}.

%% @doc create an instance
-spec new() -> State :: state().
new() ->
    {
        memory_pager:new(),
        0
    }.

%% @doc Set the bit at the given index to either true | false
-spec set_bit(Index :: pos_integer(), Value :: boolean(), State :: state()) ->
    {ok, Changed :: boolean(), State :: state()} | erlang:error({badarg, term()}).
set_bit(Index, true, State) ->
    set(Index, 1, State);
set_bit(Index, false, State) ->
    set(Index, 0, State);
set_bit(_, Arg, _) ->
    erlang:error({badarg, Arg}).

%% @doc Check the value of the bit at the given index
-spec get_bit(Index :: pos_integer(), State :: state()) -> boolean().
get_bit(Index, {Pager, _}) ->
    PageNum = memory_pager:pagenum_for_byte_index(Index, Pager),
    PageSize = memory_pager:pagesize_in_bytes(Pager),
    ByteIndex = calculate_index_in_page(Index, PageSize),

    case memory_pager:get(PageNum, Pager) of
        {none, _} ->
            false;
        {ok, {_, Buffer}, _} ->
            case get_buffer_bit(ByteIndex, Buffer) of
                1 -> true;
                0 -> false
            end
    end.

%% @doc Return the number of bytes set
-spec byte_length(State :: state()) -> pos_integer().
byte_length({_, ByteLength}) ->
    ByteLength.

%% @doc Return the number of bits toggled
-spec bit_length(State :: state()) -> pos_integer().
bit_length({_, ByteLength}) ->
    ByteLength * 8.

%% @private
set(Index, Value, {Pager, ByteLength}) ->
    %% Get page number
    PageNum = memory_pager:pagenum_for_byte_index(Index, Pager),
    PageSize = memory_pager:pagesize_in_bytes(Pager),
    BytePageIndex = calculate_index_in_page(Index, PageSize),
    case memory_pager:get(PageNum, Pager) of
        {ok, {_, Buffer}, _} ->
            NewBuff = set_buffer_bit(BytePageIndex, Value, Buffer),
            {ok, Changed, Pager1} = memory_pager:set(PageNum, NewBuff, Pager);
        {none, _} ->
            Buffer = <<0:PageSize/unit:8>>,
            NewBuff = set_buffer_bit(BytePageIndex, Value, Buffer),
            {ok, Changed, Pager1} = memory_pager:set(PageNum, NewBuff, Pager)
    end,
    %% Set the byte length
    ByteIndex = calculate_byte_index(Index),
    case ByteIndex >= ByteLength of
        true -> {ok, Changed, {Pager1, ByteIndex + 1}};
        _ -> {ok, Changed, {Pager1, ByteLength}}
    end.

%% @private Get the bit at the given index
get_buffer_bit(Index, Buffer) ->
    %% Add an index to offset from the MSB.  Then grab the bit we want.
    <<N:?IDX_SIZE, _:N/bits, X:1, _/bits>> = list_to_binary([<<Index:?IDX_SIZE>>, Buffer]),
    X.

%% @private Set the bit at the given index
set_buffer_bit(Index, Value, Buffer) ->
    <<N:?IDX_SIZE, L:N/bits, _:1, R/bits>> = list_to_binary([<<Index:?IDX_SIZE>>, Buffer]),
    <<L/bits, Value:1, R/bits>>.

%% @private Calculate which byte a given Index is in
calculate_byte_index(Index) ->
    (Index - (Index band 7)) div 8.

%% @private Squish an index into the range for a given page size
calculate_index_in_page(Index, PageSize) ->
    Index band (PageSize - 1).
