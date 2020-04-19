--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--use work.types.all;
--
--
--entity cpu_alu_tb is
--end cpu_alu_tb;
--
--
--architecture bh of cpu_alu_tb is
--  signal clk: std_logic;
--  signal cmd: alu_command;
--  signal in0: std_logic_vector (31 downto 0);
--  signal in1: std_logic_vector (31 downto 0);
--  signal out0: std_logic_vector (31 downto 0);
--  signal out1: std_logic_vector (31 downto 0);
--begin
--  dut: entity work.cpu_alu port map (clk, cmd, in0, in1, out0, out1);
--  
--  p_clk: process
--  begin
--    clk <= '0';
--    wait for 5 ns;
--    clk <= '1';
--    wait for 5 ns;
--  end process;
--  
--  p_cmd: process
--  begin
--    cmd <= alu_and;
--    in0 <= x"00000001";
--    in1 <= x"00000020";
--    wait for 10ns;
--  end process;
--end bh;
