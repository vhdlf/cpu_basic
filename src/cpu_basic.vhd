library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



entity cpu_basic is
  -- some constants
  generic (
    READ_LATENCY: natural := 2
  );
  
  -- interface
  port (
    clk: in std_logic;
    rst: in std_logic;
    input:  in  cpu_input;
    output: out cpu_output
  );
end entity cpu_basic;



architecture twoproc of cpu_basic is
  signal r, rin: cpu_internal;
begin

  p_comb: process (input, r) is
    variable i: cpu_input;
    variable o: cpu_output;
    variable c: cpu_internal;
  begin
    c := r;
    
    case c.state is
      when halted =>
        o.state.run     := '0';
        o.state.fetch   := '0';
        o.state.decode  := '0';
        o.state.execute := '0';
        o.mem.addr := 0;
        o.mem.data := 0;
        o.mem.rd   := '0';
        o.mem.wr   := '0';
        if i.state.run := '1' then
          c.state := fetch_addr;
          c.reg.r0 := 0;
          c.reg.r1 := 0;
          c.reg.r2 := 0;
          c.reg.r3 := 0;
          c.reg.ip := 0;
        end if;
      
      when fetch_addr =>
        o.state.fetch := '1';
        o.mem.rd      := '1';
        o.mem.addr    := c.reg.ip;
        c.reg.ip      := (c.reg.ip + 1) mod byte_all;
        c.state       := fetch_read;
      
      when fetch_read =>
        o.state.fetch := '1';
        if i.mem.rd := '1' then
        end if;
      
      when decode =>
        o.state.decode := '1';
        
    end case;
  end process p_comb;

end architecture twoproc;
