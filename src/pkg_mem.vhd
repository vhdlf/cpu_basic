library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;


package pkg_mem is

-- input
type mem_input is record
  addr: bits16;
  data: bits16;
  wr:   std_logic;
end record mem_input;


-- output
type mem_output is record
  data: bits16;
end record mem_output;

end package pkg_mem;
