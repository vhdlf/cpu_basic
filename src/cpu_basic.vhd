library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;



entity cpu_basic is
  -- some constants
  generic (
    READ_LATENCY: natural := 2
  );
  
  -- IO interface
  port (
    clk: in std_logic,
    rst: in std_logic,
    
  );
end entity cpu_basic;



architecture twoproc of cpu_basic is
begin

end architecture twoproc;