LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY TestBench_ProjetSim IS

END TestBench_ProjetSim;

ARCHITECTURE beh OF TestBench_ProjetSim IS
		signal enter			: std_logic_vector(7 downto 0);
		signal iclk      :    STD_LOGIC; 
		signal reset_n   :    STD_LOGIC;  
		signal hexones   : std_logic_vector(6 downto 0);
		signal hextenths  : std_logic_vector(6 downto 0);
		signal hexhundredths  : std_logic_vector(6 downto 0);
		signal sda       :    STD_LOGIC;                    --serial data output of i2c bus
		signal scl       :    STD_LOGIC;
		signal sReady	  :  STD_LOGIC;
	   signal sStart		:  STD_LOGIC;
		signal sSlv_ack1		:  STD_LOGIC;					
		signal sSlv_ack2		:  STD_LOGIC;					--on sort des pins qui rapportent les etats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â©tat 
		signal sMstr_ack		:  STD_LOGIC;
		signal sStop		:  STD_LOGIC;
		signal sRd			: STD_LOGIC;
		signal d				:    STD_LOGIC; 
		
	
	
	
		
		  -- clock period for simulation
  constant clk_period : time := 10 ns;

	component ProjetSim IS
	  PORT(
		 enter			: in std_logic_vector(7 downto 0);
		 iclk       :  IN      STD_LOGIC;                    --system clock
		 reset_n   :  IN      STD_LOGIC;                    --active low reset
		 HEX1		: out std_logic_vector(6 downto 0); --OPCODE
		 HEX10		: out std_logic_vector(6 downto 0); --LSB of G
		 HEX100	: out std_logic_vector(6 downto 0); --MSB of G *ONLY USED WHEN COUT is high* 
		 oReady	  :  out      STD_LOGIC;
		 oStart		:  out      STD_LOGIC;
		 oSlv_ack1		:  out      STD_LOGIC;					
		 oSlv_ack2		:  out      STD_LOGIC;					--on sort des pins qui rapportent les ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â©tats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â©tat 
		 oMstr_ack		:  out      STD_LOGIC;
		 oStop		:  out      STD_LOGIC;
		 oRd			: out 		STD_LOGIC;
		 appsda       :  inOUT   STD_LOGIC;                    --serial data output of i2c bus
		 appscl       :  inOUT   STD_LOGIC

		 
		 --serial clock output of i2c bus 
		);
	END component;

		
		BEGIN
		
		IProjet: entity work.ProjetSim(structure)   
		 port map (
			enter=>enter,
			iclk=> iclk, 
			reset_n => reset_n,
			
			oReady=>sReady ,
			oStart=>sStart ,
			oSlv_ack1=>sSlv_ack1 ,
			oSlv_ack2=>sSlv_ack2 ,
			oMstr_ack=>sMstr_ack ,
			oStop=>sStop ,
			oRd=>sRd ,
			appsda => sda ,
			appscl => scl,
			
			HEX1=>hexones,
			HEX10=>hextenths,
			HEX100=>hexhundredths
			
		  ); 
		 
	pSDA: process
		variable N: natural := 1;
	begin 
		d <= '0';
		wait for clk_period*N;
		d <= '1';
		wait for clk_period*N;
		N := N+1;
	end process;
	
	sda<=	d when sRd='1' else
			'0' when sSlv_ack1 ='1' else
			'0' when sSlv_ack2 ='1' else
			'0' when sMstr_ack ='1' else 'Z';
			
	pCLK: process
	begin
		iclk <= '1';
		wait for clk_period/2;
		iclk <= '0';
		wait for clk_period/2;
	end process;

	pRESETn: process
	begin
		reset_n <= '1';
		wait for clk_period*5 + clk_period/3;
		reset_n <= '0';  
		wait for clk_period;
		reset_n <= '1';
		wait;
	end process;
--
	stim_proc: process
	begin
	
	enter <= "00000000";
	wait for 10 ns;
	enter <= "00000001";
	wait for 10 ns;
	enter <= "00000010";
	wait for 10 ns;
	enter <= "00000011";
	wait for 10 ns;
	enter <= "00000100";
	wait for 10 ns;
	enter <= "00000101";
	wait for 10 ns;
	enter <= "00000110";
	wait for 10 ns;
	enter <= "00000111";
	wait for 10 ns;
	enter <= "00001000";
	wait for 10 ns;
	enter <= "00001001";
	wait for 10 ns;
	enter <= "00001010";
	wait for 10 ns;
	enter <= "00010011";
	wait for 10 ns;
	enter <= "00011001";
	wait for 10 ns;
	enter <= "10110001";
	wait for 10 ns;
	enter <= "10110010";
	wait for 10 ns;
	enter <= "11111111";
	wait for 10 ns;
	end process;
	 
	
		
END beh;
