library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;

  use work.AxiMonoStream.all;

  use work.UtilityPkg.all;
  use STD.textio.all;
  use work.text_IO_CSV.all;


entity csv_read_file is
  generic (
    FileName : string := "read_file_ex.txt";
    NUM_COL : integer := 3;
    HeaderLines :integer :=1;
    Delay : time := 2 ns 
  );
  port(
    clk : in sl;

    Rows : out t_integer_array(NUM_COL downto 0) := (others => 0);
    Index : out integer := 0
  ); 
end csv_read_file;

architecture Behavioral of csv_read_file is

begin
  seq : process(clk) is
    file input_buf : text;  -- text is keyword

    variable csv : csv_file;

  begin
    if rising_edge(clk) then 
    
      
      if not csv_isOpen(csv) then
        csv_openFile(csv,input_buf, FileName, HeaderLines, NUM_COL);
      end if;

      if not endfile(input_buf) then 
        csv_readLine(csv,input_buf);
      else 
        csv_close(csv,input_buf);
      end if;

      for i in 0 to NUM_COL loop
        Rows(i) <= csv_get(csv, i) after Delay ;
      end loop;
      Index <= csv_getIndex(csv) after Delay ;
    end if;
  end process seq;
end Behavioral;


