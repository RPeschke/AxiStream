
function axistreamMono1($axiName,$DataType,$packetName,$dataZero){

        $dataTypeName="$($axiName)_data_t"

        $masterRecName = "AxiRXTXMaster_$($axiName)"
        $slaveRecName = "AxiRXTXSlave_$($axiName)"
        $ToMasterName = "AxiToMaster_$($axiName)"
        $fromMasterName = "AxiFromMaster_$($axiName)"


$r = "library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all; 

  $(v_packet -name $packetName -entries (

        (v_subtype -name  $dataTypeName -type $DataType),
        (v_procedure -name AxiStreamReset -argumentList "data : inout $($dataTypeName)" -body "data := $dataZero;"),


        (v_record -name "$axiName" -entries (
         (v_member -name "ctrl"     -type "AxiCtrl" ),
         (v_member -name "data"     -type "$dataTypeName" -default $dataZero),
         (v_member -name "Ready"    -type "AxiDataReady_t" ),
         (v_member -name "Ready0"   -type "AxiDataReady_t" ),
         (v_member -name "Ready1"   -type "AxiDataReady_t" ),
         (v_member -name "position"      -type "size_t" ),
         (v_member -name "call_pos" -type "size_t" )
        )),
        
        (v_record -name $ToMasterName -entries (
          (v_member -name "TX_Ready" -type "AxiDataReady_t")
        )),

        (v_record -name $fromMasterName -entries (
          (v_member -name "TX_ctrl" -type "AxiCtrl"),
          (v_member -name "TX_Data" -type "$dataTypeName" -default $dataZero)
        )),

        (v_class -name "$masterRecName" -entries (
         (v_member -name "tx"     -type "$axiName"),
         
         (v_procedure -name AxiPullData -argumentList "signal tMaster : in $($ToMasterName)" -body "
            this.tx.Ready1 := this.tx.Ready0;   
            this.tx.Ready0 := this.tx.Ready;
  	        this.tx.ready :=tMaster.tx_ready;
            AxiStreamReset(this.tx.Data);
            AxiReset(this);
         "),
          (v_procedure -name AxiTxIncrementPos -body "
            if txIsValid(this) and txIsDataReady(this) then 
              this.tx.position := this.tx.position + 1;
              if txIsLast(this) then
                this.tx.position := 0;
              end if;
            end if;
         "),
         (v_function -name txIsDataReady -returnType "boolean" -body  "
             return this.tx.Ready = '1';
         "),
         (v_procedure -name   AxiPushData -argumentList "signal fromMaster : out $($fromMasterName)" -body "
            fromMaster.TX_Data  <= this.tx.Data after 1 ns;
            fromMaster.TX_ctrl.DataLast <= this.tx.ctrl.DataLast after 1 ns;
            fromMaster.TX_ctrl.DataValid <= this.tx.ctrl.DataValid after 1 ns;
            AxiTxIncrementPos(this);
         "),
         (v_procedure -name txSetData -argumentList "data : in $($dataTypeName)" -body '
            if not txIsDataReady(this) then 
                report "Error slave is not ready";
            end if;
            if txIsValid(this) then 
                report "Error data already set";
            end if;
            this.tx.Data := data;
            txSetValid(this);
         '),
         (v_procedure -name txSetLast -argumentList "last : in sl := '1'" -body '
            if not txIsValid(this) then 
                report "Error data not set";
            end if;
            this.tx.ctrl.DataLast := last;
         '),
         (v_procedure -name txPushData -argumentList "data : in $($dataTypeName)" -body "
            txPushData(this, data, this.tx.call_pos);
          "), 
         (v_procedure -name txPushData -argumentList "data : in $($dataTypeName); position : in size_t" -body "
            if position = this.tx.position then  
                txSetData(this, data);
            end if;
            this.tx.call_pos := position +1;
         "),     
         (v_procedure -name txPushLast  -body "
            if this.tx.call_pos = this.tx.position+1 then  
                txSetLast(this);
            end if;
            this.tx.call_pos := this.tx.call_pos +1;
         "),
         (v_procedure -name txSetValid -argumentList "valid : in sl := '1'" -body "
            this.tx.ctrl.DataValid := valid;
         "),
         (v_function -name txIsLast -returnType "boolean" -body "
            return this.tx.ctrl.DataLast = '1';
         "),
         (v_function -name txIsValid -returnType "boolean" -body "
            return this.tx.ctrl.DataValid = '1';
         "),
         (v_function -name txGetData  -returnType "$($dataTypeName)" -body "
            return this.tx.Data;
         "),
         (v_procedure -name AxiReset  -body "
            this.tx.call_pos := 0;
            this.tx.ctrl.DataLast  := '0';
            this.tx.ctrl.DataValid := '0';
         ")

        )
       ),



       (v_class -name $slaveRecName -entries (
        (v_member -name "RX" -type $axiName),
        (v_procedure -name AxiPullData -argumentList "signal fromMaster : in $($fromMasterName)" -body "
            this.RX.Ready1 := this.Rx.Ready0;
            this.RX.Ready0 := this.Rx.Ready;
            this.Rx.Data  := fromMaster.TX_Data;
            this.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
            this.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
            AxiReset(this);
        "),
        (v_procedure -name AxiTxIncrementPos  -body "
             if rxIsValidAndReady(this) then 
                this.rx.position := this.rx.position + 1;
                if rxIsLast(this) then
                    this.rx.position := 0;
                end if;
             end if;
        "),
        (v_procedure -name AxiPushData -argumentList "signal toMaster : out $($ToMasterName)" -body "
            toMaster.TX_Ready <= this.rx.Ready after 1 ns;
            AxiTxIncrementPos(this);
         "),
         (v_function -name rxIsDataReady  -returnType "boolean" -body "
            return this.rx.Ready1 = '1';
         "),
         (v_function -name rxGetPosition   -returnType "size_t" -body "
            return this.rx.position;
         "),
         (v_procedure -name rxSetDataReady  -body "
            this.rx.Ready := '1';
         "),
         (v_function -name rxGetData  -returnType "size_t" -body "
            return this.rx.data;
         "),
         (v_function -name rxIsLast -returnType "boolean" -body "
            return this.rx.ctrl.DataLast = '1';
         "),
         (v_function -name rxIsValid  -returnType "boolean" -body "
            return this.rx.ctrl.DataValid = '1';
         "),
         (v_function -name rxIsValidAndReady -returnType "boolean" -body "
            return rxIsValid(this) and this.rx.Ready1 = '1';  
         "),
         (v_function -name rxIsPosition -argumentList "position :size_t" -returnType "boolean" -body "
            return rxIsValidAndReady(this) and rxGetPosition(this) = position;
         "),
         (v_procedure -name rxPullData -argumentList "data :out $($dataTypeName); position :in size_t" -body "
            if rxIsPosition(this, position) then 
                data := this.rx.Data;
            end if; 
            this.rx.call_pos := this.rx.call_pos + 1;
          "),
          (v_procedure -name rxPullData -argumentList "data :out $($dataTypeName)" -body "
            rxPullData(this ,data,this.rx.call_pos);
          "),
          (v_procedure -name AxiReset -body "
            this.rx.Ready    := '0';
            this.rx.call_pos := 0;
          ")
       ))
    

))"
return $r
}