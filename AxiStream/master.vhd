library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;
  use work.UtilityPkg.all;
  use STD.textio.all;
entity master is 
  port(

    clk : in sl;

    -- Outgoing response
    fromMaster : out  AxiFromMaster_t;
    -- Incoming data
    toMaster   : in AxiToMaster_t
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
    variable RXTX : AxiSendRecieve;
    variable state : integer := 0;

  begin
    if (axiMasterCLK(clk)) then
      state := state +1;
      if state < 2 then 
        RXTX.tx.pos := 0;
      end if;
      AxiMasterPullData(RXTX, toMaster);

      report integer'image(tx_currentElement(RXTX));
      AxiPushData(RXTX, 1);
      AxiPushData(RXTX, 2);
      AxiPushData(RXTX, 3);          
      AxiPushData(RXTX, 4);      
      AxiPushData(RXTX, 5);      		
      AxiPushData(RXTX, 6);      
      AxiPushLast(RXTX);


      AxiMasterPushData(RXTX, fromMaster);
      --writeline (output, RXTX.tx.data.data);
      --writeline (output, string'("ASDAD"));
      report "jgjh";
    end if;
  end process seq;


end rtl;