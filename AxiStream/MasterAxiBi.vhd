library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;



  use work.UtilityPkg.all;
  use STD.textio.all;

  use work.axi_int_bi.all;

entity master_axi_bi is 
  port(
    clk : in sl;
    -- Outgoing response
    fromMaster : out  axi_m2s;
    -- Incoming data
    toMaster   : in axi_s2m
  );
end master_axi_bi;

architecture rtl of master_axi_bi is 




begin
  seq : process(clk) is
    variable RXTX : axi_master :=axi_master_null ;
    variable index : integer := 0;

  begin
    if (rising_edge(clk)) then
 
      report "35";
      pull_axi_master(RXTX, toMaster);
      report "37";
      if ready2Send(RXTX) then 
        sendData(RXTX, index);
        
        if sendPosition(RXTX) > 10 then 
          		sendLast(RXTX);
        end if;
      end if;

		setReady(RXTX);
      index := index+1;
      push_axi_master(RXTX, fromMaster);


    end if;
  end process seq;


end rtl;