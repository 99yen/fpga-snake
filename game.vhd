library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity GAME is
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
end GAME;

architecture RTL of GAME is
	component LFSR16
		port (
			CLK	: in std_logic;
			RST	: in std_logic;
			RAND	: out std_logic_vector(15 downto 0)
		);
	end component;	
	
	component LFSR15
		port (
			CLK	: in std_logic;
			RST	: in std_logic;
			RAND	: out std_logic_vector(14 downto 0)
		);
	end component;

	type POINT is
		record
			X : integer range -1 to 31;
			Y : integer range -1 to 31;
		end record;
		
	type REGISTERFILE is array(47 downto 0) of POINT;

	signal SNAKE_FILE : REGISTERFILE;
	signal SNAKE_NEXT : POINT;

	type DIRECTION is (UP, DOWN, RIGHT, LEFT);
	
	type GAME_STATE_T is (IDLE, VISIBLE_WAIT, BLANK_WAIT, COUNTER_WAIT, 
	                      CHECK_BORDER, CHECK_EAT_ONESELF, SHIFT, CHECK_FOOD, CHECK_WIN, 
								 MAKE_FOOD, SET_WAIT, GAMECLEAR, GAMEOVER);
	signal GAME_STATE : GAME_STATE_T;
	
	signal FOOD : POINT;
	signal RAND : POINT;
	
	signal COMPRD_POINT : POINT;
	signal POINT_EXIST : std_logic;
	
	signal SNAKE_DIRECTION, PREV_DIRECTION : DIRECTION;
	signal KEY_PUSH, CODE_ENABLE_PRE : std_logic;
	
	signal SNAKE_SPEED, WAIT_CNT : integer range 0 to 120;
	signal SNAKE_LENGTH : integer range 0 to 48;
	
	signal WALL : std_logic;
	
	signal RAND_A : std_logic_vector(15 downto 0);
	signal RAND_B : std_logic_vector(14 downto 0);
	
