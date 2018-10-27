library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all;

package AxiMonoStream is





  type AxiMonoSendReceiveMaster is record
    tx : AxiStream;
  end record AxiMonoSendReceiveMaster;

  type AxiMonoSendReceiveSlave is record
    rx : AxiStream;
  end record AxiMonoSendReceiveSlave;

  type AxiMonoToMaster_t is record
    TX_Ready : AxiDataReady_t;
  end record AxiMonoToMaster_t;

  type AxiMonoFromMaster_t is record
    TX_data  : AxiData;
  end record AxiMonoFromMaster_t;

  type AxiBiDirectional is record
    from_master : AxiMonoFromMaster_t;
    to_master   : AxiMonoToMaster_t;
  end record AxiBiDirectional;





  --Master Interface 
  procedure AxiMonoMasterPullData(rxtx : inout AxiMonoSendReceiveMaster; signal tMaster : in AxiMonoToMaster_t);
  procedure AxiMasterPushData(RXTX : inout AxiMonoSendReceiveMaster; signal fromMaster : out AxiMonoFromMaster_t);
  -- end Master Interface  

  -- Slave interface
  procedure AxiMonoSlavePullData(RXTX : inout AxiMonoSendReceiveSlave;signal fromMaster : in AxiMonoFromMaster_t) ;
  procedure AxiSlavePushData(RXTX : inout AxiMonoSendReceiveSlave; signal toMaster : out AxiMonoToMaster_t) ;
  -- end Slave interface 


  -- TX interface  
  procedure txSetData(RXTX : out AxiMonoSendReceiveMaster; data : in data_t; valid : in sl := '1' );
  procedure txSetLast(RXTX : out AxiMonoSendReceiveMaster; last : in sl := '1');

  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t);
  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t; position : in size_t);
  procedure txPushLast(RXTX : inout AxiMonoSendReceiveMaster);

  procedure txSetValid(RXTX : out AxiMonoSendReceiveMaster; valid : in sl := '1');


  function txIsLast(RXTX : in AxiMonoSendReceiveMaster) return boolean;
  function txIsValid(RXTX: in AxiMonoSendReceiveMaster) return boolean;
  function txGetData(RXTX : in AxiMonoSendReceiveMaster) return data_t;
  function txIsDataReady(RXTX : AxiMonoSendReceiveMaster) return boolean;   
  function txGetPosition(RXTX : in AxiMonoSendReceiveMaster) return size_t;
  -- TX interface end  


  -- RX interface 
  procedure rxSetDataReady(RXTX : out AxiMonoSendReceiveSlave);
  function rxGetData(RXTX : AxiMonoSendReceiveSlave) return data_t ;
  function rxIsDataReady(RXTX : in AxiMonoSendReceiveSlave) return boolean;
  function rxGetPosition(RXTX: in AxiMonoSendReceiveSlave) return size_t;



  function rxIsLast(RXTX : AxiMonoSendReceiveSlave) return boolean; 
  function rxIsValid(RXTX : AxiMonoSendReceiveSlave) return boolean; 
  function rxIsValidAndReady(RXTX : AxiMonoSendReceiveSlave) return boolean; 
  function rxIsPosition(RXTX : AxiMonoSendReceiveSlave; position :size_t ) return boolean; 

  procedure rxPullData(RXTX: inout AxiMonoSendReceiveSlave; data :out data_t; position :in size_t);
  procedure rxPullData(RXTX: inout AxiMonoSendReceiveSlave; data :out data_t);
  -- RX interface end


  procedure AxiReset(variable RXTX : out AxiMonoSendReceiveSlave);
  procedure AxiReset(variable RXTX : out AxiMonoSendReceiveMaster);


  procedure AxiResetChannel(signal fMaster : out AxiMonoFromMaster_t ;signal  tmaster : out AxiMonoToMaster_t);



end AxiMonoStream;

