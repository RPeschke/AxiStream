library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;



  use work.UtilityPkg.all;
  use STD.textio.all;

  use work.axiIntbi_p.all;

entity e_slaveAxiBiStream is 
  port(
    clk : in sl;
    -- Outgoing response
    toMaster   : out AxiToMaster_axiIntBi;
    -- Incoming data
    fromMaster : in  AxiFromMaster_axiIntBi
  );
end e_slaveAxiBiStream;

architecture rtl of e_slaveAxiBiStream is 




begin
  seq : process(clk) is
    variable RXTX : AxiRXTXMaster_axiIntBi :=AxiRXTXMaster_axiIntBi_null ;


  begin
    if (rising_edge(clk)) then
      AxiPullData(RXTX, toMaster);

      if txIsReady(RXTX) then 
        txSetData(RXTX, txGetPos(RXTX));

        if txGetPos(RXTX) > 10 then 
          txSetLast(RXTX);
        end if;
      end if;


      AxiPushData(RXTX, fromMaster);


    end if;
  end process seq;


end rtl;