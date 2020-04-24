library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_report.all;
use work.pkg_bits.all;
use work.pkg_mem.all;
use work.pkg_cpu.all;



entity top_tb is
end entity top_tb;



architecture bh of top_tb is
  signal clk:  std_logic;
  signal rst:  std_logic;
  signal run:  std_logic;
  signal mout: mem_output;
  signal minp: mem_input;
  signal cout: cpu_output;
  signal mem:  mem_block;
begin
DUT: entity work.top port map (clk, rst, run, mout, minp, cout);


-- run clock
p_clk: process
begin
  clk <= '0';
  wait for 5 ns;
  
  clk <= '1';
  wait for 5 ns;
end process;


-- 16-bit memory
p_mem: process (clk)
  variable i: mem_input;
  variable o: mem_output;
  variable a: integer range 0 to bits16'high;
begin
  i := minp;
  o := mout;
  a := to_integer(i.addr);
  
  if rising_edge(clk) then
    -- output 
    o.data(7  downto 0) := mem(a);
    o.data(15 downto 8) := mem(a + 1);
    if i.wr = '1' then
      mem(a)     <= i.data(7  downto 0);
      mem(a + 1) <= i.data(15 downto 8);
    end if;
    mout <= o;
  end if;
end process;


-- run test
p_init: process
begin
  report_init("report.log");

  rst <= '1';
  wait for 10 ns;
  
  report_log(ID_SIM, note, "CPU_BASIC tests passed.");
  wait;
end process;
end architecture bh;
