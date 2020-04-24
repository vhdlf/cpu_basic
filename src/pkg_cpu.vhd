library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg_cpu is

-- data sizes
subtype bits4  is std_logic_vector (3  downto 0);
subtype bits8  is std_logic_vector (7  downto 0);
subtype bits16 is std_logic_vector (15 downto 0);
subtype bits32 is std_logic_vector (31 downto 0);
subtype bits64 is std_logic_vector (63 downto 0);


-- registers
type cpu_registers is array (15 downto 0) of bits64;


-- instruction
type cpu_instruction is record
  op: bits8;
  rd: bits4;
  rs: bits4;
  imm: bits64;
end record cpu_instruction;


-- opcodes
type cpu_opcode is (
  op_load,
  op_store,
  op_movi,
  op_mov,

  op_cmp,
  op_jmp,
  op_jz,
  op_jnz,
  op_jb,
  op_jbe,
  op_jg,
  op_jge,

  op_add,
  op_adc,
  op_sub,
  op_sbb,
  op_mul,
  op_imul,
  op_div,
  op_idiv,

  op_and,
  op_or,
  op_not,
  op_xor,
  op_shl,
  op_shr,
  op_rol,
  op_ror
);


-- states
type cpu_state is (
  st_halted,
  st_paused,
  st_fetch0,
  st_fetch1,
  st_fetch2,
  st_fetch3,
  st_fetch4,
  st_fetch5,
  st_load0,
  st_load1,
  st_load2,
  st_load3,
  st_execute0,
  st_execute1,
  st_store0,
  st_store1,
  st_store2,
  st_store3
);

end package pkg_cpu;


-- Wrote this after following:
-- gardintrapp/cpu_4004 by Oddbjorn Norstrand
-- Thank you.
