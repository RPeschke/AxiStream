library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;

  use work.AxiMonoStream.all;

  use work.UtilityPkg.all;
  use STD.textio.all;
  use work.text_io_export_csv.all;



entity csv_write_file is
  generic (
    FileName : string := "read_file_ex.txt";
    NUM_COL : integer := 3;
    HeaderLines :string := "x y z"

  );
  port(
    clk : in sl;

    Rows : in t_integer_array(NUM_COL downto 0) := (others => 0)

  ); 
end csv_write_file;

architecture Behavioral of csv_write_file is
begin

  seq : process(clk) is
    file outBuffer : text;  
    variable csv : csv_exp_file;


  begin
    if rising_edge(clk) then 

      if not csv_isOpen(csv) then
        csv_openFile(csv,outBuffer, FileName, HeaderLines, NUM_COL);
      end if;

      for i in 0 to NUM_COL loop 
        csv_set(csv,i,Rows(i));
      end loop;
      
      
      csv_write(csv,outBuffer);
    end if;
  end process seq;

end Behavioral;
