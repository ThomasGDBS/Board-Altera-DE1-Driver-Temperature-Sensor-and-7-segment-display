library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Projet is
port 
	(
-- Place ports here
      iclk        : in      STD_LOGIC;                    --system clock
      reset_n     : in      STD_LOGIC;                    --active low reset
		HEX1		: out std_logic_vector(6 downto 0); --OPCODE
		HEX10		: out std_logic_vector(6 downto 0); --LSB of G
		HEX100	: out std_logic_vector(6 downto 0); --MSB of G *ONLY USED WHEN COUT is high*
		oReady	  :  out      STD_LOGIC;
		oStart		:  out      STD_LOGIC;
		oSlv_ack1		:  out      STD_LOGIC;					
		oSlv_ack2		:  out      STD_LOGIC;					--on sort des pins qui rapportent les ÃƒÆ’Ã‚Â©tats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã‚Â©tat 
		oMstr_ack		:  out      STD_LOGIC;
		oStop		:  out      STD_LOGIC;
		oRd			: out 		STD_LOGIC;
		appsda       :  inOUT   STD_LOGIC;                    --serial data output of i2c bus
		appscl       :  inOUT   STD_LOGIC
		
	);
end entity;

architecture structure of Projet is

-- Place any signals you need here
   signal ones : std_logic_vector(3 downto 0);
   signal tenths : std_logic_vector(3 downto 0);
   signal hundredths : std_logic_vector(3 downto 0);
	signal binIN: std_logic_vector(7 downto 0);   
	signal ena       :    STD_LOGIC;                    --latch in command
	signal addr      :    STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
	signal rw        :    STD_LOGIC;                    --'0' is write, '1' is read
	signal data_wr   :    STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
	signal busy      :    STD_LOGIC;                    --indicates transaction in progress
	signal data_rd   :    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
	signal ack_error :    STD_LOGIC;                    --flag if improper acknowledge from slave
	signal sReady	  :  STD_LOGIC;
	signal sStart		:  STD_LOGIC;
	signal sSlv_ack1		:  STD_LOGIC;					
	signal sSlv_ack2		:  STD_LOGIC;					--on sort des pins qui rapportent les etats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã‚Â©tat 
	signal sMstr_ack		:  STD_LOGIC;
	signal sStop		:  STD_LOGIC;
	signal sRd			: STD_LOGIC;
	signal sSda : std_logic;
	signal sScl : std_logic;
	signal hexones   : std_logic_vector(6 downto 0);
	signal hextenths  : std_logic_vector(6 downto 0);
	signal hexhundredths  : std_logic_vector(6 downto 0);

	component Path IS
	  PORT(
		 clk       :  IN      STD_LOGIC;                    --system clock
		 reset_n   :  IN      STD_LOGIC;                    --active low reset
		 ena       :  OUT      STD_LOGIC;                    --latch in command
		 addr      :  OUT      STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
		 rw        :  OUT      STD_LOGIC;                    --'0' is write, '1' is read
		 data_wr   :  OUT      STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
		 busy      :  IN     STD_LOGIC;                    --indicates transaction in progress
		 iSlv_ack1		:  IN      STD_LOGIC;					
		 iSlv_ack2		:  IN      STD_LOGIC;					--on sort des pins qui rapportent les Ã©tats dans lesquels on est pour savoir ou on est dans la machine d'Ã©tat 
		 iMstr_ack		:  IN      STD_LOGIC;
		 iStop		:  IN      STD_LOGIC;
		 iRd			: IN 		STD_LOGIC;
		 led : out std_LOGIC_VECTOR(7 DOWNTO 0)
		 );
		
		END component;

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
			 oSlv_ack2		:  out      STD_LOGIC;				--on sort des pins qui rapportent les ÃƒÆ’Ã‚Â©tats dans lesquels on est pour savoir ou on est dans la machine d'ÃƒÆ’Ã‚Â©tat 
			 oMstr_ack		:  out      STD_LOGIC;
			 oStop		:  out      STD_LOGIC;
			 oRd			: out 		STD_LOGIC;
			 sda       :  INOUT   STD_LOGIC;                    --serial data output of i2c bus
			 scl       :  INOUT   STD_LOGIC
			 );                   --serial clock output of i2c bus
	END component;


	-- convert 8 bit (nombre de 0-255) en 3 fois 4 bits (chiffre 0-9)
	component BCD
			port(
			 binIN : in  STD_LOGIC_VECTOR (7 downto 0);
			 ones : out  STD_LOGIC_VECTOR (3 downto 0);
			 tens : out  STD_LOGIC_VECTOR (3 downto 0);
			 hundreds : out  STD_LOGIC_VECTOR (3 downto 0)
			 );
	end component;

	--convert 4 bit in data to seven segment display
	component Encoder7											
			Port( 	
			 BCDin : in STD_LOGIC_VECTOR (3 downto 0);	
			 Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0)
			 );
	end component;





begin

IApp: entity work.Path(logic)  
		 port map( clk=> iclk, 
		 reset_n => reset_n, 
		 ena => ena, 
		 addr => addr , 
		 rw => rw , 
		 data_wr => data_wr , 
		 busy => busy ,
  		  iSlv_ack1=>sSlv_ack1 ,
		  iSlv_ack2=>sSlv_ack2 ,
		  iMstr_ack=>sMstr_ack ,
		  iStop=>sStop ,
		  iRd=>sRd
			);
		  
I2Cdriver : entity work.I2C(logic) --modifiÃƒÆ’Ã‚Â©
		 port map( 
			clk=> iclk, 
			reset_n => reset_n, 
			ena => ena, 
			addr => addr , 
			rw => rw , 
			data_wr => data_wr , 
			busy => busy , 
			data_rd => binIN ,
			ack_error => ack_error,
			oReady=>oReady ,
			oStart=>oStart ,
			oSlv_ack1=>sSlv_ack1 ,
			oSlv_ack2=>sSlv_ack2 ,
			oMstr_ack=>sMstr_ack ,
			oStop=>sStop ,
			oRd=>sRd ,
			sda => appsda,
			scl => appscl
			);	

IBDC: entity work.bin2bcd_8bit (Behavioral)
		 port map(
			binIN=>binIN  ,
			ones=> ones ,
			tens=> tenths ,
			hundreds=>hundredths
				 );	

HEncoder7: entity work.bcd_7segment(Behavioral)
		 port map( 	
			BCDin => hundredths ,	
			Seven_Segment => hexhundredths
			);

TEncoder7: entity work.bcd_7segment (Behavioral)
		 port map( 	
			BCDin => tenths,	
			Seven_Segment => hextenths
			);
			
OEncoder7: entity work.bcd_7segment (Behavioral)
		 port map( 	
			BCDin => ones ,	
			Seven_Segment => hexones
			);			


		
	

			
			HEX1<=hexones;
			HEX10<=hextenths;
			HEX100<=hexhundredths;	 
			oSlv_ack1<=sSlv_ack1 ; 
			oSlv_ack2<=sSlv_ack2 ;
		   oMstr_ack<=sMstr_ack ;
		   oStop<=sStop ;
		   oRd<=sRd;
		  

end structure;