library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  use work.AxiMonoStream.all;
  use work.UtilityPkg.all;
  

entity tb_streamTest is
end;

architecture rtl of tb_streamTest is
component csv_write_file is
  generic (
    FileName : string := "read_file_ex.txt";
    NUM_COL : integer := 3;
    HeaderLines :string := "x y z"

  );
  port(
    clk : in sl;

    Rows : in t_integer_array(NUM_COL downto 0) := (others => 0)
    
  ); 
  end component;
  component csv_read_file is
    generic (
      FileName : string := "read_file_ex.txt";
      NUM_COL : integer := 3;
      HeaderLines :integer :=1

    );
    port(
      clk : in sl;

      Rows : out t_integer_array(NUM_COL downto 0) := (others => 0);
      Index : out integer := 0
    ); 
  end component;
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
signal data_stream : t_integer_array(3 downto 0);
constant usrClk_period : time := 10 ns;
begin


  s : slave port map (clk => clk,toMaster => tMaster, fromMaster => fMaster);  
  m : Master_textio generic map (FileName => "read_file_ex.txt") port map (clk => clk , fromMaster=> fMaster ,  toMaster  => tMaster);
  csv : csv_read_file generic map (FileName => "test2.txt", NUM_COL => 3) port map(clk => clk, Rows => data_stream);
  csv_out :csv_write_file generic map (FileName => "test3.txt") port map(clk => clk, Rows => data_stream);

  usrClk_process :process
  begin
    clk <= '0';
    wait for usrClk_period/2;
    clk <= '1';
    wait for usrClk_period/2;
  end process;


end rtl;