library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CLK25M is
	port (
		CLK_IN	: in std_logic;
		CLK_OUT	: out std_logic
	);
end CLK25M;

architecture RTL of CLK25M is
	signal DIVIDER : std_logic;
begin
	CLK_OUT <= DIVIDER;
	
	process (CLK_IN) begin
		if(CLK_IN'event and CLK_IN = '1') then
			DIVIDER <= not DIVIDER;
		end if;
	end process;
end RTL;
