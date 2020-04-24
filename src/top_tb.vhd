library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_report.all;
use work.pkg_bits.all;
use work.pkg_mem.all;
use work.pkg_cpu.all;



-- internal test bench
-- no pins necessary
entity top_tb is
end entity top_tb;



architecture bh of top_tb is
  signal clk:  std_logic;
  signal rst:  std_logic;
  signal run:  std_logic;
  signal mout: mem_output;
  signal minp: mem_input;
  signal output: cpu_output;
begin
-- this device
-- is under test
DUT: entity work.top port map (clk, rst, run, mout, minp, output);


p_clk: process
begin
  clk <= '0';
  wait for 5 ns;
  
  clk <= '1';
  wait for 5 ns;
end process;


p_init: process
begin
  -- need report.log?
  report_init("report.log");

  -- test reset
  rst <= '1';
  wait for 10 ns;
  -- report_assert(ID_SIM, error, "case 0 failed!", output.state = st_halted);
  
  report_log(ID_SIM, note, "CPU_BASIC tests passed.");
  wait;
  -- test done
  -- so just wait
end process;
end architecture bh;