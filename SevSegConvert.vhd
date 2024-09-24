library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SevSegConvert is
	Port ( 
		CLK			: in		STD_LOGIC;
		RST			: in		STD_LOGIC;
		DEC_SEL		: in		STD_LOGIC;
		HEX_SEL		: in		STD_LOGIC;
		INCREASE	: in		STD_LOGIC;
		DECREASE	: in		STD_LOGIC;
		DIG_SEL		: buffer	STD_LOGIC;
		SSD			: out		STD_LOGIC_VECTOR(6 downto 0)
	);
end SevSegConvert;

architecture Behavioral of SevSegConvert is

-- Signals
SIGNAL counter		: unsigned(7 downto 0) := (others => '0');
ALIAS  digit_0 is counter(7 downto 4);
ALIAS  digit_1 is counter(3 downto 0);

SIGNAL disp			: unsigned(3 downto 0) := (others => '0');
SIGNAL disp_dec		: unsigned(3 downto 0) := (others => '0');
SIGNAL disp_bin		: unsigned(3 downto 0) := (others => '0');

-- Refresh Rate for SSD
SIGNAL clk_size		: integer := 0;
CONSTANT clk_int	: integer := 50000;

-- Debouncing
SIGNAL db1, db2, db3 : std_logic := '0';
SIGNAL db4, db5, db6 : std_logic := '0';
SIGNAL INCREASE_DB : std_logic;
SIGNAL DECREASE_DB : std_logic;

-- States for ouput type
type formats is (BIN, DEC, HEX);
signal FMT: formats;

-- Seven Seg Display outputs 
CONSTANT ZERO	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0111111";
CONSTANT ONE	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000110";
CONSTANT TWO 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1011011";
CONSTANT THREE	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1001111";
CONSTANT FOUR	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100110";
CONSTANT FIVE 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1101101";
CONSTANT SIX	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111101";
CONSTANT SEVEN	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100111";
CONSTANT EIGHT 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";
CONSTANT NINE	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100111";
CONSTANT OxA	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1110111";
CONSTANT OxB 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111100";
CONSTANT OxC 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0111001";
CONSTANT OxD 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1011110";
CONSTANT OxE 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111001";
CONSTANT OxF 	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1110001";
CONSTANT dash	: std_logic_vector(6 DOWNTO 0) := "1000000";


begin
	SevSegDriver : process(CLK, RST) begin
		-- Reset counter and change format back to default.
		if (RST = '1') then
			counter <= (others => '0');
			FMT <= BIN;

		elsif rising_edge(CLK) then
			-- Check state
			if ((DEC_SEL = '0') and (HEX_SEL = '0')) then
				FMT <= BIN;
			elsif (DEC_SEL = '1') then
				FMT <= DEC;
			elsif (HEX_SEL = '1') then
				FMT <= HEX;
			end if;

			-- Check increase and decrease btn
			if (INCREASE_DB = '1') then 
				counter <= counter + 1;
			elsif (DECREASE_DB = '1') then
				counter <= counter - 1;
			end if;

			-- Left digit (tens place in decimal
			if (DIG_SEL = '1') then
				-- Hex digit
				disp <= digit_0;

				-- Binary Left digit
				if (counter < "00000100") then
					disp_bin <= digit_1 srl 1;
				else 
					disp_bin <= "1111";	
				end if;

				-- Binary limit
				if (counter > "01100011") then
					--- garbage value to display dash '-'
					disp_dec <= "1111";	
				else 
					disp_dec <= to_unsigned(((to_integer(counter)-(to_integer(counter) mod 10))/10),
					digit_0'length);
				end if;
				
			--  Right digit (ones place decimal)
			else
				disp <= digit_1;
				
				if (counter < "00000100") then
					disp_bin <= digit_1;
				else 
					disp_bin <= "1111";	
				end if;

				if (counter > "01100011") then
					--- garbage value to display dash '-'
					disp_dec <= "1111";	
				else
					disp_dec <= to_unsigned(to_integer(counter) mod 10, digit_0'length);
				end if;
				 
			end if;

			case(FMT) is 
				when BIN =>
					case(disp_bin) is
						when "0000" => SSD <= ZERO;
						when "0001" => SSD <= ONE;
						when "0010" => SSD <= ZERO;
						when "0011" => SSD <= ONE;
						when others => SSD <= dash;
					end case;
				when DEC =>
					case(disp_dec) is
						when "0000" => SSD <= ZERO;
						when "0001" => SSD <= ONE;
						when "0010" => SSD <= TWO;
						when "0011" => SSD <= THREE;
						when "0100" => SSD <= FOUR;
						when "0101" => SSD <= FIVE;
						when "0110" => SSD <= SIX;
						when "0111" => SSD <= SEVEN;
						when "1000" => SSD <= EIGHT;
						when "1001" => SSD <= NINE;
						when others => SSD <= dash;
					end case;
				when HEX =>
					case(disp) is
						when "0000" => SSD <= ZERO;
						when "0001" => SSD <= ONE;
						when "0010" => SSD <= TWO;
						when "0011" => SSD <= THREE;
						when "0100" => SSD <= FOUR;
						when "0101" => SSD <= FIVE;
						when "0110" => SSD <= SIX;
						when "0111" => SSD <= SEVEN;
						when "1000" => SSD <= EIGHT;
						when "1001" => SSD <= NINE;
						when "1010" => SSD <= OxA;
						when "1011" => SSD <= OxB;
						when "1100" => SSD <= OxC;
						when "1101" => SSD <= OxD;
						when "1110" => SSD <= OxE;
						when "1111" => SSD <= OxF;
						when others => SSD <= dash;
					end case;
			end case;
		end if;
	end process SevSegDriver;

	-- Process for debouncing switches. Very simple
	Debounce : process(CLK) begin
		if (CLK'event and CLK = '1') then
			db1 <= INCREASE;
			db2 <= db1;
			db3 <= db2;

			db4 <= DECREASE;
			db5 <= db4;
			db6 <= db5;
		end if;
	end process Debounce;

	-- Digit Selection Process
	Clock_Count : process(CLK) begin
		if rising_edge(CLK) then
			if (RST = '1') then
				clk_size <= 0;
				DIG_SEL <= '0';
			else
				if (clk_size = clk_int) then
					clk_size <= 0;
					DIG_SEL <= not DIG_SEL;
				else
					clk_size <= clk_size + 1;
				end if;
			end if;	
		end if;
	end process Clock_count;

	-- Store debounced signals for use in SevSegDriver Process
	INCREASE_DB <= db1 and db2 and (not db3);
	DECREASE_DB <= db4 and db5 and (not db6);
end Behavioral;
-- Signals
