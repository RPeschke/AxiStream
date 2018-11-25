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
  
  constant c_AxiMonoToMaster_t : AxiMonoToMaster_t := (TX_Ready => '0');

  type AxiMonoFromMaster_t is record
    TX_ctrl  : AxiCtrl;
    TX_Data  : data_t; 
  end record AxiMonoFromMaster_t;
  
  constant c_AxiMonoFromMaster_t : AxiMonoFromMaster_t := (TX_ctrl => axiCtrl_null, TX_Data => 0);
  

  type AxiBiDirectional is record
    from_master : AxiMonoFromMaster_t;
    to_master   : AxiMonoToMaster_t;
  end record AxiBiDirectional;





  --Master Interface 
  procedure AxiPullData(rxtx : inout AxiMonoSendReceiveMaster; signal tMaster : in AxiMonoToMaster_t);
  procedure AxiPushData(RXTX : inout AxiMonoSendReceiveMaster; signal fromMaster : out AxiMonoFromMaster_t);
  -- end Master Interface  

  -- Slave interface
  procedure AxiPullData(RXTX : inout AxiMonoSendReceiveSlave;signal fromMaster : in AxiMonoFromMaster_t) ;
  procedure AxiPushData(RXTX : inout AxiMonoSendReceiveSlave; signal toMaster : out AxiMonoToMaster_t) ;
  -- end Slave interface 


  -- TX interface  
  procedure txSetData(RXTX : inout AxiMonoSendReceiveMaster; data : in data_t; valid : in sl := '1' );
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


  procedure AxiPullData(rxtx : inout AxiMonoSendReceiveMaster; signal tMaster : in AxiMonoToMaster_t) is begin
    rxtx.tx.Ready1 := rxtx.tx.Ready0;   
    rxtx.tx.Ready0 := rxtx.tx.Ready;
  	rxtx.tx.ready :=tMaster.tx_ready;
    rxtx.tx.Data := 0;
    AxiReset(rxtx);
  end  AxiPullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiMonoSendReceiveMaster) is begin
    if txIsValid(RXTX) and txIsDataReady(RXTX) then 
      RXTX.tx.position := RXTX.tx.position + 1;
      if txIsLast(RXTX) then
        RXTX.tx.position := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure  AxiPushData(RXTX : inout AxiMonoSendReceiveMaster; signal fromMaster : out AxiMonoFromMaster_t) is begin
    fromMaster.TX_Data  <= RXTX.tx.Data after 1 ns;
    fromMaster.TX_ctrl.DataLast <= RXTX.tx.ctrl.DataLast after 1 ns;
    fromMaster.TX_ctrl.DataValid <= RXTX.tx.ctrl.DataValid after 1 ns;
    AxiTxIncrementPos(RXTX);
  end procedure AxiPushData;


  procedure AxiPullData(RXTX : inout AxiMonoSendReceiveSlave; signal fromMaster : in AxiMonoFromMaster_t) is  begin
    RXTX.RX.Ready1 := RXTX.Rx.Ready0;
    RXTX.RX.Ready0 := RXTX.Rx.Ready;
    RXTX.Rx.Data  := fromMaster.TX_Data;
    RXTX.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
    RXTX.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
    AxiReset(RXTX);
  end procedure AxiPullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiMonoSendReceiveSlave) is begin
    if rxIsValidAndReady(RXTX) then 
      RXTX.rx.position := RXTX.rx.position + 1;
      if rxIsLast(RXTX) then
        RXTX.rx.position := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure AxiPushData(RXTX : inout AxiMonoSendReceiveSlave ; signal toMaster : out AxiMonoToMaster_t) is
  begin
    toMaster.TX_Ready <= RXTX.rx.Ready after 1 ns;
    AxiTxIncrementPos(RXTX);
  end procedure AxiPushData;


  procedure txSetData(RXTX : inout AxiMonoSendReceiveMaster; data : in data_t; valid : in sl := '1' ) is begin
    if not txIsDataReady(RXTX) then 
      report "Error";
    end if;
    RXTX.tx.Data := data;
    RXTX.tx.ctrl.DataValid := valid;
  end procedure txSetData;

  procedure txSetLast(RXTX : out AxiMonoSendReceiveMaster; last : in sl := '1') is begin
    RXTX.tx.ctrl.DataLast := last;
  end procedure txSetLast;

  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t) is begin
    txPushData(RXTX, data, RXTX.tx.call_pos);
  end procedure txPushData;

  procedure txPushData(RXTX : inout AxiMonoSendReceiveMaster;   data : in data_t; position : in size_t) is begin 
    if position = RXTX.tx.position then  
      txSetData(RXTX, data);
    end if;
    RXTX.tx.call_pos := position +1;
  end procedure txPushData;

  procedure txPushLast(RXTX : inout AxiMonoSendReceiveMaster) is begin
    if RXTX.tx.call_pos = RXTX.tx.position+1 then  
      txSetLast(RXTX);
    end if;
    RXTX.tx.call_pos := RXTX.tx.call_pos +1;
  end procedure txPushLast;

  procedure txSetValid(RXTX : out AxiMonoSendReceiveMaster; valid : in sl := '1') is begin
    RXTX.tx.ctrl.DataValid := valid;
  end procedure txSetValid;

  function txIsLast(RXTX : in AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.ctrl.DataLast = '1';
  end function txIsLast;


  function txIsValid(RXTX: in AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.ctrl.DataValid = '1';
  end function txIsValid;

  function txGetData(RXTX : in AxiMonoSendReceiveMaster) return data_t is begin
    return RXTX.tx.Data;
  end function  txGetData;

  function rxIsDataReady(RXTX : in AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.Ready1 = '1';
  end function rxIsDataReady;

  function rxGetPosition(RXTX: in AxiMonoSendReceiveSlave) return size_t is begin
    return RXTX.rx.position;
  end function rxGetPosition;

  function txIsDataReady(RXTX : AxiMonoSendReceiveMaster) return boolean is begin
    return RXTX.tx.Ready = '1';
  end function txIsDataReady;

  function txGetPosition(RXTX : in AxiMonoSendReceiveMaster) return size_t is begin
    return RXTX.tx.position;
  end function txGetPosition;

  procedure rxSetDataReady(RXTX : out AxiMonoSendReceiveSlave) is begin
    RXTX.rx.Ready := '1';
  end procedure rxSetDataReady;

  function rxGetData(RXTX : AxiMonoSendReceiveSlave) return data_t is begin
    return RXTX.rx.Data;
  end function rxGetData;



  function rxIsLast(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.ctrl.DataLast = '1';
  end function rxIsLast;

  function rxIsValid(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return RXTX.rx.ctrl.DataValid = '1';
  end function rxIsValid;

  function rxIsValidAndReady(RXTX : AxiMonoSendReceiveSlave) return boolean is begin
    return rxIsValid(RXTX) and RXTX.rx.Ready1 = '1';  

  end function rxIsValidAndReady;


  function rxIsPosition(RXTX : AxiMonoSendReceiveSlave; position :size_t ) return boolean is begin
    return rxIsValidAndReady(RXTX) and rxGetPosition(RXTX) = position;
  end function rxIsPosition;

  procedure rxPullData(RXTX: inout AxiMonoSendReceiveSlave; data :out data_t; position :in size_t) is begin
    if rxIsPosition(RXTX, position) then 
      data := RXTX.rx.Data;
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
    RXTX.tx.ctrl.DataLast  := '0';
    RXTX.tx.ctrl.DataValid := '0';

  end procedure AxiReset;


  procedure AxiResetChannel(signal fMaster : out AxiMonoFromMaster_t ;signal  tmaster : out AxiMonoToMaster_t) is begin


    fMaster.TX_Data <= 0; 
    fMaster.TX_ctrl.DataLast <='0';
    fMaster.TX_ctrl.DataValid <= '0';


    tmaster.TX_Ready <= '0';
  end AxiResetChannel;


end package body AxiMonoStream;