﻿
function axiClass($name,$type){
    $ret =  (v_class -name $name  -entries (
         (v_member -name "ctrl"     -type "AxiCtrl" ),
         (v_member -name "data"     -type "$type"),
         (v_member -name "Ready"    -type "AxiDataReady_t"  ),
         (v_member -name "Ready0"   -type "AxiDataReady_t" ),
         (v_member -name "Ready1"   -type "AxiDataReady_t" ),
         (v_member -name "position" -type "size_t" ),
         (v_procedure -name resetSender -body "
            resetData(this.Data);
            this.ctrl.DataLast  := '0';
            this.ctrl.DataValid := '0';
         "),
         (v_procedure -name pullSender -argumentList "tx_ready : in AxiDataReady_t" -body "
            this.Ready1 := this.Ready0;   
            this.Ready0 := this.Ready;
  	        this.ready :=tx_ready;
            resetSender(this);
         "),
         (v_procedure -name pushSender -argumentList "signal TX_Data : out $type; signal DataLast: out sl; signal DataValid: out sl" -body "
            TX_Data  <= this.Data after 1 ns;
            DataLast <= this.ctrl.DataLast after 1 ns;
            DataValid <= this.ctrl.DataValid after 1 ns;
            IncrementPosSender(this);
         "),

         (v_procedure -name IncrementPosSender -body "
            if IsValid(this) and IsReady(this) then 
              this.position := this.position + 1;
              if isLast(this) then
                this.position := 0;
              end if;
            end if;
         "),
         (v_procedure -name ResetReceiver -body "
            this.Ready    := '0';
            
          "),
         (v_procedure -name pullReceiver -argumentList "RX_Data : in $type; DataLast : in sl; DataValid : in sl" -body  "
            this.Ready1 := this.Ready0;
            this.Ready0 := this.Ready;
            this.Data  := RX_Data;
            this.ctrl.DataLast  := DataLast;
            this.ctrl.DataValid := DataValid;

            ResetReceiver(this);
          "),
         (v_procedure -name pushReceiver -argumentList "signal RX_Ready : out AxiDataReady_t" -body  "
            RX_Ready <= this.Ready after 1 ns;
            IncrementPosReceiver(this);
          "),
          (v_procedure -name IncrementPosReceiver  -body "
             if IsValid(this) and  wasReady(this) then 
                this.position := this.position + 1;
                if isLast(this) then
                    this.position := 0;
                end if;
             end if;
          "), 
          (v_function -name IsReady -returnType "boolean" -body  "
             return this.Ready = '1';
          "),
          (v_function -name wasReady -returnType "boolean" -body  "
            return this.Ready1 = '1';
          "),
          (v_function -name IsValid -returnType "boolean" -body  "
             return this.ctrl.DataValid = '1';
          "),
          (v_function -name isLast -returnType boolean -body "
            return this.ctrl.DataLast = '1';
          "),
          (v_procedure -name SetValid -argumentList "valid : in sl := '1'" -body '
            if not IsReady(this) then 
                report "Error receiver not ready";
            end if;
            this.ctrl.DataValid := valid;
          '),
          (v_procedure -name SetLast -argumentList "last : in sl := '1'" -body '
            if not IsValid(this) then 
                report "Error data not set";
            end if;
            this.ctrl.DataLast := last;
         '),
         (v_procedure -name SetData -argumentList "data : in $($type)" -body '
            if not IsReady(this) then 
                report "Error slave is not ready";
            end if;
            if IsValid(this) then 
                report "Error data already set";
            end if;
            this.Data := data;
            SetValid(this);
         ')
         

        ))

    return $ret
}

function axiHandle($name, $txClassName,$RxClassName,$fromMasterName,$ToMasterName,$TxDataType,$RxDataType, [switch]$Slave){

if($Slave){
$AxiPullData =(v_procedure -name AxiPullData -argumentList "signal fMaster : in $($fromMasterName)" -body "
            pullSender(this.tx, fMaster.RX_Ready);
            pullReceiver(this.rx, fMaster.TX_Data ,fMaster.TX_ctrl.DataLast,  fMaster.TX_ctrl.DataValid);

          ")

$AxiPushData = (v_procedure -name   AxiPushData -argumentList "signal toMaster : out $($ToMasterName)" -body "
            pushSender(this.tx, toMaster.RX_Data ,toMaster.RX_ctrl.DataLast,toMaster.RX_ctrl.DataValid );
            pushReceiver(this.rx, toMaster.TX_Ready);
          ")

}else {

$AxiPullData =(v_procedure -name AxiPullData -argumentList "signal tMaster : in $($ToMasterName)" -body "
            pullSender(this.tx, tMaster.tx_ready);
            pullReceiver(this.rx, tMaster.RX_Data ,tMaster.RX_ctrl.DataLast,  tMaster.RX_ctrl.DataValid);

          ")

$AxiPushData = (v_procedure -name   AxiPushData -argumentList "signal fromMaster : out $($fromMasterName)" -body "
            pushSender(this.tx, fromMaster.TX_Data ,fromMaster.TX_ctrl.DataLast,fromMaster.TX_ctrl.DataValid );
            pushReceiver(this.rx, fromMaster.RX_Ready);
          ")
}


$ret = (v_class -name "$name" -entries (
         (v_member -name "tx"     -type "$txClassName"),
         (v_member -name "rx"     -type "$RxClassName"),
         
         $AxiPullData,
         $AxiPushData,


         (v_function -name txIsReady -returnType "boolean" -body  "
             return IsReady(this.tx);
         "),

         (v_procedure -name txSetData -argumentList "data : in $($TxDataType)" -body '
            SetData(this.tx, data);
         '),
         (v_procedure -name txSetLast  -body '
            SetLast(this.tx);
         '),
         (v_function -name txIsLast -returnType "boolean" -body "
            return this.tx.ctrl.DataLast = '1';
         "),
         (v_function -name txIsValid -returnType "boolean" -body "
            return this.tx.ctrl.DataValid = '1';
         "),
         (v_function -name txGetData  -returnType "$($TxDataType)" -body "
            return this.tx.Data;
         "),
         (v_function -name txGetPos  -returnType "size_t" -body "
            return this.tx.position;
         "),
         (v_function -name rxIsValidAndReady -returnType "boolean" -body "
            return IsValid(this.rx) and wasReady(this.rx);  
         "),
         (v_function -name rxGetData  -returnType "$($RxDataType)" -body '
            if not rxIsValidAndReady(this) then 
              report "Error data already set";
            end if;
            return this.rx.data;
         '),
         (v_procedure -name rxSetReady  -body "
            this.rx.Ready := '1';
         "),
         (v_function -name rxGetPos  -returnType "size_t" -body "
            return this.rx.position;
         ")
         
        )
       )

       return $ret
}


function axistream_BiDirectional($axiName,$packetName,$DataTypeFromMaster,$dataZeroFromMaster,$DataTypeToMaster,$dataZeroToMaster){

        $dataTypeNameFromMaster="$($DataTypeFromMaster)_data_t"
        $dataTypeNameToMaster="$($DataTypeToMaster)_data_t"

        $masterRecName = "AxiRXTXMaster_$($axiName)"
        $slaveRecName = "AxiRXTXSlave_$($axiName)"
        $ToMasterName = "AxiToMaster_$($axiName)"
        $fromMasterName = "AxiFromMaster_$($axiName)"
        $axifromMaster =  "$($axiName)_fromMaster"
        $axitoMaster = "$($axiName)_ToMaster"


$r = "library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all; 

  $(v_packet -name $packetName -entries (

        (v_subtype -name  $dataTypeNameFromMaster -type $DataTypeFromMaster -default $dataZeroFromMaster),
        (v_procedure -name resetData -argumentList "data : inout $($dataTypeNameFromMaster)" -body "data := $dataZeroFromMaster;"),


        (v_subtype -name  $dataTypeNameToMaster -type $DataTypeToMaster -default $dataZeroToMaster),
       

        
        (v_record -name $ToMasterName -entries (
          (v_member -name "TX_Ready" -type "AxiDataReady_t"),
          (v_member -name "RX_ctrl" -type "AxiCtrl"),
          (v_member -name "RX_Data" -type "$dataTypeNameToMaster")
        )),

        (v_record -name $fromMasterName -entries (
          (v_member -name "TX_ctrl" -type "AxiCtrl"),
          (v_member -name "TX_Data" -type "$dataTypeNameFromMaster"),
          (v_member -name "RX_Ready" -type "AxiDataReady_t")
        )),


        (axiClass -name $axifromMaster -type $dataTypeNameFromMaster),
        (axiClass -name $axitoMaster -type $dataTypeNameToMaster),
 
        (axiHandle -name $masterRecName -txClassName $axifromMaster -fromMasterName $fromMasterName -TxDataType $dataTypeNameFromMaster -RxClassName $axitoMaster -ToMasterName $ToMasterName -RxDataType $dataTypeNameToMaster),
        (axiHandle -name $slaveRecName -txClassName $axitoMaster -fromMasterName $fromMasterName -TxDataType $dataTypeNameToMaster -RxClassName $axifromMaster -ToMasterName $ToMasterName -RxDataType $dataTypeNameFromMaster -Slave)




    

))"
return $r
}