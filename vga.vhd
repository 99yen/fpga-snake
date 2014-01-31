library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VGA is
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
end VGA;

architecture RTL of VGA is
	signal HSYNC_CNT : std_logic_vector(9 downto 0);
	signal VSYNC_CNT : std_logic_vector(9 downto 0);

	signal NEXT_HSYNC_CNT : std_logic_vector(9 downto 0);
	signal NEXT_VSYNC_CNT : std_logic_vector(9 downto 0);
	
	signal BLANK_H_BUF : std_logic;
	signal BLANK_V_BUF : std_logic;
	
	signal HSYNC_CARRY : std_logic;
begin
	-- VISIBLE 1 UNVISIBLE 0
	-- BLANKING AREA H
	BLANK_H_BUF <= '0' when (NEXT_HSYNC_CNT < 160) else '1';
	BLANK_H <= BLANK_H_BUF;
	-- BLANKING AERA V
	BLANK_V_BUF <= '0' when (NEXT_VSYNC_CNT < 36 or NEXT_VSYNC_CNT >= 516) else '1';
	BLANK_V <= BLANK_V_BUF;
	
	-- DISPLAYING X, Y
	X <= (NEXT_HSYNC_CNT - 160) when (BLANK_H_BUF = '1') else (others => '0');
	Y <= (NEXT_VSYNC_CNT -  36) when (BLANK_V_BUF = '1') else (others => '0');
	
	-- HSYNC COUNTER 800
	HSYNC_CARRY <= '1' when HSYNC_CNT = 799 else '0';
	NEXT_HSYNC_CNT <= (others => '0') when HSYNC_CNT = 799 else HSYNC_CNT + 1;
	process(CLK, RST) begin
		if (RST = '0') then
			HSYNC_CNT <= (others => '0');
			HSYNC <= '1';
		elsif (CLK'event and CLK = '1') then
			HSYNC_CNT <= NEXT_HSYNC_CNT;
			
			-- REFRESH COLOR OUTPUT
			if (BLANK_H_BUF = '1' and BLANK_H_BUF ='1') then
				R_OUT <= R_IN;
				G_OUT <= G_IN;
				B_OUT <= B_IN;
			else
				R_OUT <= (others => '0');
				G_OUT <= (others => '0');
				B_OUT <= (others => '0');
			end if;
			
			-- HSYNC SIGNAL (NEGATIVE) and BLANKING AREA
			if (NEXT_HSYNC_CNT = 16) then
				HSYNC <= '0';
			elsif (NEXT_HSYNC_CNT = 112) then
				HSYNC <= '1';
			end if;
			
		end if;
	end process;
	
	-- VSYNC COUNTER 525
	NEXT_VSYNC_CNT <= (others => '0') when VSYNC_CNT = 524 else VSYNC_CNT + 1;
	process(CLK, RST) begin
		if (RST = '0') then
			VSYNC_CNT <= (others => '0');
			VSYNC <= '0';
		elsif (CLK'event and CLK = '1') then
			if (HSYNC_CARRY = '1') then
				VSYNC_CNT <= NEXT_VSYNC_CNT;
				
				-- VSYNC SIGNAL (NEGATIVE) and BLANKING AREA
				if (NEXT_VSYNC_CNT = 0) then
					VSYNC <= '0';
				elsif (NEXT_VSYNC_CNT = 2) then
					VSYNC <= '1';
				end if;
			end if;
		end if;
	end process;
	
end RTL;
