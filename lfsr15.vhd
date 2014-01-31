library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LFSR15 is
	port (
		CLK	: in std_logic;
		RST	: in std_logic;
		RAND	: out std_logic_vector(14 downto 0)
	);
end LFSR15;

architecture RTL of LFSR15 is
	signal FEEDBACK : std_logic;
	signal SR : std_logic_vector(14 downto 0);
begin
	RAND <= SR;
	FEEDBACK <= SR(14) xor SR(13);
	
	process (CLK, RST) begin
		if (RST = '0') then
			SR <= "000000000000001";
		elsif(CLK'event and CLK = '1') then
			SR <= SR(13 downto 0) & FEEDBACK;
		end if;
	end process;
end RTL;
