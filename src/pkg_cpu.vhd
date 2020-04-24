library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;


package pkg_cpu is

-- registers
type cpu_registers is array (15 downto 0) of word;


-- states
type cpu_state is (
  st_halted,
  st_fetch0,
  st_fetch1,
  st_fetch2,
  st_fetch3,
  st_load0,
  st_load1,
  st_execute,
  st_store0,
  st_store1
);


-- opcodes
--constant OP_HALT: bits8 := x"00";
--constant OP_LOAD: bits8 := x"01";

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


-- flags
type cpu_flags is (
  fl_carry,
  fl_zero,
  fl_sign,
  fl_overflow
);


-- output
type cpu_output is record
  state: bits4;
  ip:    bits16;
end record cpu_output;


-- internal
type cpu_internal is record
  -- status
  state: cpu_state;
  regs:  cpu_registers;
  flags: bits4;
  ip:    word;
  -- instruction
  op:   bits8;
  rd:   bits4;
  rs:   bits4;
  imm:  word;
  -- memory
  addr: bits16;
  data: bits16;
  buff: word;
  wr:   std_logic;
end record cpu_internal;

end package pkg_cpu;
