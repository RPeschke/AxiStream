class AxiStream{

[string]$name;
[string]$dataType;
[string]$dataTypeName;
[string]$masterRecName;
[string]$slaveRecName;
[string]$ToMasterName;
[string]$fromMasterName;

    AxiStream($Name,$dataType){
        $this.dataType=$dataType;
        $this.dataTypeName="$($Name)_data_t"
        $this.name = $Name;
        $this.masterRecName = "AxiRXTXMaster_$($this.name)"
        $this.slaveRecName = "AxiRXTXSlave_$($this.name)"
        $this.ToMasterName = "AxiToMaster_$($this.name)"
        $this.fromMasterName = "AxiFromMaster_$($this.name)"
    }

    [System.Object]GetRecord(){
    $r1  = make_packet_entry -header "subtype  $($this.dataTypeName) is $($this.dataType);"
    $r2 = v_record -recordName $($this.name) -entries "
    ctrl   : AxiCtrl;
    data   : $($this.dataTypeName);
    Ready  : AxiDataReady_t;
	Ready0 : AxiDataReady_t;
    Ready1 : AxiDataReady_t;
    pos    :  size_t ;
    call_pos :  size_t;
    "
    $ret =@()
    $ret += $r1 
    $ret += $r2 
    
  return $ret;
    }

   [System.Object]MasterRecord(){
    
        $ret =  v_record -recordName $this.masterRecName -entries "
        tx : $($this.name); 
        "
        return $ret;
    }
    [System.Object]SlaveRecord(){
    
        $ret =  v_record -recordName $this.slaveRecName -entries "
        rx : $($this.name); 
        "
        return $ret; 

    }

    [System.Object]ToMasterRec(){
        $ret = v_record -recordName $($this.ToMasterName) -entries "TX_Ready : AxiDataReady_t;"
        return $ret;

    }

   [System.Object]FromMasterRec(){
        $ret =v_record  -recordName $($this.fromMasterName) -entries "TX_ctrl  : AxiCtrl;
        TX_Data  : data_t;"
        return $ret;
    }
}


