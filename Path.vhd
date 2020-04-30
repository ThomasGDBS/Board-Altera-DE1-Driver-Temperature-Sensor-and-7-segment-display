
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
--     Corrected timing of when ack_error signal clears
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY Path IS
  PORT(
    clk       :  IN      STD_LOGIC;                    --system clock
    reset_n   :  IN      STD_LOGIC;                    --active low reset
    ena       :  OUT      STD_LOGIC;                    --latch in command
    addr      :  OUT      STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        :  OUT      STD_LOGIC;                    --'0' is write, '1' is read
    data_wr  :  OUT      STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      :  IN     STD_LOGIC;                    --indicates transaction in progress
    iSlv_ack1		:  IN      STD_LOGIC;					
    iSlv_ack2		:  IN      STD_LOGIC;					--on sort des pins qui rPathortent les états dans lesquels on est pour savoir ou on est dans la machine d'état 
    iMstr_ack		:  IN      STD_LOGIC;
    iStop		:  IN      STD_LOGIC;
	 iRd			: IN 		STD_LOGIC;
	 led : out std_LOGIC_VECTOR(7 DOWNTO 0);
	 sState : out std_logic);
END Path;

ARCHITECTURE logic OF Path IS
	TYPE machine IS(etat1, etat2,etat2bis,etat3, etat4, etat5, etat6, etat7, etat8);
  SIGNAL  state     :  machine;
  
BEGIN
	sState<='1' when state=etat7 else '0';
	led <= (others => '0');
	
  PROCESS(clk, reset_n,state)
  BEGIN
    IF(reset_n = '0') THEN
			ena<='0';
			state<=etat1;
    ELSIF(clk'EVENT AND clk = '1') THEN
      CASE state IS
         WHEN etat1 =>
				addr<="1001000"; 					--
				rw<='0';
				data_wr<="00000001";	
				ena<='1';
				IF(iSlv_ack2='1')
				THEN state<=etat2;
				END IF;
			WHEN etat2 =>
					data_wr<="00100000";
				IF(iSlv_ack2='0')
				THEN 
					state<=etat2bis;
				END IF;
			WHEN etat2bis =>
				IF(iSlv_ack2='1')
				THEN state<=etat3;
				END IF;
			WHEN etat3 =>
				ena<='0';
				IF(busy='0')
				THEN state<=etat4;
				END IF;
			WHEN etat4 =>
				data_wr<="00000000";
				rw<='0';
				ena<='1';
				IF(iSlv_ack2='1')
				THEN state<=etat5;
				END IF;
			WHEN etat5 =>
				rw<='1';
				ena<='1';
				IF(iMstr_ack='1')
				THEN state<=etat6;
				END IF;
			WHEN etat6 =>
				IF(iRd='1')
				THEN state<=etat7;
				END IF;
			WHEN etat7 =>
				ena<='0';
				IF(iMstr_ack='1')
				THEN state<=etat8;
				END IF;
			WHEN etat8 =>
				IF(iStop='1')
				THEN state<=etat1;
				END IF;
			WHEN OTHERS =>
				ena<='0';
				state<=etat1;
      END CASE;    
    END IF;

       
  END PROCESS;  

END logic;