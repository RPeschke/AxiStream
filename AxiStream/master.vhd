library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;

  use work.AxiMonoStream.all;

  use work.UtilityPkg.all;
  use STD.textio.all;

entity master is 
  port(

    clk : in sl;

    -- Outgoing response
    fromMaster : out  AxiMonoFromMaster_t;
    -- Incoming data
    toMaster   : in AxiMonoToMaster_t
    -- This board ID
  );
end master;

architecture rtl of master is 

  constant WORD_HEADER_C  : data_t := 0;  
  constant WORD_COMMAND_C : data_t := 1;
  constant WORD_PING_C    : data_t := 2;
  constant WORD_READ_C    : data_t := 3;
  constant WORD_WRITE_C   : data_t := 4;
  constant WORD_ACK_C     : data_t := 5;
  constant WORD_ERR_C     : data_t := 6;

begin
  seq : process(clk) is
    variable RXTX : AxiMonoSendReceiveMaster ;
    variable state : integer := 0;

  begin
    if (rising_edge(clk)) then
      state := state +1;
      if state < 2 then 
        RXTX.tx.pos := 0;
		  --RXTX.tx.ready :='0';
      end if;
      AxiMonoMasterPullData(RXTX, toMaster);

		--RXTX.tx.ready :=toMaster.tx_ready;
      report integer'image(txGetPosition(RXTX));
		if txIsDataReady(RXTX) then 
      txPushData(RXTX, 1);
      txPushData(RXTX, 2);
      txPushData(RXTX, 3);          
      txPushData(RXTX, 4);      
      txPushData(RXTX, 5);      		
      txPushData(RXTX, 6);      
      txPushLast(RXTX);
		end if;


      AxiMasterPushData(RXTX, fromMaster);
		
      --writeline (output, RXTX.tx.data.data);
      --writeline (output, string'("ASDAD"));
      report "jgjh";
    end if;
  end process seq;


end rtl;