package body AxiMonoStream is


  procedure AxiMonoMasterPullData(rxtx : inout AxiMonoSendReceiveMaster; signal tMaster : in AxiMonoToMaster_t) is begin
	rxtx.tx.Ready1 := rxtx.tx.Ready0;   
	rxtx.tx.Ready0 := rxtx.tx.Ready;
  	rxtx.tx.ready :=tMaster.tx_ready;
    AxiReset(rxtx);
  end  AxiMonoMasterPullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiMonoSendReceiveMaster) is begin
    if txIsValid(RXTX) and txIsDataReady(RXTX) then 
      RXTX.tx.pos := RXTX.tx.pos + 1;
      if txIsLast(RXTX) then
        RXTX.tx.pos := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure  AxiMasterPushData(RXTX : inout AxiMonoSendReceiveMaster; signal fromMaster : out AxiMonoFromMaster_t) is begin
    fromMaster.TX_data.Data  <= RXTX.tx.data.Data;
    fromMaster.TX_data.DataLast <= RXTX.tx.data.DataLast;
    fromMaster.TX_data.DataValid <= RXTX.tx.data.DataValid;
    AxiTxIncrementPos(RXTX);
  end procedure AxiMasterPushData;


  procedure AxiMonoSlavePullData(RXTX : inout AxiMonoSendReceiveSlave; signal fromMaster : in AxiMonoFromMaster_t) is  begin
	 RXTX.RX.Ready1 := RXTX.Rx.Ready0;
    RXTX.RX.Ready0 := RXTX.Rx.Ready;
    RXTX.Rx.data.Data  := fromMaster.TX_data.Data;
    RXTX.Rx.data.DataLast  := fromMaster.TX_data.DataLast;
    RXTX.Rx.data.DataValid := fromMaster.TX_data.DataValid;
    AxiReset(RXTX);
  end procedure AxiMonoSlavePullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiMonoSendReceiveSlave) is begin
    if rxIsValidAndReady(RXTX) then 
      RXTX.rx.pos := RXTX.rx.pos + 1;
      if rxIsLast(RXTX) then
        RXTX.rx.pos := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure AxiSlavePushData(RXTX : inout AxiMonoSendReceiveSlave ; signal toMaster : out AxiMonoToMaster_t) is
  begin
    toMaster.TX_Ready <= RXTX.rx.Ready;
    AxiTxIncrementPos(RXTX);
  end procedure AxiSlavePushData;


  procedure txSetData(RXTX : out AxiMonoSendReceiveMaster; data : in data_t; valid : in sl := '1' ) is begin
    RXTX.tx.Data.Data := data;
    RXTX.tx.data.DataValid := valid;
  end procedure txSetData;

  procedure txSetLast(RXTX : out AxiMonoSendReceiveMaster; last : in sl := '1') is begin
    RXTX.tx.Data.DataLast := last;
  end procedure txSetLast;

  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t) is begin
    txPushData(RXTX, data, RXTX.tx.call_pos);
  end procedure txPushData;

  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t; position : in size_t) is begin 
    if position = RXTX.tx.pos then  
      txSetData(RXTX, data);
    end if;
    RXTX.tx.call_pos := position +1;
  end procedure txPushData;

  procedure txPushLast(RXTX : inout AxiMonoSendReceiveMaster) is begin
    if RXTX.tx.call_pos = RXTX.tx.pos+1 then  
      txSetLast(RXTX);
    end if;
    RXTX.tx.call_pos := RXTX.tx.call_pos +1;
  end procedure txPushLast;

  procedure txSetValid(RXTX : out AxiMonoSendReceiveMaster; valid : in sl := '1') is begin
    RXTX.tx.Data.DataValid := valid;
  end procedure txSetValid;

  function txIsLast(RXTX : in AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.data.DataLast = '1';
  end function txIsLast;


  function txIsValid(RXTX: in AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.data.DataValid = '1';
  end function txIsValid;

  function txGetData(RXTX : in AxiMonoSendReceiveMaster) return data_t is begin
    return RXTX.tx.data.Data;
  end function  txGetData;

  function rxIsDataReady(RXTX : in AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.Ready1 = '1';
  end function rxIsDataReady;

  function rxGetPosition(RXTX: in AxiMonoSendReceiveSlave) return size_t is begin
    return RXTX.rx.pos;
  end function rxGetPosition;

  function txIsDataReady(RXTX : AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.Ready = '1';
  end function txIsDataReady;

  function txGetPosition(RXTX : in AxiMonoSendReceiveMaster) return size_t is begin
    return RXTX.tx.pos;
  end function txGetPosition;

  procedure rxSetDataReady(RXTX : out AxiMonoSendReceiveSlave) is begin
    RXTX.rx.Ready := '1';
  end procedure rxSetDataReady;

  function rxGetData(RXTX : AxiMonoSendReceiveSlave) return data_t is begin
    return RXTX.rx.Data.Data;
  end function rxGetData;



  function rxIsLast(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.Data.DataLast = '1';
  end function rxIsLast;

  function rxIsValid(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.Data.DataValid = '1';
  end function rxIsValid;

  function rxIsValidAndReady(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return rxIsValid(RXTX) and RXTX.rx.Ready1 = '1';  

  end function rxIsValidAndReady;


  function rxIsPosition(RXTX : AxiMonoSendReceiveSlave; position :size_t ) return boolean is begin
    return rxIsValidAndReady(RXTX) and rxGetPosition(RXTX) = position;
  end function rxIsPosition;

  procedure rxPullData(RXTX: inout AxiMonoSendReceiveSlave; data :out data_t; position :in size_t) is begin
    if rxIsPosition(RXTX, position) then 
      data := RXTX.rx.data.Data;
    end if; 
    RXTX.rx.call_pos := RXTX.rx.call_pos + 1;
  end procedure rxPullData;

  procedure rxPullData(RXTX: inout AxiMonoSendReceiveSlave; data :out data_t) is begin
    rxPullData(RXTX,data,RXTX.rx.call_pos);
  end procedure rxPullData;


  procedure AxiReset(variable RXTX : out AxiMonoSendReceiveSlave) is begin
    RXTX.rx.Ready    := '0';
    RXTX.rx.call_pos := 0;
  end procedure AxiReset;

  procedure AxiReset(variable RXTX : out AxiMonoSendReceiveMaster) is begin
    RXTX.tx.call_pos := 0;
    RXTX.tx.data.DataLast  := '0';
    RXTX.tx.data.DataValid := '0';

  end procedure AxiReset;


  procedure AxiResetChannel(signal fMaster : out AxiMonoFromMaster_t ;signal  tmaster : out AxiMonoToMaster_t) is begin


    fMaster.TX_data.Data <= 0; 
    fMaster.TX_data.DataLast <='0';
    fMaster.TX_data.DataValid <= '0';


    tmaster.TX_Ready <= '0';
  end AxiResetChannel;


end package body AxiMonoStream;