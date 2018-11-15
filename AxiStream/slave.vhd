library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  use work.AxiMonoStream.all;
  use work.UtilityPkg.all;

  use std.textio.all;
entity slave is 
  port   (
    clk : in sl;

    -- Outgoing response
    toMaster   : out AxiMonoToMaster_t;
    -- Incoming data
    fromMaster : in  AxiMonoFromMaster_t
    -- This board ID
  );
end slave;

architecture rtl of slave is 
  --constant C_FILE_NAME_RD :string  := "./ReadIntFromFileIn.dat";
  constant C_FILE_NAME_WR :string  := "./ReadIntFromFileOut.dat";
  constant endSim : integer := 100;
  type INTEGER_FILE is file of integer;
  file fptrrd             :INTEGER_FILE;
  file fptrwr             :INTEGER_FILE;
  file fptr: text;
begin

  seq : process(clk) is
    variable RXTX : AxiMonoSendReceiveSlave;
    variable state : integer := 0;
    variable data: data_t;
    variable counter : integer := 0 ;
    variable statwr : FILE_OPEN_STATUS;
    variable counter_full: integer := 0;
    variable file_line     :line;
  begin


    if (rising_edge(clk)) then
      if counter_full = 0 then 
        file_open(statwr, fptr, C_FILE_NAME_WR, write_mode);
      end  if;

      counter_full := counter_full +1;

      counter := counter +1;
      AxiMonoSlavePullData(RXTX, fromMaster);
      data := rxGetData(RXTX);
      if  counter > 3 then 
        rxSetDataReady(RXTX);
        if counter >4 then 
          counter :=0;
        end if;
      end if;
      if counter_full < endSim and rxIsValidAndReady(RXTX) then 
        --		      hwrite(file_line, data, left, 5);
        write(file_line, data, right, 2);
        --				write(file_line, data, left, 5);
        writeline(fptr, file_line);
      end  if;
      if counter_full = endSim then
        file_close(fptr);
      end if;

      report "slave " &  integer'image(counter) & "  "  & integer'image(data);
      AxiSlavePushData(RXTX, toMaster);

    end if;
  end process seq;


end rtl;