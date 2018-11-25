



library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all;


package axiIntTest is






  subtype  axiInt_data_t is integer;

  
  type axiInt is record
    ctrl   : AxiCtrl;
    data   : axiInt_data_t;
    Ready  : AxiDataReady_t;
	Ready0 : AxiDataReady_t;
    Ready1 : AxiDataReady_t;
    pos    :  size_t ;
    call_pos :  size_t;
  end record axiInt;

  




type AxiRXTXMaster_axiInt is record 

        tx : axiInt; 
        
end record AxiRXTXMaster_axiInt; 



type AxiRXTXSlave_axiInt is record 

        rx : axiInt; 
        
end record AxiRXTXSlave_axiInt; 



type AxiToMaster_axiInt is record 
TX_Ready : AxiDataReady_t;
end record AxiToMaster_axiInt; 


type AxiFromMaster_axiInt is record 
TX_ctrl  : AxiCtrl;
    TX_Data  : data_t;
end record AxiFromMaster_axiInt; 






  --Master Interface 
  procedure AxiPullData(rxtx : inout AxiRXTXMaster_axiInt; signal tMaster : in AxiToMaster_axiInt);
  procedure AxiPushData(RXTX : inout AxiRXTXMaster_axiInt; signal fromMaster : out AxiFromMaster_axiInt);
  -- end Master Interface  

  -- Slave interface
  procedure AxiPullData(RXTX : inout AxiRXTXSlave_axiInt;signal fromMaster : in AxiFromMaster_axiInt) ;
  procedure AxiPushData(RXTX : inout AxiRXTXSlave_axiInt; signal toMaster : out AxiToMaster_axiInt) ;
  -- end Slave interface 


  -- TX interface  
  procedure txSetData(RXTX : out AxiRXTXMaster_axiInt; data : in axiInt_data_t; valid : in sl := '1' );
  procedure txSetLast(RXTX : out AxiRXTXMaster_axiInt; last : in sl := '1');

  procedure txPushData(RXTX : inout AxiRXTXMaster_axiInt;   data : in axiInt_data_t);
  procedure txPushData(RXTX : inout AxiRXTXMaster_axiInt;   data : in axiInt_data_t; position : in size_t);
  procedure txPushLast(RXTX : inout AxiRXTXMaster_axiInt);

  procedure txSetValid(RXTX : out AxiRXTXMaster_axiInt; valid : in sl := '1');


  function txIsLast(RXTX : in AxiRXTXMaster_axiInt) return boolean;
  function txIsValid(RXTX: in AxiRXTXMaster_axiInt) return boolean;
  function txGetData(RXTX : in AxiRXTXMaster_axiInt) return axiInt_data_t;
  function txIsDataReady(RXTX : AxiRXTXMaster_axiInt) return boolean;   
  function txGetPosition(RXTX : in AxiRXTXMaster_axiInt) return size_t;
  -- TX interface end  


  -- RX interface 
  procedure rxSetDataReady(RXTX : out AxiRXTXSlave_axiInt);
  function rxGetData(RXTX : AxiRXTXSlave_axiInt) return axiInt_data_t ;
  function rxIsDataReady(RXTX : in AxiRXTXSlave_axiInt) return boolean;
  function rxGetPosition(RXTX: in AxiRXTXSlave_axiInt) return size_t;



  function rxIsLast(RXTX : AxiRXTXSlave_axiInt) return boolean; 
  function rxIsValid(RXTX : AxiRXTXSlave_axiInt) return boolean; 
  function rxIsValidAndReady(RXTX : AxiRXTXSlave_axiInt) return boolean; 
  function rxIsPosition(RXTX : AxiRXTXSlave_axiInt; position :size_t ) return boolean; 

  procedure rxPullData(RXTX: inout AxiRXTXSlave_axiInt; data :out axiInt_data_t; position :in size_t);
  procedure rxPullData(RXTX: inout AxiRXTXSlave_axiInt; data :out axiInt_data_t);
  -- RX interface end


  procedure AxiReset(variable RXTX : out AxiRXTXSlave_axiInt);
  procedure AxiReset(variable RXTX : out AxiRXTXMaster_axiInt);


  procedure AxiResetChannel(signal fMaster : out AxiFromMaster_axiInt ;signal  tmaster : out AxiToMaster_axiInt);



