library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.types_memory.all;



-- memory interface
entity memory is
generic(
  WAIT_RD: natural := 2
);
port(
  clk:    in  std_logic;
  input:  in  memory_in;
  output: out memory_out
);
end entity memory;



architecture bh of memory is
  signal data:   memory_data;
  signal si, so: memory_state;
begin

  -- update state, output on clock
  p_seq: process (clk) is
  begin
    if rising_edge(clk) then
      si <= so;
      output <= so.output;
    end if;
  end process;
  
  -- update state
  p_comb: process (input, si)
    variable s: memory_state;
  begin
    s := si;
    -- write data immediately
    if input.wr = '1' then
      data(to_integer(input.addr)) <= input.data;
    -- save read request
    elsif input.rd = '1' then
      s.count := WAIT_RD;
      s.input := input;
      s.output.rd := '0';
    end if;
    -- wait for read
    if s.count > 0 then
      s.count := s.count - 1;
    -- output read value
    elsif s.input.rd = '1' then
      s.output.data := data(to_integer(s.input.addr));
      s.output.rd := '1';
      s.input.rd := '0';
    end if;
    so <= s;
  end process;
  
end architecture bh;
