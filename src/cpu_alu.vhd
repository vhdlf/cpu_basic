library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



entity cpu_alu is
port(
  clk: in std_logic;
  cmd: in alu_command;
  in0: in  std_logic_vector (31 downto 0);
  in1: in  std_logic_vector (31 downto 0);
  out0: out std_logic_vector (31 downto 0);
  out1: out std_logic_vector (31 downto 0)
);
end entity cpu_alu;



architecture bh of cpu_alu is
begin

p1: process(clk)
  variable x: unsigned (31 downto 0);
  variable y: unsigned (31 downto 0);
  variable a: unsigned (63 downto 0);
begin
  if rising_edge(clk) then
    x := unsigned(in0);
    y := unsigned(in1);
    case cmd is
      when alu_and =>
        a := x and y;
      
      when alu_or =>
        a := x or y;

      when alu_not =>
        a := (not x);
      
      when alu_xor =>
        a := ((not x) and y) or (x and (not y));
      
      when alu_add =>
        a := x + y;
      
      when alu_sub =>
        a := x - y;
      
      when alu_mul =>
        a := x * y;
      
      when others =>
        a := x / y;
    end case;
    out0 <= std_logic_vector(a(31 downto 0));
    out1 <= std_logic_vector(a(63 downto 32));
  end if;
end process;

end bh;
