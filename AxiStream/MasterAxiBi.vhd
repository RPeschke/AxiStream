library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;



  use work.UtilityPkg.all;
  use STD.textio.all;

  use work.axiIntbi_p.all;

entity master_axi_bi is 
  port(
    clk : in sl;
    -- Outgoing response
    fromMaster : out  AxiFromMaster_axiIntBi;
    -- Incoming data
    toMaster   : in AxiToMaster_axiIntBi
  );
end master_axi_bi;

architecture rtl of master_axi_bi is 




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