library ieee;
  use ieee.std_logic_1164.all;
  use work.axiStreamHelper.all;



  use work.UtilityPkg.all;
  use STD.textio.all;

  use work.axiIntbi_p.all;

entity slave_AxiBi is 
  port(
    clk : in sl;
    -- Outgoing response
    toMaster   : out AxiToMaster_axiIntBi;
    -- Incoming data
    fromMaster : in  AxiFromMaster_axiIntBi
  );
end slave_AxiBi;

architecture rtl of slave_AxiBi is 
  type StateType     is (IDLE_S,RECEIVING,SENDING);



begin
  seq : process(clk) is
    variable RXTX : AxiRXTXSlave_axiIntBi := AxiRXTXSlave_axiIntBi_null;
    variable Buffer1 : t_integer_array(20 downto 0);
    variable Index : integer := 0;
    variable Index1 : integer := 0;
    variable max_Index : integer := 0;
    variable state :StateType :=IDLE_S;
  begin
    if (rising_edge(clk)) then
      AxiPullDataSlave(RXTX, fromMaster);

      if rxIsValidAndReady(RXTX) and state /= SENDING  then 
        Buffer1(Index) :=  rxGetData(RXTX);
        Index := Index + 1;
        if rxIsLast(RXTX) then 
          max_Index := Index;
          Index := 0;
          state := SENDING;
        end if;
      end if;

      if state = SENDING and txIsReady(RXTX)  then 
        txSetData(RXTX, Buffer1(Index));

        Index := Index + 1;
        if Index  = max_Index then 
          txSetLast(RXTX);

          state := IDLE_S;
          Index := 0;
        end if;
      end if;
      
      if state /= SENDING then
        if Index1 mod 5 = 0 then
          rxSetReady(RXTX);
        end if;
        
      end if;
      Index1 := Index1 +1;
      AxiPushDataSlave(RXTX, toMaster);

    end if;
  end process seq;


end rtl;