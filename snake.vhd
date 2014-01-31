-- snake game
-- 99yen
-- 2014/01/14

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SNAKE is
	port (
		CLK	: in std_logic;
		RST	: in std_logic;
		
		VGA_VS, VGA_HS : out std_logic;
		VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
		
		PS2_KBCLK, PS2_KBDAT : in std_logic;
		
		LED4, LED3, LED2, LED1 : out std_logic_vector(7 downto 0)
			;DEBUG : out std_logic
	);
end SNAKE;

architecture RTL of SNAKE is
	component CLK25M
		port (
			CLK_IN	: in std_logic;
			CLK_OUT	: out std_logic
		);
	end component;

	component VGA
	port (
		CLK		: in std_logic;
		RST		: in std_logic;
		R_IN		: in std_logic_vector(3 downto 0);
		G_IN		: in std_logic_vector(3 downto 0);
		B_IN		: in std_logic_vector(3 downto 0);
		
		X			: out std_logic_vector(9 downto 0);
		Y			: out std_logic_vector(9 downto 0);
		R_OUT		: out std_logic_vector(3 downto 0);
		G_OUT		: out std_logic_vector(3 downto 0);
		B_OUT		: out std_logic_vector(3 downto 0);
		BLANK_H	: out std_logic;
		BLANK_V	: out std_logic;
		HSYNC		: out std_logic;
		VSYNC		: out std_logic
	);
	end component;
	
	component PS2KEYBOARD
		port (
			CLK	: in std_logic;
			RST	: in std_logic;
			PS2_KBCLK, PS2_KBDAT : in std_logic;
			KEYCODE : out std_logic_vector(7 downto 0);
			CODE_ENABLE	: out std_logic
		);
	end component;
	
	component LED7SEG
		port (
			A  : in std_logic_vector(3 downto 0);
			Y : out std_logic_vector(6 downto 0)
	   );
	end component;
	
	component GENGRAPHIC
		port (
			VGA_X, VGA_Y	: in std_logic_vector(9 downto 0);
			TITLE	: in std_logic;
			SCORE	: in std_logic_vector(7 downto 0);
			VISIBLE	:	in std_logic;
			MAP_X, MAP_Y	: out std_logic_vector(5 downto 0);
			R_OUT, G_OUT, B_OUT	: out std_logic_vector(3 downto 0)
		);
	end component;

	component GAME
		port (
				CLK	: in std_logic;
				RST	: in std_logic;
				
				BLANKING : in std_logic;

				KEYCODE : in std_logic_vector(7 downto 0);
				CODE_ENABLE	: in std_logic;
				
				MAP_X, MAP_Y	: in std_logic_vector(5 downto 0);
				
				TITLE	: out std_logic;
				SCORE	: out std_logic_vector(7 downto 0);
				VISIBLE	:	out std_logic
							;DEBUG : out std_logic
		);
	end component;

	signal CLK_VGA : std_logic;
	signal X, Y : std_logic_vector(9 downto 0);
	
	signal R_IN, G_IN, B_IN : std_logic_vector(3 downto 0);
	signal R_OUT, G_OUT, B_OUT : std_logic_vector(3 downto 0);
	
	signal BLANK_H, BLANK_V : std_logic;

	signal KEYCODE : std_logic_vector(7 downto 0);
	signal CODE_ENABLE : std_logic;
	
	signal BOX_X, BOX_Y : std_logic_vector(5 downto 0);
	signal CN_PULSE : std_logic;
	
	signal LEDBUF1, LEDBUF2, LEDBUF3, LEDBUF4 : std_logic_vector(6 downto 0);
	
	signal VISIBLE : std_logic;
	
	signal MAP_X, MAP_Y : std_logic_vector(5 downto 0);
	
	signal SCORE : std_logic_vector(7 downto 0);
begin
	U_CLK: CLK25M 
		port map(CLK_IN => CLK, CLK_OUT => CLK_VGA);
	
	U_VGA: VGA 
		port map(
			CLK => CLK_VGA, RST => RST, 
			R_IN => R_OUT, G_IN => G_OUT, B_IN => B_OUT,
			X => X, Y => Y,
			R_OUT => VGA_R, G_OUT => VGA_G, B_OUT => VGA_B,
			BLANK_H => BLANK_H, BLANK_V => BLANK_V, 
			HSYNC => VGA_HS, VSYNC => VGA_VS);
	
	U_PS2: PS2KEYBOARD 
		port map(
			CLK => CLK_VGA, RST => RST, 
			PS2_KBCLK => PS2_KBCLK, PS2_KBDAT => PS2_KBDAT, 
			KEYCODE => KEYCODE, CODE_ENABLE => CODE_ENABLE);
	
	U_GENGRAPHIC : GENGRAPHIC 
		port map(
			VGA_X => X, VGA_Y => Y, 
			TITLE => '0', SCORE => "00000000", VISIBLE => VISIBLE,
			MAP_X => MAP_X, MAP_Y => MAP_Y,
			R_OUT => R_OUT, G_OUT => G_OUT, B_OUT => B_OUT);
	
	U_GAME : GAME
		port map (
			CLK => CLK_VGA, RST => RST,
			BLANKING => BLANK_V,
			KEYCODE => KEYCODE, CODE_ENABLE => CODE_ENABLE,
			MAP_X => MAP_X, MAP_Y => MAP_Y,
			TITLE => open, SCORE => SCORE, VISIBLE => VISIBLE, DEBUG => DEBUG);
	
	U_LED1: LED7SEG port map(A => KEYCODE(3 downto 0), Y => LEDBUF1);
	U_LED2: LED7SEG port map(A => KEYCODE(7 downto 4), Y => LEDBUF2);
	U_LED3: LED7SEG port map(A => SCORE(3 downto 0), Y => LEDBUF3);
	U_LED4: LED7SEG port map(A => SCORE(7 downto 4), Y => LEDBUF4);
	
	LED1 <= not (CODE_ENABLE & LEDBUF1);
	LED2 <= not ("0" & LEDBUF2);
	
	LED3 <= not ("1" & LEDBUF3);
	LED4 <= not ("0" & LEDBUF4);

end RTL;
