library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  use work.AxiMonoStream.all;
  use work.UtilityPkg.all;


entity tb_streamTest is
end;

architecture rtl of tb_streamTest is

  component master is 
    port(
      clk : in sl;
      -- Outgoing response
      fromMaster : out  AxiMonoFromMaster_t;
      -- Incoming data
      toMaster   : in AxiMonoToMaster_t
      -- This board ID
    );
  end component;
  component Master_textio is 
  generic (FileName : string := "read_file_ex.txt");
    port(
      clk : in sl;
      -- Outgoing response
      fromMaster : out  AxiMonoFromMaster_t;
      -- Incoming data
      toMaster   : in AxiMonoToMaster_t
      -- This board ID
    );
  end component;
  component slave is port(
    clk : in sl;

    -- Outgoing response
    toMaster   : out AxiMonoToMaster_t;
    -- Incoming data
    fromMaster : in  AxiMonoFromMaster_t
    -- This board ID
  );
end component;


signal a : sl;
signal fMaster : AxiMonoFromMaster_t;
signal tMaster : AxiMonoToMaster_t;
signal clk : sl;
constant usrClk_period : time := 10 ns;
begin


  s : slave port map (clk => clk,toMaster => tMaster, fromMaster => fMaster);  
  m : Master_textio generic map (FileName => "read_file_ex.txt") port map (clk => clk , fromMaster=> fMaster ,  toMaster  => tMaster);


  usrClk_process :process
  begin
    clk <= '0';
    wait for usrClk_period/2;
    clk <= '1';
    wait for usrClk_period/2;
  end process;


end rtl;