library ieee;
use ieee.std_logic_1164.all;

entity LED7SEG is
	port (
		A : in std_logic_vector(3 downto 0);
		Y : out std_logic_vector(6 downto 0)
	);
end LED7SEG;

architecture RTL of LED7SEG is
begin
	Y <= "0111111" when A = X"0" else
	     "0000110" when A = X"1" else
	     "1011011" when A = X"2" else
	     "1001111" when A = X"3" else
	     "1100110" when A = X"4" else
	     "1101101" when A = X"5" else
	     "1111101" when A = X"6" else
	     "0100111" when A = X"7" else
	     "1111111" when A = X"8" else
	     "1101111" when A = X"9" else
		  "1110111" when A = X"A" else
		  "1111100" when A = X"B" else
		  "0111001" when A = X"C" else
		  "1011110" when A = X"D" else
		  "1111001" when A = X"E" else
		  "1110001" when A = X"F" else
	     "1110110"; -- other
end RTL;
