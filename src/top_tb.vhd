library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.txt_util.all;
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
  variable a: integer range 0 to 65535;
begin
  i := minp;
  o := mout;
  a := to_integer(i.addr);
  
  if falling_edge(clk) then
    -- output
    o.data(7  downto 0) := mem(a);
    o.data(15 downto 8) := mem(a + 1);
    if mwr = '1' then
      mem <= mcopy;
    end if;
    if i.wr = '1' then
      report "write @" & str(a) & ": " & hstr(i.data) severity note;
      mem(a)     <= i.data(7  downto 0);
      mem(a + 1) <= i.data(15 downto 8);
    end if;
    mout <= o;
  end if;
end process;


-- run test
p_init: process
begin
  -- init memory
  mcopy <= (others => x"00");
  mwr <= '1';
  wait for tclk;
  mwr <= '0';
  
  -- reset cpu
  rst <= '1';
  wait for tclk;
  rst <= '0';

  -- test factorial program
  mcopy <= (
    -- movi r0, 00000005
    0 => OP_MOVI, 1 => x"00",
    2 => x"05", 3 => x"00", 4 => x"00", 5 => x"00",
    -- inc r1
    6 => OP_INC, 7 => x"01",
    -- mul r1, r0
    8 => OP_MUL, 9 => x"01",
    -- dec r0
    10 => OP_DEC, 11 => x"00",
    -- cmp r0, r2
    12 => OP_CMP, 13 => x"20",
    -- jnz 00000008
    14 => OP_JNZ, 15 => x"00",
    16 => x"08", 17 => x"00", 18 => x"00", 19 => x"00",
    -- store [r2+00000000], r1
    20 => OP_STORE, 21 => x"12",
    22 => x"00", 23 => x"00", 24 => x"00", 25 => x"00",
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
  wait;
end process;
end architecture bh;
