library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;


package pkg_cpu is

-- registers
type cpu_registers is array (15 downto 0) of word;


-- instruction
type cpu_instruction is record
  op:   bits8;
  rd:   bits4;
  rs:   bits4;
  imm:  word;
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


-- status
type cpu_status is record
  state: cpu_state;
  regs:  cpu_registers;
  flags: bits4;
  ip:    word;
end record cpu_status;


-- internal
type cpu_internal is record
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
