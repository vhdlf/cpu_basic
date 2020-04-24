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
constant OP_HALT:  bits8 := x"00";

constant OP_LOAD:  bits8 := x"10";
constant OP_STORE: bits8 := x"11";
constant OP_MOVI:  bits8 := x"12";
constant OP_MOV:   bits8 := x"13";

constant OP_CMP:   bits8 := x"20";
constant OP_JMP:   bits8 := x"21";
constant OP_JZ:    bits8 := x"22";
constant OP_JNZ:   bits8 := x"23";
constant OP_JB:    bits8 := x"24";
constant OP_JBE:   bits8 := x"25";
constant OP_JG:    bits8 := x"26";
constant OP_JGE:   bits8 := x"27";

constant OP_ADD:   bits8 := x"30";
constant OP_ADC:   bits8 := x"31";
constant OP_SUB:   bits8 := x"32";
constant OP_SBB:   bits8 := x"33";
constant OP_MUL:   bits8 := x"34";
constant OP_IMUL:  bits8 := x"35";
constant OP_DIV:   bits8 := x"36";
constant OP_IDIV:  bits8 := x"37";

constant OP_AND:   bits8 := x"40";
constant OP_OR:    bits8 := x"41";
constant OP_NOT:   bits8 := x"42";
constant OP_XOR:   bits8 := x"43";
constant OP_SHL:   bits8 := x"44";
constant OP_SHR:   bits8 := x"45";
constant OP_ROL:   bits8 := x"46";
constant OP_ROR:   bits8 := x"47";



-- flags
constant FL_CARRY:    integer := 0;
constant FL_ZERO:     integer := 1;
constant FL_SIGN:     integer := 2;
constant FL_OVERFLOW: integer := 3;



-- output
type cpu_output is record
  -- status
  state: bits4;
  ip:    bits8;
  -- instruction
  op:    bits8;
  rd:    bits4;
  rs:    bits4;
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
