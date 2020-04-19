library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



package types_memory is

-- 64Kbytes memory
subtype address  is std_logic_vector ((16-1) downto 0);
type memory_data is array (0 to address'high) of byte;


type memory_in is record
  addr: address;
  data: byte;
  rd:   std_logic; -- read request
  wr:   std_logic; -- write request
end record memory_in;


type memory_out is record
  data: byte;
  rd:   std_logic; -- can read?
end record memory_out;


type memory_state is record
  count:  integer range 0 to 15;
  input:  memory_in;
  output: memory_out;
end record memory_state;

end package types_memory;
