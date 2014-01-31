library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity XY2MAP is
	port (
		VGA_X, VGA_Y	: in std_logic_vector(9 downto 0);
		GRID_X, GRID_Y	: out std_logic_vector(5 downto 0);
		BOX_X, BOX_Y	: out std_logic_vector(3 downto 0)
	);
end XY2MAP;

architecture RTL of XY2MAP is
begin
	-- divide by 16 (shift)
	GRID_X <= VGA_X(9 downto 4);
	GRID_Y <= VGA_Y(9 downto 4);
	
	BOX_X <= VGA_X(3 downto 0);
	BOX_Y <= VGA_Y(3 downto 0);
end RTL;
