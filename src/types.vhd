library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package types is

-- we are making a 16-bit cpu
subtype byte  is std_logic_vector ((8-1)  downto 0);
subtype word  is std_logic_vector ((16-1) downto 0);
subtype dword is std_logic_vector ((32-1) downto 0);
subtype qword is std_logic_vector ((64-1) downto 0);


-- with 16 registers
type cpu_registers is array (0 to (16-1)) of word;


-- cpu can be in these states
-- type cpu_state is (
--   halted,
--   paused,
--   fetch_addr,
--   fetch_read,
--   decode_byte1,
--   decode_byte2,
--   execute
-- );

-- -- you can ask it to run
-- type cpu_state_in is record
--   run: std_logic;
-- end record cpu_state_in;

-- -- and it will indicate its status
-- type cpu_state_out is record
--   run:     std_logic;
--   fetch:   std_logic;
--   decode:  std_logic;
--   execute: std_logic;
-- end record cpu_state_out;


-- -- input interface
-- type cpu_input is record
--   state: state_in;
--   mem:   memory_in;
-- end record cpu_input;

-- -- output interface
-- type cpu_output is record
--   state: cpu_state_out;
--   mem:   cpu_memory_out;
--   reg:   cpu_registers;
-- end record cpu_output;  

-- type cpu_internal is record
--   state: cpu_state;
--   reg:   cpu_registers;
-- end record cpu_internal;


-- type alu_command is (
--   alu_and,
--   alu_or,
--   alu_not,
--   alu_xor,
--   alu_add,
--   alu_sub,
--   alu_mul,
--   alu_div
-- );


-- procedure cpu_registers_reset (
--   signal r: out cpu_registers);

end package types;



package body types is

-- procedure cpu_registers_reset (
--   signal r: out cpu_registers) is
-- begin
--   r.r0 <= 0;
--   r.r1 <= 0;
--   r.r2 <= 0;
--   r.r3 <= 0;
--   r.ip <= 0;
-- end procedure cpu_registers_reset;

end package body types;


-- Wrote this after following:
-- gardintrapp/cpu_4004 by Oddbjorn Norstrand
-- Thank you.
