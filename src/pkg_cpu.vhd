library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_bits.all;


package pkg_cpu is

-- registers
type cpu_registers is array (15 downto 0) of bits64;


-- instruction
type cpu_instruction is record
  op:   bits8;
  rd:   bits4;
  rs:   bits4;
  imm:  bits64;
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
  st_fetch4,
  st_fetch5,
  st_load0,
  st_load1,
  st_load2,
  st_load3,
  st_execute,
  st_store0,
  st_store1,
  st_store2,
  st_store3
);


-- status
type cpu_status is record
  state: cpu_state;
  regs:  cpu_registers;
  flags: bits64;
  ip:    bits64;
end record cpu_status;


-- internal
type cpu_internal is record
  -- instruction
  op:   bits8;
  rd:   bits4;
  rs:   bits4;
  imm:  bits64;
  -- memory
  addr: bits16;
  data: bits16;
  buff: bits64;
  wr:   std_logic;
end record cpu_internal;

end package pkg_cpu;
