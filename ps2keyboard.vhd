library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PS2KEYBOARD is
	port (
		CLK	: in std_logic;
		RST	: in std_logic;
		PS2_KBCLK, PS2_KBDAT : in std_logic;
		KEYCODE : out std_logic_vector(7 downto 0);
		CODE_ENABLE	: out std_logic
	);
end PS2KEYBOARD;

architecture RTL of PS2KEYBOARD is
	type STATE_SET is (START_BIT, DATA0, DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7, PARITY_BIT, STOP_BIT);

	signal PS2CLK : std_logic_vector(1 downto 0);
	signal KEYCODE_BUF : std_logic_vector(7 downto 0);
	signal STATE : STATE_SET;
	
	signal PARITY : std_logic;
begin	
	KEYCODE <= KEYCODE_BUF;
	PARITY <= KEYCODE_BUF(0) xor KEYCODE_BUF(1) xor KEYCODE_BUF(2) xor KEYCODE_BUF(3) xor
             KEYCODE_BUF(4) xor KEYCODE_BUF(5) xor KEYCODE_BUF(6) xor KEYCODE_BUF(7) xor '1';
	
	process (CLK, RST) begin
		if (RST = '0') then
			PS2CLK <= "00";
			STATE  <= START_BIT;
			KEYCODE_BUF <= (others => '0');
			CODE_ENABLE <= '0';
		elsif (CLK'event and CLK = '1') then
			PS2CLK <= PS2CLK(0) & PS2_KBCLK;
			
			if (PS2CLK = "10") then
				case STATE is
					when START_BIT =>
						if (PS2_KBDAT = '0') then
							STATE <= DATA0;
							CODE_ENABLE <= '0';
						else
							STATE <= START_BIT;
						end if;
					when DATA0 =>
						STATE <= DATA1;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA1 =>
						STATE <= DATA2;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA2 =>
						STATE <= DATA3;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA3 =>
						STATE <= DATA4;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA4 =>
						STATE <= DATA5;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA5 =>
						STATE <= DATA6;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA6 =>
						STATE <= DATA7;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when DATA7 =>
						STATE <= PARITY_BIT;
						KEYCODE_BUF <= PS2_KBDAT & KEYCODE_BUF(7 downto 1);
					when PARITY_BIT =>
						if (PS2_KBDAT = PARITY) then
							STATE <= STOP_BIT;
						else
							STATE <= START_BIT;
						end if;
					when STOP_BIT =>
						if (PS2_KBDAT = '1') then
							STATE <= START_BIT;
							CODE_ENABLE <= '1';
						else
							STATE <= START_BIT;
						end if;
				end case;
			end if;
		end if;
	end process;
end RTL;
