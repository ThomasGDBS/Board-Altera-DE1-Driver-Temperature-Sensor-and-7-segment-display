
--------------------------------------------------------------------------------
--
--   FileName:         i2c_master.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 32-bit Version 11.1 Build 173 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 11/1/2012 Scott Larson
--     Initial Public Release
--   Version 2.0 06/20/2014 Scott Larson
--     Added ability to interface with different slaves in the same transaction
--     Corrected ack_error bug where ack_error went 'Z' instead of '1' on error
--     Corrected timing of when ack_error 	 clears
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY TestBench_I2C IS
END TestBench_I2C;

ARCHITECTURE Archi_I2C OF TestBench_I2C IS
	-- test 	s
		signal clk       :    STD_LOGIC :='0';
		signal reset_n   :    STD_LOGIC :='1';
		signal ena       :    STD_LOGIC;                    --latch in command
		signal addr      :    STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
		signal rw        :    STD_LOGIC;                    --'0' is write, '1' is read
		signal data_wr   :    STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
		signal busy      :    STD_LOGIC;                    --indicates transaction in progress
		signal data_rd   :    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
		signal ack_error :    STD_LOGIC;                    --flag if improper acknowledge from slave
		signal sda       :    STD_LOGIC;                    --serial data output of i2c bus
		signal scl       :    STD_LOGIC;
		signal sReady	  :  STD_LOGIC;
	   signal sStart		:  STD_LOGIC;
		signal sSlv_ack1		:  STD_LOGIC;					
		signal sSlv_ack2		:  STD_LOGIC;					--on sort des pins qui rapportent les ÃƒÆ’Ã‚Â©tats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã‚Â©tat 
		signal sMstr_ack		:  STD_LOGIC;
		signal sStop		:  STD_LOGIC;
		signal sRd			: STD_LOGIC;
  -- clock period for simulation
  constant clk_period : time := 10 ns;
	
	component I2C IS
	  GENERIC(
		 input_clk :  INTEGER := 50_000_000; --input clock speed from user logic in Hz
		 bus_clk   :  INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
	  PORT(
		 clk       :  IN      STD_LOGIC;                    --system clock
		 reset_n   :  IN      STD_LOGIC;                    --active low reset
		 ena       :  IN      STD_LOGIC;                    --latch in command
		 addr      :  IN      STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
		 rw        :  IN      STD_LOGIC;                    --'0' is write, '1' is read
		 data_wr   :  IN      STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
		 busy      :  OUT     STD_LOGIC;                    --indicates transaction in progress
		 data_rd   :  OUT     STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
		 ack_error :  BUFFER  STD_LOGIC;                    --flag if improper acknowledge from slave
		 oReady	  :  out      STD_LOGIC;
	    oStart		:  out      STD_LOGIC;
		 oSlv_ack1		:  out      STD_LOGIC;					
		 oSlv_ack2		:  out      STD_LOGIC;					--on sort des pins qui rapportent les ÃƒÆ’Ã‚Â©tats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã‚Â©tat 
		 oMstr_ack		:  out      STD_LOGIC;
		 oStop		:  out      STD_LOGIC;
		 oRd			: out 		STD_LOGIC;
		 sda       :  INOUT   STD_LOGIC;                    --serial data output of i2c bus
		 scl       :  INOUT   STD_LOGIC);                   --serial clock output of i2c bus
	END component;

BEGIN

	DUT : entity work.I2C(logic) --modifiÃƒÆ’Ã‚Â©
		 port map( clk=> clk, reset_n => reset_n, ena => ena, addr => addr , rw => rw , data_wr => data_wr , busy => busy , data_rd => data_rd ,ack_error => ack_error,
		  oReady=>sReady ,
		  oStart=>sStart ,
		  oSlv_ack1=>sSlv_ack1 ,
		  oSlv_ack2=>sSlv_ack2 ,
		  oMstr_ack=>sMstr_ack ,
		  oStop=>sStop ,
		  oRd=>sRd ,
		  sda => sda ,scl => scl);	
		 
	pCLK: process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	
	-- reset_n generation process (no sensitivity list - then use WAIT)
	pRESETn: process
	begin
		reset_n <= '1';
		wait for clk_period*5 + clk_period/3;
		reset_n <= '0';
		wait for clk_period;
		reset_n <= '1';
		wait;
	end process;
		

	pENA : process
	begin
		ena<='1';
		addr <="0111110"; --dev
		rw <='0';
		data_wr <="10000001"; --reg
		wait until busy='1';
		ena<='1';
		addr <="0111110"; --reg
		rw <='0';
		data_wr <="10000001"; --vav
		wait until busy='1';
		wait until busy='0';
		ena<='1';
		addr <="0111110"; --dev
		rw <='1';
		data_wr <="10000001"; --reg
		wait until busy='1';
		wait until busy='0';

	end process;
	
	
	
	
END Archi_I2C;