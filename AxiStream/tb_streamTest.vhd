library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  use work.AxiMonoStream.all;
  use work.UtilityPkg.all;
  use work.axi_int_bi.all;

entity tb_streamTest is
end;

architecture rtl of tb_streamTest is


  

signal fMaster : AxiMonoFromMaster_t := c_AxiMonoFromMaster_t;
signal tMaster : AxiMonoToMaster_t := c_AxiMonoToMaster_t;
signal clk : sl;
signal data_stream : t_integer_array(3 downto 0);
signal fromMaster : axi_m2s := axi_m2s_null;
signal toMaster   :  axi_s2m := axi_s2m_null;
constant usrClk_period : time := 10 ns;
begin


  s : entity  work.slave port map (clk => clk,toMaster => tMaster, fromMaster => fMaster);  
  m :entity  work.Master_textio generic map (FileName => "read_file_ex.txt") port map (clk => clk , fromMaster=> fMaster ,  toMaster  => tMaster);
  csv :entity  work.csv_read_file generic map (FileName => "../example_in1.csv", NUM_COL => 3) port map(clk => clk, Rows => data_stream);
  csv_out : entity  work.csv_write_file generic map (FileName => "test3.txt",HeaderLines=> "x1; x2; x3; x3") port map(clk => clk, Rows => data_stream);
  mBi : entity work.master_axi_bi port map(clk => clk, fromMaster => fromMaster, toMaster=>toMaster);
  sBI : entity work.slave_AxiBi port map(clk =>clk , toMaster => toMaster , fromMaster => fromMaster);
  
  usrClk_process :process
  begin
    clk <= '0';
    wait for usrClk_period/2;
    clk <= '1';
    wait for usrClk_period/2;
  end process;


end rtl;