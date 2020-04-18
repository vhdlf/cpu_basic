library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package types is

-- we are making an 8-bit cpu
subtype  byte is integer range 0 to 255;
constant byte_all: integer := byte'high + 1;


-- with only 256 bytes memory
subtype  address is integer range 0 to 255;
type     memory  is array (address) of byte;

-- and only 4 registers
type cpu_registers is record
  r0: byte;
  r1: byte;
  r2: byte;
  r3: byte;
  r4: byte
end record cpu_registers;


-- memory gives data, and readability
type cpu_memory_in  is record
  data: byte;
  rd:   std_logic
end record cpu_memory_in;

-- memory takes address, data, and command
type cpu_memory_out is record
  addr: address;
  data: byte;
  rd:   std_logic;
  wr:   std_logic
end record cpu_memory_out;


-- cpu can be in these states
type cpu_state is (
  halted,
  paused,
  fetch_addr,
  fetch_read,
  decode_byte1,
  decode_byte2,
  execute
);

-- you can ask it to run
type cpu_state_in is record
  run: std_logic
end record cpu_state_in;

-- and it will indicate its status
type cpu_state_out is record
  run:     std_logic;
  fetch:   std_logic;
  decode:  std_logic;
  execute: std_logic
end record cpu_state_out;


-- input interface
type cpu_input is record
  sta: cpu_state_in;
  mem: cpu_memory_in
end record cpu_input;

-- output interface
type cpu_output is record
  sta: cpu_state_out;
  mem: cpu_memory_out;
  reg: cpu_registers
end record cpu_output;  

end package types;



-- Wrote this after following:
-- gardintrapp/cpu_4004 by Oddbjorn Norstrand
-- Thank you.
