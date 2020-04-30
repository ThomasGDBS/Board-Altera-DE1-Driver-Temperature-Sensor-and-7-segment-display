LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY bin2bcd_8bit_test_file IS
END bin2bcd_8bit_test_file;

 
ARCHITECTURE behavior OF bin2bcd_8bit_test_file IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT bin2bcd_8bit
    PORT(
         binIN : IN  std_logic_vector(7 downto 0);
         ones : OUT  std_logic_vector(3 downto 0);
         tens : OUT  std_logic_vector(3 downto 0);
         hundreds : OUT  std_logic_vector(3 downto 0)
	 
        );
    END COMPONENT;
    
  -- WARNING: Please, notice that there is no need for a clock signal in the testbench, since the design is strictly
  --    combinational (or concurrent, in contrast to the C implementation which is sequential).
  -- This clock is here just for simulation; you can omit all clock references and process, and use "wait for ... ns"
  --    statements instead.

   --Inputs
   signal binIN : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';  -- can be omitted

 	--Outputs
   signal ones : std_logic_vector(3 downto 0);
   signal tenths : std_logic_vector(3 downto 0);
   signal hundredths : std_logic_vector(3 downto 0);
   

   -- Clock period definitions
   constant clk_period : time := 1 ns;  -- can be omitted

   -- Miscellaneous
   signal full_number : std_logic_vector(11 downto 0);
	
	
	
	
	

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: bin2bcd_8bit PORT MAP (
          binIN => binIN,
          ones => ones,
          tens => tenths,
          hundreds => hundredths
	  
        );

   -- Clock process definitions  -- the whole process can be omitted
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Combine signals for full number
   full_number <= hundredths & tenths & ones;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		-- should return 4095
		binIN <= X"FF";
		wait for clk_period*10;  assert full_number = x"255" severity error;  -- use "wait for ... ns;"

		-- should return 0
		binIN <= X"00";
		wait for clk_period*10;  assert full_number = x"000" severity error;

		-- should return 2748
		binIN <= X"B2";
		wait for clk_period*10;  assert full_number = x"178" severity error;
		
		
      wait;
   end process;

END;