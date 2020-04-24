library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg_bits is

-- data sizes
subtype bits4   is unsigned (3   downto 0);
subtype bits8   is unsigned (7   downto 0);
subtype bits16  is unsigned (15  downto 0);
subtype bits32  is unsigned (31  downto 0);
subtype bits64  is unsigned (63  downto 0);
subtype bits128 is unsigned (127 downto 0);
subtype word    is bits32;
subtype dword   is bits64;

end package pkg_bits;
