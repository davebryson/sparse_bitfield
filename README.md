# Sparse Bitfield

Flip a bit at a random location in a random sized binary


## Example
```erlang
    %% Create it
    State1 = sparse_bitfield:new(),

    %% Check the 11th bit is false.  False (0) is the default value
    false = sparse_bitfield:get_bit(11, State1),

    %% Set the 11th bit to true (1)
    %% It returns 'true' to show the bit has changed
    {ok, true, State2} = sparse_bitfield:set_bit(11, true, State1),

    %% Check again...it's set (true/1)
    true = sparse_bitfield:get_bit(11, State2),

    %% We said random locations earlier...let's prove it
    {ok, true, State3} = sparse_bitfield:set_bit(10002, true, State2),

    true = sparse_bitfield:get_bit(11, State3),
    true = sparse_bitfield:get_bit(10002, State3),
```