end axiIntTest;

package body axiIntTest is


  procedure AxiPullData(rxtx : inout AxiRXTXMaster_axiInt; signal tMaster : in AxiToMaster_axiInt) is begin
    rxtx.tx.Ready1 := rxtx.tx.Ready0;   
    rxtx.tx.Ready0 := rxtx.tx.Ready;
  	rxtx.tx.ready :=tMaster.tx_ready;
    rxtx.tx.Data := 0;
    AxiReset(rxtx);
  end  AxiPullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiRXTXMaster_axiInt) is begin
    if txIsValid(RXTX) and txIsDataReady(RXTX) then 
      RXTX.tx.pos := RXTX.tx.pos + 1;
      if txIsLast(RXTX) then
        RXTX.tx.pos := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure  AxiPushData(RXTX : inout AxiRXTXMaster_axiInt; signal fromMaster : out AxiFromMaster_axiInt) is begin
    fromMaster.TX_Data  <= RXTX.tx.Data after 1 ns;
    fromMaster.TX_ctrl.DataLast <= RXTX.tx.ctrl.DataLast after 1 ns;
    fromMaster.TX_ctrl.DataValid <= RXTX.tx.ctrl.DataValid after 1 ns;
    AxiTxIncrementPos(RXTX);
  end procedure AxiPushData;


  procedure AxiPullData(RXTX : inout AxiRXTXSlave_axiInt; signal fromMaster : in AxiFromMaster_axiInt) is  begin
    RXTX.RX.Ready1 := RXTX.Rx.Ready0;
    RXTX.RX.Ready0 := RXTX.Rx.Ready;
    RXTX.Rx.Data  := fromMaster.TX_Data;
    RXTX.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
    RXTX.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
    AxiReset(RXTX);
  end procedure AxiPullData;

  procedure AxiTxIncrementPos(RXTX: inout AxiRXTXSlave_axiInt) is begin
    if rxIsValidAndReady(RXTX) then 
      RXTX.rx.pos := RXTX.rx.pos + 1;
      if rxIsLast(RXTX) then
        RXTX.rx.pos := 0;
      end if;
    end if;

  end procedure AxiTxIncrementPos;



  procedure AxiPushData(RXTX : inout AxiRXTXSlave_axiInt ; signal toMaster : out AxiToMaster_axiInt) is
  begin
    toMaster.TX_Ready <= RXTX.rx.Ready after 1 ns;
    AxiTxIncrementPos(RXTX);
  end procedure AxiPushData;


  procedure txSetData(RXTX : out AxiRXTXMaster_axiInt; data : in axiInt_data_t; valid : in sl := '1' ) is begin
    RXTX.tx.Data := data;
    RXTX.tx.ctrl.DataValid := valid;
  end procedure txSetData;

  procedure txSetLast(RXTX : out AxiRXTXMaster_axiInt; last : in sl := '1') is begin
    RXTX.tx.ctrl.DataLast := last;
  end procedure txSetLast;

  procedure txPushData(RXTX : inout AxiRXTXMaster_axiInt;   data : in axiInt_data_t) is begin
    txPushData(RXTX, data, RXTX.tx.call_pos);
  end procedure txPushData;

  procedure txPushData(RXTX : inout AxiRXTXMaster_axiInt;   data : in axiInt_data_t; position : in size_t) is begin 
    if position = RXTX.tx.pos then  
      txSetData(RXTX, data);
    end if;
    RXTX.tx.call_pos := position +1;
  end procedure txPushData;

  procedure txPushLast(RXTX : inout AxiRXTXMaster_axiInt) is begin
    if RXTX.tx.call_pos = RXTX.tx.pos+1 then  
      txSetLast(RXTX);
    end if;
    RXTX.tx.call_pos := RXTX.tx.call_pos +1;
  end procedure txPushLast;

  procedure txSetValid(RXTX : out AxiRXTXMaster_axiInt; valid : in sl := '1') is begin
    RXTX.tx.ctrl.DataValid := valid;
  end procedure txSetValid;

  function txIsLast(RXTX : in AxiRXTXMaster_axiInt) return boolean is begin
    return RXTX.tx.ctrl.DataLast = '1';
  end function txIsLast;


  function txIsValid(RXTX: in AxiRXTXMaster_axiInt) return boolean is begin
    return RXTX.tx.ctrl.DataValid = '1';
  end function txIsValid;

  function txGetData(RXTX : in AxiRXTXMaster_axiInt) return axiInt_data_t is begin
    return RXTX.tx.Data;
  end function  txGetData;

  function rxIsDataReady(RXTX : in AxiRXTXSlave_axiInt) return boolean is begin
    return RXTX.rx.Ready1 = '1';
  end function rxIsDataReady;

  function rxGetPosition(RXTX: in AxiRXTXSlave_axiInt) return size_t is begin
    return RXTX.rx.pos;
  end function rxGetPosition;

  function txIsDataReady(RXTX : AxiRXTXMaster_axiInt) return boolean is begin
    return RXTX.tx.Ready = '1';
  end function txIsDataReady;

  function txGetPosition(RXTX : in AxiRXTXMaster_axiInt) return size_t is begin
    return RXTX.tx.pos;
  end function txGetPosition;

  procedure rxSetDataReady(RXTX : out AxiRXTXSlave_axiInt) is begin
    RXTX.rx.Ready := '1';
  end procedure rxSetDataReady;

  function rxGetData(RXTX : AxiRXTXSlave_axiInt) return axiInt_data_t is begin
    return RXTX.rx.Data;
  end function rxGetData;



  function rxIsLast(RXTX : AxiRXTXSlave_axiInt) return boolean is begin
    return RXTX.rx.ctrl.DataLast = '1';
  end function rxIsLast;

  function rxIsValid(RXTX : AxiRXTXSlave_axiInt) return boolean is begin
    return RXTX.rx.ctrl.DataValid = '1';
  end function rxIsValid;

  function rxIsValidAndReady(RXTX : AxiRXTXSlave_axiInt) return boolean is begin
    return rxIsValid(RXTX) and RXTX.rx.Ready1 = '1';  

  end function rxIsValidAndReady;


  function rxIsPosition(RXTX : AxiRXTXSlave_axiInt; position :size_t ) return boolean is begin
    return rxIsValidAndReady(RXTX) and rxGetPosition(RXTX) = position;
  end function rxIsPosition;

  procedure rxPullData(RXTX: inout AxiRXTXSlave_axiInt; data :out axiInt_data_t; position :in size_t) is begin
    if rxIsPosition(RXTX, position) then 
      data := RXTX.rx.Data;
    end if; 
    RXTX.rx.call_pos := RXTX.rx.call_pos + 1;
  end procedure rxPullData;

  procedure rxPullData(RXTX: inout AxiRXTXSlave_axiInt; data :out axiInt_data_t) is begin
    rxPullData(RXTX,data,RXTX.rx.call_pos);
  end procedure rxPullData;


  procedure AxiReset(variable RXTX : out AxiRXTXSlave_axiInt) is begin
    RXTX.rx.Ready    := '0';
    RXTX.rx.call_pos := 0;
  end procedure AxiReset;

  procedure AxiReset(variable RXTX : out AxiRXTXMaster_axiInt) is begin
    RXTX.tx.call_pos := 0;
    RXTX.tx.ctrl.DataLast  := '0';
    RXTX.tx.ctrl.DataValid := '0';

  end procedure AxiReset;


  procedure AxiResetChannel(signal fMaster : out AxiFromMaster_axiInt ;signal  tmaster : out AxiToMaster_axiInt) is begin


    fMaster.TX_Data <= 0; 
    fMaster.TX_ctrl.DataLast <='0';
    fMaster.TX_ctrl.DataValid <= '0';


    tmaster.TX_Ready <= '0';
  end AxiResetChannel;


end package body axiIntTest;


