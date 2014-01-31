library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity GENGRAPHIC is
	port (
		VGA_X, VGA_Y	: in std_logic_vector(9 downto 0);
		TITLE	: in std_logic;
		SCORE	: in std_logic_vector(7 downto 0);
		VISIBLE	:	in std_logic;
		MAP_X, MAP_Y	: out std_logic_vector(5 downto 0);
		R_OUT, G_OUT, B_OUT	: out std_logic_vector(3 downto 0)
	);
end GENGRAPHIC;

architecture RTL of GENGRAPHIC is
	component XY2MAP
		port (
			VGA_X, VGA_Y	: in std_logic_vector(9 downto 0);
			GRID_X, GRID_Y	: out std_logic_vector(5 downto 0);
			BOX_X, BOX_Y	: out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal BOX_X, BOX_Y	: std_logic_vector(3 downto 0);
	signal GRID_X, GRID_Y	: std_logic_vector(5 downto 0);
	signal R_ENABLE, G_ENABLE, B_ENABLE, BOX_ENABLE	: std_logic;
	signal FRAME	: std_logic;
begin
	U1: XY2MAP port map(VGA_X => VGA_X, VGA_Y => VGA_Y, GRID_X => GRID_X, GRID_Y => GRID_Y, BOX_X => BOX_X, BOX_Y => BOX_Y);
	
	-- outer frame
	FRAME <= '1' when (VGA_Y = 30 or VGA_Y = 448 or VGA_X = 110 or VGA_X = 528) else '0';
	
	-- box
	MAP_X <= GRID_X - 7;
	MAP_Y <= GRID_Y - 2;
	
	BOX_ENABLE <= '0' when (BOX_X = "1111" or BOX_Y = "1111") else '1';

	R_ENABLE <= '1' when ((BOX_ENABLE = '1' and VISIBLE = '1') or FRAME = '1') else '0';
	G_ENABLE <= '1' when ((BOX_ENABLE = '1' and VISIBLE = '1') or FRAME = '1') else '0';
	B_ENABLE <= '1' when ((BOX_ENABLE = '1' and VISIBLE = '1') or FRAME = '1') else '0';
	
	R_OUT <= "1111" when R_ENABLE = '1' else "0000";
	G_OUT <= "1111" when G_ENABLE = '1' else "0000";
	B_OUT <= "1111" when B_ENABLE = '1' else "0000";
	
end RTL;
