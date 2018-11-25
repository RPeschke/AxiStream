library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;

  use work.AxiMonoStream.all;

  use work.UtilityPkg.all;
  use STD.textio.all;
	use work.text_IO_CSV.all;


entity Master_textio is
  generic (FileName : string := "read_file_ex.txt");
  port(

    clk : in sl;

    -- Outgoing response
    fromMaster : out  AxiMonoFromMaster_t;
    -- Incoming data
    toMaster   : in AxiMonoToMaster_t

  ); 
end Master_textio;


architecture Behavioral of Master_textio is
  type t_integer_array       is array(integer range <> )  of integer;
	constant NUM_COL : integer := 3;
begin
  seq : process(clk) is
    file input_buf : text;  -- text is keyword
    variable RXTX : AxiMonoSendReceiveMaster ;
    variable csv : csv_file;
    variable state : integer := 0;
  begin
    if (rising_edge(clk)) then
      state := state +1;
      if state < 2 then 
        file_open(input_buf, FileName,  read_mode); 
        RXTX.tx.position := 0;
      end if;

      AxiPullData(RXTX, toMaster);
      if txIsDataReady(RXTX) and  not endfile(input_buf)  then 
        csv_readLine(csv,input_buf);
        txSetData(RXTX, csv_get(csv, 1));
      end if;
      if endfile(input_buf) then 
        txSetLast(RXTX);
        file_close(input_buf);
        file_open(input_buf, FileName,  read_mode); 
      end if;

      AxiPushData(RXTX, fromMaster);


    end if;
  end process seq;

end Behavioral;

