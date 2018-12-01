
function axiClass($prefixName,$type,$classIn, $DoUse, [switch]$ReversInOut){
$const = getConstants -ReversInOut $ReversInOut

if($ReversInOut){
 $classIn.MasterBeforePull ="this.$($prefixName)_Ready0 := this.$($prefixName)_Ready;"
 $classIn.SlaveAfterPull  ="$($prefixName)_IncrementPosSender(this);"
 #$classIn.MasterAfterPull = "$($prefixName)_IncrementPosReceiver(this);"
}else{
 $classIn.SlaveBeforePull="this.$($prefixName)_Ready0 := this.$($prefixName)_Ready;"
 $classIn.MasterAfterPull  ="$($prefixName)_IncrementPosSender(this);"
 #$classIn.SlaveAfterPull = "$($prefixName)_IncrementPosReceiver(this);"
}
    if($DoUse -eq $false){
        return
    }

    $classIn.append((v_member -name "$($prefixName)_DataValid"    -type "sl"     -InOut $const.Out ))
    $classIn.append((v_member -name "$($prefixName)_DataLast"     -type "sl"     -InOut $const.Out))
    $classIn.append((v_member -name "$($prefixName)_data"         -type "$type"  -InOut $const.Out))
    $classIn.append((v_member -name "$($prefixName)_Ready"        -type "sl"     -InOut $const.In ))
    $classIn.append((v_member -name "$($prefixName)_Ready0"       -type "sl"     -InOut $const.InternalSlave ))
    #$classIn.append((v_member -name "$($prefixName)_Ready1"       -type "sl"     -InOut $const.Internal ))
    $classIn.append((v_member -name "$($prefixName)_position"     -type "size_t" -InOut $const.Internal ))
         
    $classIn.append((v_procedure -name "$($prefixName)_IncrementPosSender" -masterSlave $const.Master -body "
            if this.$($prefixName)_DataValid = '1' and this.$($prefixName)_Ready = '1' then 
              this.$($prefixName)_position := this.$($prefixName)_position + 1;
             

              if this.$($prefixName)_DataLast = '1' then
                this.$($prefixName)_position := 0;
              end if;

              this.$($prefixName)_Data  := $(v_record_null -Name $type);
              this.$($prefixName)_DataLast  := '0';
              this.$($prefixName)_DataValid := '0';

            end if;
         "))
  

    $classIn.append((v_procedure -name "$($prefixName)_IncrementPosReceiver" -masterSlave $const.Slave -body "
             if this.$($prefixName)_DataValid = '1' and  this.$($prefixName)_Ready0 ='1' then 
                this.$($prefixName)_position := this.$($prefixName)_position + 1;
                if this.$($prefixName)_DataLast = '1' then
                    this.$($prefixName)_position := 0;
                end if;
             end if;
             this.$($prefixName)_Ready    := '0';
          "))

      $classIn.append((v_function -name ready2Send -returnType boolean -masterSlave $const.Master -body "
            return this.$($prefixName)_DataValid = '0';
          "))

    $classIn.append((v_procedure -name sendData -argumentList "data : in $($type)" -masterSlave $const.Master -body "
          
            if this.$($prefixName)_DataValid = '1' then 
                report `"Error data already set`";
            end if;
            this.$($prefixName)_data := data;
            this.$($prefixName)_DataValid := '1';
          "))

    $classIn.append((v_procedure -name setReady -masterSlave $const.Slave -body "
             this.$($prefixName)_Ready := '1';
          "))
     $classIn.append((v_procedure -name sendLast -masterSlave $const.Master -body "
             this.$($prefixName)_DataLast := '1';
          "))

    $classIn.append((v_function -name HasReceivedData -returnType boolean -masterSlave $const.Slave -body "
            return this.$($prefixName)_DataValid = '0' and this.$($prefixName)_Ready0 ='1';
          "))

    $classIn.append((v_function -name HasReceivedLast -returnType boolean -masterSlave $const.Slave -body "
            return this.$($prefixName)_DataLast = '0';
          "))

    $classIn.append((v_function -name ReceivedData -returnType $type -masterSlave $const.Slave -body "
            return this.$($prefixName)_data;
          "))

    $classIn.append((v_function -name receivePosition  -returnType "size_t" -masterSlave $const.Slave  -body "
            return this.$($prefixName)_position;
    "))

    $classIn.append((v_function -name sendPosition  -returnType "size_t" -masterSlave $const.Master -body "
            return this.$($prefixName)_position;
    "))
}

$x = v_class -name axi

  (axiClass -prefixName TX -type integer -classIn $x ),
  (axiClass -prefixName RX -type integer -classIn $x -ReversInOut)
$r = "library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all; 

  $(v_packet -name axi_int_bi -entries ($x.getEntries()))"