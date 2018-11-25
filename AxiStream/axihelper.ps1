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

    [string]GetRecord(){
     $ret ="
  subtype  $($this.dataTypeName) is $($this.dataType);

  
  type $($this.name) is record
    ctrl   : AxiCtrl;
    data   : $($this.dataTypeName);
    Ready  : AxiDataReady_t;
	Ready0 : AxiDataReady_t;
    Ready1 : AxiDataReady_t;
    pos    :  size_t ;
    call_pos :  size_t;
  end record $($this.name);

  "
  return $ret;
    }

    [string]MasterRecord(){
    
        $ret =  record -Name $this.masterRecName -recordBody "
        tx : $($this.name); 
        "
        return $ret;
    }
    [string]SlaveRecord(){
    
        $ret =  record -Name $this.slaveRecName -recordBody "
        rx : $($this.name); 
        "
        return $ret; 

    }

    [string]ToMasterRec(){
        $ret = record -Name $($this.ToMasterName) -recordBody "TX_Ready : AxiDataReady_t;"
        return $ret;

    }

    [string]FromMasterRec(){
        $ret =record  -Name $($this.fromMasterName) -recordBody "TX_ctrl  : AxiCtrl;
    TX_Data  : data_t;"
        return $ret;
    }
}

