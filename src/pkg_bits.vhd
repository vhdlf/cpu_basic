library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg_bits is

-- data sizes
subtype  byte is integer range 0 to 255;
constant byte_values: integer := byte'high + 1;
subtype bits4   is unsigned (3   downto 0);
subtype bits8   is unsigned (7   downto 0);
subtype bits16  is unsigned (15  downto 0);
subtype bits32  is unsigned (31  downto 0);
subtype bits33  is unsigned (32  downto 0);
subtype bits64  is unsigned (63  downto 0);
subtype bits65  is unsigned (64  downto 0);
subtype word    is bits32;
subtype word1   is bits33;
subtype dword   is bits64;
subtype dword1  is bits65;

end package pkg_bits;
