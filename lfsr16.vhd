library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LFSR16 is
	port (
		CLK	: in std_logic;
		RST	: in std_logic;
		RAND	: out std_logic_vector(15 downto 0)
	);
end LFSR16;

architecture RTL of LFSR16 is
	signal FEEDBACK : std_logic;
	signal SR : std_logic_vector(15 downto 0);
begin
	RAND <= SR;
	FEEDBACK <= SR(15) xor SR(13) xor SR(12) xor SR(10);
	
	process (CLK, RST) begin
		if (RST = '0') then
			SR <= "0000000000000001";
		elsif(CLK'event and CLK = '1') then
			SR <= SR(14 downto 0) & FEEDBACK;
		end if;
	end process;
end RTL;
