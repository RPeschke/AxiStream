library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all;

package AxiBiStream is



  type AxiStream is record
    data  : AxiData;
    Ready : AxiDataReady_t;
    lastReady : AxiDataReady_t;
    pos   :  size_t ;
    call_pos :  size_t;
  end record AxiStream;

  type AxiSendRecieve is record
    rx : AxiStream;
    tx : AxiStream;
  end record AxiSendRecieve;

  type AxiToMaster_t is record
    RX_data  : AxiData;
    TX_Ready : AxiDataReady_t;
  end record AxiToMaster_t;

  type AxiFromMaster_t is record
    TX_data  : AxiData;
    RX_Ready : AxiDataReady_t;
  end record AxiFromMaster_t;

  type AxiBiDirectional is record
    from_master : AxiFromMaster_t;
    to_master   : AxiToMaster_t;
  end record AxiBiDirectional;





  --Master Interface 
  procedure AxiMasterPullData(RXTX : inout AxiSendRecieve; toMaster : in AxiToMaster_t);
  procedure AxiMasterPushData(RXTX : in AxiSendRecieve; signal fromMaster : out AxiFromMaster_t);
  -- end Master Interface  

  -- Slave interface
  procedure AxiSlavePullData(RXTX : inout AxiSendRecieve; fromMaster : in AxiFromMaster_t) ;
  procedure AxiSlavePushData(RXTX : in AxiSendRecieve; signal toMaster : out AxiToMaster_t) ;
  -- end Slave interface 


  -- TX interface  
  procedure setTXData(RXTX : out AxiSendRecieve; data : in data_t; valid : in sl := '1' );
  procedure setTXLast(RXTX : out AxiSendRecieve; last : in sl := '1');

  procedure AxiPushData(RXTX : inout AxiSendRecieve;   data : in data_t);
  procedure AxiPushData(RXTX : inout AxiSendRecieve;   data : in data_t; position : in size_t);
  procedure AxiPushLast(RXTX : inout AxiSendRecieve);

  procedure setTXValid(RXTX : out AxiSendRecieve; valid : in sl);


  function isTXLast(RXTX : in AxiSendRecieve) return boolean;
  function isTXValid(RXTX: in AxiSendRecieve) return boolean;
  function getTXData(RXTX : in AxiSendRecieve) return data_t;
  function TxDataReady(RXTX : AxiSendRecieve) return boolean;   
  -- TX interface end  


  -- RX interface 
  function rxData(RXTX : AxiSendRecieve) return data_t ;
  function tx_currentElement(RXTX : in AxiSendRecieve) return size_t;
  procedure rxDataReady(RXTX : out AxiSendRecieve);
  function isRxDataReady(RXTX : in AxiSendRecieve) return boolean;

  --procedure AxiPullData(RXTX: inout AxiSendRecieve; data :out data_t);
  --procedure AxiPullData(RXTX: inout AxiSendRecieve; data :out data_t; position :in size_t);

  function rxLast(RXTX : AxiSendRecieve) return boolean; 
  function rxValid(RXTX : AxiSendRecieve) return boolean; 

  -- RX interface end


  procedure AxiReset(variable AxitRXTX : out AxiSendRecieve);


  procedure AxiResetChannel(signal fMaster : out AxiFromMaster_t ;signal  tmaster : out AxiToMaster_t);



end AxiBiStream;