function axistreamMono($axiName,$DataType,$packetName,$dataZero){
$myStream = [AxiStream]::new($axiName,$DataType)

$ret = "



library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all;


$(
v_packet -name $packetName -entries (
$myStream.GetRecord(),
$myStream.MasterRecord(),
$myStream.SlaveRecord(),
$myStream.ToMasterRec(),
$myStream.FromMasterRec(),
(v_procedure -name AxiPullData -argumentList "rxtx : inout $($myStream.masterRecName); signal tMaster : in $($myStream.ToMasterName)" -body "
    rxtx.tx.Ready1 := rxtx.tx.Ready0;   
    rxtx.tx.Ready0 := rxtx.tx.Ready;
  	rxtx.tx.ready :=tMaster.tx_ready;
    rxtx.tx.Data := $dataZero;
    AxiReset(rxtx);
 "),
 (v_procedure -name AxiTxIncrementPos -argumentList "RXTX: inout $($myStream.masterRecName)" -body "
    if txIsValid(RXTX) and txIsDataReady(RXTX) then 
      RXTX.tx.pos := RXTX.tx.pos + 1;
      if txIsLast(RXTX) then
        RXTX.tx.pos := 0;
      end if;
    end if;
 "),
 (v_procedure -name   AxiPushData -argumentList "RXTX : inout $($myStream.masterRecName); signal fromMaster : out $($myStream.fromMasterName)" -body "
    fromMaster.TX_Data  <= RXTX.tx.Data after 1 ns;
    fromMaster.TX_ctrl.DataLast <= RXTX.tx.ctrl.DataLast after 1 ns;
    fromMaster.TX_ctrl.DataValid <= RXTX.tx.ctrl.DataValid after 1 ns;
    AxiTxIncrementPos(RXTX);
  "),
  (v_procedure -name AxiPullData -argumentList "RXTX : inout $($myStream.slaveRecName); signal fromMaster : in $($myStream.fromMasterName)" -body "
    RXTX.RX.Ready1 := RXTX.Rx.Ready0;
    RXTX.RX.Ready0 := RXTX.Rx.Ready;
    RXTX.Rx.Data  := fromMaster.TX_Data;
    RXTX.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
    RXTX.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
    AxiReset(RXTX);
    "),
    (v_procedure -name AxiTxIncrementPos -argumentList "RXTX: inout $($myStream.slaveRecName)" -body "
    if rxIsValidAndReady(RXTX) then 
      RXTX.rx.pos := RXTX.rx.pos + 1;
      if rxIsLast(RXTX) then
        RXTX.rx.pos := 0;
      end if;
    end if;
    "),
    (v_procedure -name AxiPushData -argumentList "RXTX : inout $($myStream.slaveRecName) ; signal toMaster : out $($myStream.ToMasterName)" -body "
    toMaster.TX_Ready <= RXTX.rx.Ready after 1 ns;
    AxiTxIncrementPos(RXTX);
    "),
    (v_procedure -name txSetLast -argumentList "RXTX : out $($myStream.masterRecName); last : in sl := '1'" -body "
    RXTX.tx.ctrl.DataLast := last;
    "), 
    (v_procedure -name txPushData -argumentList "RXTX : inout $($myStream.masterRecName);   data : in $($myStream.dataTypeName)" -body "
    txPushData(RXTX, data, RXTX.tx.call_pos);
    "), 
    (v_procedure -name txPushData -argumentList "RXTX : inout $($myStream.masterRecName);   data : in $($myStream.dataTypeName); position : in size_t" -body "
    if position = RXTX.tx.pos then  
      txSetData(RXTX, data);
    end if;
    RXTX.tx.call_pos := position +1;
    "), 
    (v_procedure -name txPushLast -argumentList "RXTX : inout $($myStream.masterRecName)" -body "
    if RXTX.tx.call_pos = RXTX.tx.pos+1 then  
      txSetLast(RXTX);
    end if;
    RXTX.tx.call_pos := RXTX.tx.call_pos +1;
    "),
    (v_procedure -name txSetValid -argumentList "RXTX : out $($myStream.masterRecName); valid : in sl := '1'" -body "
        RXTX.tx.ctrl.DataValid := valid;
    "),
    (v_procedure -name txIsLast -argumentList "RXTX : in $($myStream.masterRecName)" -body "
        return RXTX.tx.ctrl.DataLast = '1';
    "),
    (v_function -name txIsValid -argumentList "RXTX: in $($myStream.masterRecName)" -returnType "boolean" -body "
        return RXTX.tx.ctrl.DataValid = '1';
    "),
    (v_function -name txGetData -argumentList "RXTX : in $($myStream.masterRecName)" -returnType "$($myStream.dataTypeName)" -body "
           return RXTX.tx.Data;
    "),
    (v_function -name rxIsDataReady -argumentList "RXTX : in $($myStream.slaveRecName)" -returnType "boolean" -body "
        return RXTX.rx.Ready1 = '1';
    "),
    (v_function -name rxGetPosition -argumentList "RXTX: in $($myStream.slaveRecName)" -returnType "size_t" -body "
       return RXTX.rx.pos;
    "),
    (v_procedure -name rxSetDataReady -argumentList "RXTX : out $($myStream.slaveRecName)" -body "
        RXTX.rx.Ready := '1';
    "),
    (v_function -name rxGetData -argumentList "RXTX: in $($myStream.slaveRecName)" -returnType "size_t" -body "
       return RXTX.rx.pos;
    "),
    (v_function -name rxIsLast -argumentList "RXTX : $($myStream.slaveRecName)" -returnType "boolean" -body "
    return RXTX.rx.ctrl.DataLast = '1';
    "),
    (v_function -name rxIsValid -argumentList "RXTX : $($myStream.slaveRecName)" -returnType "boolean" -body "
    return RXTX.rx.ctrl.DataValid = '1';
    "),
    (v_function -name rxIsValidAndReady -argumentList "RXTX : $($myStream.slaveRecName)" -returnType "boolean" -body "
     return rxIsValid(RXTX) and RXTX.rx.Ready1 = '1';  
    "),
    (v_function -name rxIsPosition -argumentList "RXTX : $($myStream.slaveRecName); position :size_t" -returnType "boolean" -body "
        return rxIsValidAndReady(RXTX) and rxGetPosition(RXTX) = position;
    "),
    (v_procedure -name rxPullData -argumentList "RXTX: inout $($myStream.slaveRecName); data :out $($myStream.dataTypeName); position :in size_t" -body "
    if rxIsPosition(RXTX, position) then 
      data := RXTX.rx.Data;
    end if; 
    RXTX.rx.call_pos := RXTX.rx.call_pos + 1;
    "),
    (v_procedure -name rxPullData -argumentList "RXTX: inout $($myStream.slaveRecName); data :out $($myStream.dataTypeName)" -body "
        rxPullData(RXTX,data,RXTX.rx.call_pos);
    "),
     (v_procedure -name AxiReset -argumentList "variable RXTX : out $($myStream.slaveRecName)" -body "
    RXTX.rx.Ready    := '0';
    RXTX.rx.call_pos := 0;
    "),
     (v_procedure -name AxiReset -argumentList "variable RXTX : out $($myStream.masterRecName)" -body "
    RXTX.tx.call_pos := 0;
    RXTX.tx.ctrl.DataLast  := '0';
    RXTX.tx.ctrl.DataValid := '0';
    "),
    (v_procedure -name AxiResetChannel -argumentList "signal fMaster : out $($myStream.fromMasterName) ;signal  tmaster : out $($myStream.ToMasterName)" -body "

    fMaster.TX_Data <= $dataZero; 
    fMaster.TX_ctrl.DataLast <='0';
    fMaster.TX_ctrl.DataValid <= '0';


    tmaster.TX_Ready <= '0';
    ")




)) 
"
return $ret;

}