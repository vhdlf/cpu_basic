library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package types is

-- we are making a 16-bit cpu
subtype byte  is std_logic_vector ((8-1)  downto 0);
subtype word  is std_logic_vector ((16-1) downto 0);


-- cpu can be in these states
type cpu_state is (
  state_halted,
  state_fetch0,
  state_fetch1,
  state_decode,
  state_load0,
  state_load1,
  state_store0,
  state_store1,
  state_execute
);


-- and execute following opcodes
type cpu_opcode is (
  opcode_ld,
  opcode_st,
  opcode_jmp,
  opcode_jz,
  opcode_jnz,
  opcode_jp,
  opcode_jn,
  opcode_mov,
  opcode_and,
  opcode_or,
  opcode_not,
  opcode_xor,
  opcode_add,
  opcode_adc,
  opcode_sub,
  opcode_sbb,
  opcode_mul,
  opcode_imul,
  opcode_div,
  opcode_idiv
);


-- with 16 + 1 (ip) registers
type cpu_registers is array (0 to (17-1)) of word;


-- 8-bit memory interface
type cpu_memory is record
  addr: address;
  dout: byte;
  din:  byte;
  wr:   std_logic;
end record cpu_memory;


-- instruction data (internal)
type cpu_instruction is record
  op: cpu_opcode;
  rd: word;
  rs: word;
  imm: word;
end record cpu_instruction;


-- fetch data (internal)
subtype cpu_fetch_data is array (0 to (4-1)) of byte;
type cpu_fetch is record
  addr: address;
  data: cpu_fetch_data;
  count: integer range 0 to (8-1)
end record cpu_fetch;


-- data (internal)
type cpu_data is record
  state: cpu_state;
  fetch: cpu_fetch;
  instr: cpu_instruction;
  regs:  cpu_registers;
  mem:   cpu_memory;
end record cpu_data;

end package types;


-- Wrote this after following:
-- gardintrapp/cpu_4004 by Oddbjorn Norstrand
-- Thank you.
