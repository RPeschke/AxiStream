library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  
  use work.UtilityPkg.all;


entity hello_world is
end;

architecture rtl of hello_world is
  
  component master is 
  port(
    clk : in sl;
    -- Outgoing response
    fromMaster : out  AxiFromMaster_t;
    -- Incoming data
    toMaster   : in AxiToMaster_t
    -- This board ID
  );
end component;
component slave is port(
  clk : in sl;

  -- Outgoing response
  toMaster   : out AxiToMaster_t;
  -- Incoming data
  fromMaster : in  AxiFromMaster_t
  -- This board ID
);
end component;


  signal a : sl;
  signal fMaster : AxiFromMaster_t;
  signal tMaster : AxiToMaster_t;
  signal clk : sl;
  constant usrClk_period : time := 10 ns;
begin

  
  s : slave port map (clk => clk,toMaster => tMaster, fromMaster => fMaster);  
  m : master port map (clk => clk , fromMaster=> fMaster ,  toMaster  => tMaster);


  usrClk_process :process
  begin
    clk <= '0';
    wait for usrClk_period/2;
    clk <= '1';
    wait for usrClk_period/2;
  end process;
  
  stimulus : process
   
    
  begin

    --AxiResetChannel(fMaster,tMaster);

--    tMaster.TX_Ready <= '1';

    a <= '1';

    wait for 10 ns;
    
    a <= '0';
    wait for 10 ns;
    a <= '1';
    wait for 10 ns;  
  
    assert false
      report "Hello World"
      severity note;
    wait;
  end process stimulus;
end rtl;