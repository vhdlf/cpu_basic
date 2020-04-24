library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg_bits is

-- data sizes
subtype bits4  is std_logic_vector (3  downto 0);
subtype bits8  is std_logic_vector (7  downto 0);
subtype bits16 is std_logic_vector (15 downto 0);
subtype bits32 is std_logic_vector (31 downto 0);
subtype bits64 is std_logic_vector (63 downto 0);
subtype bits65 is std_logic_vector (64 downto 0);

end package pkg_bits;
