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
    variable index : integer := 0;

  begin
    if (rising_edge(clk)) then
 
      report "35";
      AxiPullDataMaster(RXTX, toMaster);
      report "37";
      if not txIsValid(RXTX) then 
        txSetData(RXTX, index);
        
        if txGetPos(RXTX) > 10 then 
          txSetLast(RXTX);
        end if;
      end if;

      rxSetReady(RXTX);
      index := index+1;
      AxiPushDataMaster(RXTX, fromMaster);


    end if;
  end process seq;


end rtl;