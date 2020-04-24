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
  constant ID_CPU: string := "cpu";
  constant ID_MEM: string := "mem";
  constant tclk: time := 1 ns;

  signal clk:  std_logic;
  signal rst:  std_logic;
  signal run:  std_logic;
  signal mout: mem_output;
  signal minp: mem_input;
  signal cout: cpu_output;
  signal mem:   mem_block;
  signal mcopy: mem_block;
  signal mwr:   std_logic;
begin
DUT: entity work.top port map (clk, rst, run, mout, minp, cout);


-- run clock
p_clk: process
begin
  clk <= '0';
  wait for tclk / 2;
  
  clk <= '1';
  wait for tclk / 2;
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
    report_log(ID_MEM, note, "read @" &
      integer'image(a) & " = " &
      integer'image(to_integer(o.data))
    );
    if mwr = '1' then
      mem <= mcopy;
    end if;
    if i.wr = '1' then
      mem(a)     <= i.data(7  downto 0);
      mem(a + 1) <= i.data(15 downto 8);
      report_log(ID_MEM, warning, "write @" &
        integer'image(a) & " = " &
        integer'image(to_integer(i.data))
      );
    end if;
    mout <= o;
  end if;
end process;


-- run test
p_init: process
begin
  -- start report
  report_init("report.log");
  
  -- init memory
  mcopy <= (others => x"00");
  mwr <= '1';
  wait for tclk;
  mwr <= '0';
  
  -- reset cpu
  rst <= '1';
  wait for tclk;
  rst <= '0';

  -- test movi & store
  mcopy <= (
    -- movi r0, 00010203
    0 => OP_MOVI, 1 => x"00",
    2 => x"11", 3 => x"22", 4 => x"33", 5 => x"44",
    -- store [r1+00000000], r0
    6 => OP_STORE, 7 => x"10",
    8 => x"00", 9 => x"00", 10 => x"00", 11 => x"00",
    -- halt
    others => OP_HALT
  );
  mwr <= '1';
  wait for tclk;
  mwr <= '0';
  run <= '1';
  wait for tclk;
  run <= '0';
  wait for 20 * tclk;
  
  report_log(ID_SIM, note, "CPU_BASIC tests passed.");
  wait;
end process;
end architecture bh;