package body AxiBiStream is



  function isRxDataReady(RXTX : in AxiSendRecieve) return boolean is begin
    return RXTX.rx.lastReady = '1';

  end isRxDataReady;

  function isTXValid(RXTX: in AxiSendRecieve) return boolean is begin

    return RXTX.tx.data.DataValid = '1';
  end isTXValid;

  procedure AxiTxIncrementPos(RXTX: inout AxiSendRecieve) is begin

    if isTXValid(RXTX) and TxDataReady(RXTX) then 

      if isTXLast(RXTX) then
        RXTX.tx.pos := 0;
      else 
        RXTX.tx.pos := RXTX.tx.pos + 1;
      end if;


    end if;

  end procedure AxiTxIncrementPos;


  procedure AxiMasterPullData(RXTX : inout AxiSendRecieve; toMaster : in AxiToMaster_t) is begin
    RXTX.tx.lastReady := RXTX.tx.Ready;
    RXTX.rx.lastReady := RXTX.rx.Ready;
    RXTX.rx.data  := toMaster.RX_data;
    RXTX.tx.Ready := toMaster.TX_Ready;

    AxiTxIncrementPos(RXTX);
    AxiReset(RXTX);
  end procedure AxiMasterPullData;

  procedure AxiSlavePullData(RXTX : inout AxiSendRecieve; fromMaster : in AxiFromMaster_t) is  begin
    RXTX.tx.lastReady := RXTX.tx.Ready;
    RXTX.rx.lastReady := RXTX.rx.Ready;
    RXTX.rx.data  := fromMaster.TX_data;
    RXTX.tx.Ready := fromMaster.RX_Ready;


    AxiTxIncrementPos(RXTX);
    AxiReset(RXTX);
  end procedure AxiSlavePullData;

  procedure  AxiMasterPushData(RXTX : in AxiSendRecieve; signal fromMaster : out AxiFromMaster_t) is
  begin
    fromMaster.TX_data.Data  <= RXTX.tx.data.Data after 10 ns;
    fromMaster.TX_data.DataLast <= RXTX.tx.data.DataLast after 10 ns;;
    fromMaster.TX_data.DataValid <= RXTX.tx.data.DataValid after 10 ns;;
    fromMaster.RX_Ready <= RXTX.rx.Ready after 10 ns;
  end procedure AxiMasterPushData;

  procedure AxiSlavePushData(RXTX : in AxiSendRecieve ; signal toMaster : out AxiToMaster_t) is
  begin
    toMaster.RX_data.Data  <= RXTX.tx.data.Data after 10 ns;
    toMaster.RX_data.DataLast <= RXTX.tx.data.DataLast after 10 ns;
    toMaster.RX_data.DataValid <= RXTX.tx.data.DataValid after 10 ns;
    toMaster.TX_Ready <= RXTX.rx.Ready after 10 ns;
  end procedure AxiSlavePushData;

  procedure AxiFromMaster2TX(
    signal AxiIn      : in AxiFromMaster_t;
    variable AxitRXTX : out AxiSendRecieve
  ) is
  begin
    AxitRXTX.tx.data  := AxiIn.TX_data;
    AxitRXTX.rx.Ready := AxiIn.RX_Ready;

  end AxiFromMaster2TX;

  procedure AxiFromMaster2RX(
    signal AxiIn      : in AxiFromMaster_t;
    variable AxitRXTX : out AxiSendRecieve
  ) is
  begin
    AxitRXTX.rx.data  := AxiIn.TX_data;
    AxitRXTX.tx.Ready := AxiIn.RX_Ready;

  end AxiFromMaster2RX;

  procedure AxiReset(
    variable AxitRXTX : out AxiSendRecieve
  ) is
  begin
    AxitRXTX.rx.Ready          := '0';
    AxitRXTX.tx.Data.DataValid := '0';
    AxitRXTX.tx.Data.DataLast  := '0';
    AxitRXTX.tx.call_pos := 0;
    AxitRXTX.rx.call_pos := 0;
  end AxiReset;

  procedure rxDataReady(RXTX : out AxiSendRecieve) is
  begin
    RXTX.rx.Ready := '1';
  end rxDataReady;

  procedure setTXData(RXTX : out AxiSendRecieve; data : in data_t; valid :in sl := '1') is
  begin
    RXTX.tx.Data.Data := data;
    RXTX.tx.data.DataValid := valid;
  end setTXData;



  procedure setTXValid(RXTX : out AxiSendRecieve; valid : in sl) is
  begin
    RXTX.tx.Data.DataValid := valid;
  end setTXValid;

  procedure setTXLast(RXTX : out AxiSendRecieve; last : in sl := '1') is
  begin
    RXTX.tx.Data.DataLast := last;
  end setTXLast;

  function getTXData(RXTX : in AxiSendRecieve) return data_t is
  begin
    return RXTX.tx.data.Data;
  end getTXData;

  function isTXLast(RXTX : in AxiSendRecieve) return boolean is
  begin
    return RXTX.tx.data.DataLast = '1';
  end isTXLast;
  function rxLast(RXTX : AxiSendRecieve) return boolean is
  begin
    return RXTX.rx.Data.DataLast = '1';

  end rxLast;

  function rxValid(RXTX : AxiSendRecieve) return boolean is
  begin
    return RXTX.rx.Data.DataValid = '1';

  end rxValid;

  function rxData(RXTX : AxiSendRecieve) return data_t is
  begin
    return RXTX.rx.Data.Data;

  end rxData;

  function TxDataReady(RXTX : AxiSendRecieve) return boolean is
  begin
    return RXTX.tx.Ready = '1';

  end TxDataReady;

  procedure AxiPushData( RXTX : inout AxiSendRecieve; data : in data_t) is begin
    AxiPushData(RXTX, data,RXTX.tx.call_pos);
  end AxiPushData;

  procedure AxiPushData(RXTX : inout AxiSendRecieve;   data : in data_t; position : in size_t) is begin
    if position = RXTX.tx.pos then  

      setTXData(RXTX, data);


    end if;
    RXTX.tx.call_pos := position +1;

  end AxiPushData;

  procedure AxiPushLast(RXTX : inout AxiSendRecieve) is begin
    if RXTX.tx.call_pos = RXTX.tx.pos+1 then  

      setTXLast(RXTX);


    end if;
    RXTX.tx.call_pos := RXTX.tx.call_pos +1;

  end AxiPushLast;

  function tx_currentElement(RXTX : in AxiSendRecieve) return size_t is begin 

    return RXTX.tx.pos;
  end tx_currentElement;


  procedure AxiResetChannel(signal fMaster : out AxiFromMaster_t ;signal  tmaster : out AxiToMaster_t) is begin

    fMaster.RX_Ready <= '0';
    fMaster.TX_data.Data <= 0; 
    fMaster.TX_data.DataLast <='0';
    fMaster.TX_data.DataValid <= '0';

    tmaster.RX_data.Data <= 0;
    tmaster.RX_data.DataLast <= '0';
    tmaster.RX_data.DataValid <= '0';
    tmaster.TX_Ready <= '0';
  end AxiResetChannel;
  type AxiSendRecieveVector is array (natural range <>) of AxiSendRecieve;

end package body AxiBiStream;