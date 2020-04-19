library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



entity cpu is
port (
  clk: in std_logic;
  rst: in std_logic;
  input:  in  cpu_input;
  output: out cpu_output
);
end entity cpu;



architecture twoproc of cpu_basic is
  signal si, so: cpu_internal;
begin

p_comb: process (input, si)
  variable i: cpu_input;
  variable o: cpu_output;
  variable s: cpu_internal;
begin
  i := input;
end process;

p_seq: process (clk, rst)
  variable o: cpu_output;
begin
  if rst = '1' then
    o.state.run := '0';
    o.state.fetch := '0';
    o.state.decode := '0';
    o.state.execute := '0';
    o.mem.addr := 0;
    o.mem.data := 0;
    o.mem.rd := '0';
    o.mem.wr := '0';
    o.reg.r0 := 0;
    o.reg.r1 := 0;
    o.reg.r2 := 0;
    o.reg.r3 := 0;
    o.reg.ip := 0;
  elsif rising_edge(clk) then
    si <= so;
  end if;
  output <= o;
end process;

end architecture twoproc;