begin	
	U_LFSR16 : LFSR16 port map(CLK => CLK, RST => RST, RAND => RAND_A);
	U_LFSR15 : LFSR15 port map(CLK => CLK, RST => RST, RAND => RAND_B);
	
	SNAKE_NEXT.Y <= (SNAKE_FILE(0).Y - 1) when SNAKE_DIRECTION = UP   else
	                (SNAKE_FILE(0).Y + 1) when SNAKE_DIRECTION = DOWN else
						  SNAKE_FILE(0).Y;
	SNAKE_NEXT.X <= (SNAKE_FILE(0).X - 1) when SNAKE_DIRECTION = LEFT  else
	                (SNAKE_FILE(0).X + 1) when SNAKE_DIRECTION = RIGHT else
						  SNAKE_FILE(0).X;

	WALL <= '1' when SNAKE_NEXT.X = -1 or SNAKE_NEXT.Y = -1 or
	                 SNAKE_NEXT.X = 26 or SNAKE_NEXT.Y = 26 else
			  '0';
	DEBUG <= '1' when GAME_STATE = IDLE else '0';
	
	SCORE <= CONV_std_logic_vector(SNAKE_LENGTH, 8);
	
	-- Compare Snake Point with oneself or food
	COMPRD_POINT <= SNAKE_NEXT when GAME_STATE = CHECK_EAT_ONESELF else FOOD;
	process (COMPRD_POINT, SNAKE_LENGTH, SNAKE_FILE)
		variable TMP : std_logic;
	begin
		TMP := '0';
		for I in 0 to 47 loop
			if (SNAKE_FILE(I) = COMPRD_POINT and I < SNAKE_LENGTH) then
				TMP := '1';
			end if;
		end loop;
		
		POINT_EXIST <= TMP;
	end process;
	
	-- Compare Snake point with Graphic output
	process (MAP_X, MAP_Y, SNAKE_LENGTH, SNAKE_FILE, FOOD)
		variable TMP : std_logic;
	begin
		TMP := '0';
		for I in 0 to 47 loop
			if (SNAKE_FILE(I).X = MAP_X and SNAKE_FILE(I).Y = MAP_Y and I < SNAKE_LENGTH) then
				TMP := '1';
			elsif (FOOD.X = MAP_X and FOOD.Y = MAP_Y) then
				TMP := '1';
			end if;
		end loop;
		
		VISIBLE <= TMP;
	end process;
	
	-- game main state machine
	process(CLK, RST) 
		variable TMP : std_logic;
	begin
		if (RST = '0') then
			GAME_STATE <= IDLE;
			SNAKE_LENGTH <= 1;
			
			WAIT_CNT <= 0;

			FOOD.X <= 31;
			FOOD.Y <= 31;
			
		elsif (CLK'event and CLK = '1') then
			case GAME_STATE is
				when IDLE =>
					if (KEY_PUSH = '1' and KEYCODE = X"29") then -- push space key
						WAIT_CNT <= 0;
						SNAKE_LENGTH <= 1;
						
						case RAND_A(1 downto 0) is
							when "00" =>	
								FOOD.X <= 5;
								FOOD.Y <= 5;
							when "01" =>	
								FOOD.X <= 20;
								FOOD.Y <= 5;
							when "10" =>	
								FOOD.X <= 5;
								FOOD.Y <= 20;
							when others =>	
								FOOD.X <= 20;
								FOOD.Y <= 20;
						end case;
						
						GAME_STATE <= VISIBLE_WAIT;
					else
						GAME_STATE <= IDLE;
					end if;
				
				when VISIBLE_WAIT =>
					if (BLANKING = '1') then
						GAME_STATE <= BLANK_WAIT;
					else
						GAME_STATE <= VISIBLE_WAIT;
					end if;
				
				when BLANK_WAIT =>
					if (BLANKING = '0') then
						GAME_STATE <= COUNTER_WAIT;
					else
						GAME_STATE <= BLANK_WAIT;
					end if;
				
				when COUNTER_WAIT =>
					if (WAIT_CNT = 0) then
						GAME_STATE <= CHECK_BORDER;
					else
						WAIT_CNT <= WAIT_CNT - 1;
						GAME_STATE <= VISIBLE_WAIT;
					end if;
				
				when CHECK_BORDER =>
					if (WALL = '1') then
						GAME_STATE <= GAMEOVER;
					else
						GAME_STATE <= CHECK_EAT_ONESELF;
					end if;
				
				when CHECK_EAT_ONESELF =>
					if (POINT_EXIST = '1') then
						GAME_STATE <= GAMEOVER;
					else
						GAME_STATE <= SHIFT;
					end if;
					
				when SHIFT =>
					PREV_DIRECTION <= SNAKE_DIRECTION;
					GAME_STATE <= CHECK_FOOD;
					
				when CHECK_FOOD =>
					if (SNAKE_FILE(0) = FOOD) then
						SNAKE_LENGTH <= SNAKE_LENGTH + 1;
						GAME_STATE <= CHECK_WIN;
					else
						GAME_STATE <= SET_WAIT;
					end if;

				when CHECK_WIN =>
					if (SNAKE_LENGTH = 47) then
						GAME_STATE <= GAMECLEAR;
					else
						FOOD <= RAND;
						GAME_STATE <= MAKE_FOOD;
					end if;
				
				when MAKE_FOOD =>
					if (POINT_EXIST = '0') then
						GAME_STATE  <= SET_WAIT;
					else
						FOOD <= RAND;
						GAME_STATE <= MAKE_FOOD;
					end if;
				
				when SET_WAIT =>
					case SNAKE_LENGTH is
						when 0 to 3 =>
							WAIT_CNT <= 14;
						when 4 to 10 =>
							WAIT_CNT <= 13;
						when 11 to 15 =>
							WAIT_CNT <= 10;
						when 16 to 20 =>
							WAIT_CNT <= 8;
						when 21 to 25 =>
							WAIT_CNT <= 6;
						when 26 to 35 =>
							WAIT_CNT <= 5;
						when 36 to 43 =>
							WAIT_CNT <= 5;
						when 44 to 47 =>
							WAIT_CNT <= 3;
						when others =>
							WAIT_CNT <= 40;
					end case;
					
					GAME_STATE <= VISIBLE_WAIT;
				
				when GAMECLEAR =>
					GAME_STATE <= IDLE;
				
				when GAMEOVER =>
					GAME_STATE <= IDLE;
				
			end case;
		end if;
	end process;
	
	-- make food
	process (RAND_A, RAND_B)
		variable CANADIATE : POINT;
	begin
		CANADIATE.X := CONV_INTEGER(RAND_A(4 downto 0));
		CANADIATE.Y := CONV_INTEGER(RAND_B(4 downto 0));
		
		if (CANADIATE.X > 25) then
			CANADIATE.X := CANADIATE.X - 13;
		end if;
		if (CANADIATE.Y > 25) then
			CANADIATE.Y := CANADIATE.Y - 13;
		end if;	
		
		RAND <= CANADIATE;
	end process;
	
	-- Shift Snake Shift Register File
	-- I don't know why, but State machie viewer does not work when this process is exist.
	process (CLK, RST, GAME_STATE, SNAKE_FILE, SNAKE_NEXT) begin
		if (RST = '0') then
			SNAKE_FILE(0).X <= 13;
			SNAKE_FILE(0).Y <= 13;
			
			for I in 1 to 47 loop
				SNAKE_FILE(I).X <= 0;
				SNAKE_FILE(I).Y <= 0;
			end loop;
		elsif (CLK'event and CLK = '1') then
			if (GAME_STATE = IDLE) then
				SNAKE_FILE(0).X <= 13;
				SNAKE_FILE(0).Y <= 13;
			elsif (GAME_STATE = SHIFT) then
				SNAKE_FILE(0) <= SNAKE_NEXT;
				for I in 1 to 47 loop
					SNAKE_FILE(I) <= SNAKE_FILE(I-1);
				end loop;
			end if;
		end if;
	end process;
	
	-- keyboard input
	process(CLK, RST) begin
		if (RST = '0') then
			CODE_ENABLE_PRE <= '0';
			KEY_PUSH <= '0';
		elsif (CLK'event and CLK = '1') then
			if (CODE_ENABLE = '1' and CODE_ENABLE_PRE = '0') then
				KEY_PUSH <= '1';
				CODE_ENABLE_PRE <= CODE_ENABLE;
			else
				KEY_PUSH <= '0';
				CODE_ENABLE_PRE <= CODE_ENABLE;
			end if;
		end if;
	end process;
	
	-- keyboard direction
	process(CLK, RST) begin
		if (RST = '0') then
			SNAKE_DIRECTION <= UP;
		elsif(CLK'event and CLK ='1') then
			if (KEY_PUSH = '1') then
				if (KEYCODE = X"72" and PREV_DIRECTION /= UP) then
					SNAKE_DIRECTION <= DOWN;
				elsif (KEYCODE = X"75" and PREV_DIRECTION /= DOWN) then
					SNAKE_DIRECTION <= UP;
				elsif (KEYCODE = X"74" and PREV_DIRECTION /= LEFT) then
					SNAKE_DIRECTION <= RIGHT;
				elsif (KEYCODE = X"6B" and PREV_DIRECTION /= RIGHT) then
					SNAKE_DIRECTION <= LEFT;
				end if;
			end if;
		end if;
	end process;
	
end RTL;
