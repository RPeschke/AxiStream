
function axiClass($name,$type,$DoUse){
    if($DoUse -eq $false){
        $ret = make_packet_entry
        return $ret
    }

    $ret =  (v_class -name $name  -entries (

         (v_member -name "DataValid"     -type "sl"  -out),
         (v_member -name "DataLast"     -type "sl" -out),
         (v_member -name "data"     -type "$type" -out),
         (v_member -name "Ready"    -type "AxiDataReady_t" -internal),
         (v_member -name "Ready0"   -type "AxiDataReady_t" -internal),
         (v_member -name "Ready1"   -type "AxiDataReady_t" -internal),
         (v_member -name "position" -type "size_t" -internal),
         (v_procedure -name resetSender -body "
            resetData(this.Data);
            this.ctrl.DataLast  := '0';
            this.ctrl.DataValid := '0';
         "),
         (v_procedure -name pullSender -argumentList "tx_ready : in AxiDataReady_t" -body "
            this.Ready1 := this.Ready0;   
            this.Ready0 := this.Ready;
  	        this.ready :=tx_ready;
            $($name)_IncrementPosSender(this);
            
         "),
         (v_procedure -name pushSender -argumentList "signal TX_Data : out $type; signal DataLast: out sl; signal DataValid: out sl" -body "
            TX_Data  <= this.Data after 1 ns;
            DataLast <= this.ctrl.DataLast after 1 ns;
            DataValid <= this.ctrl.DataValid after 1 ns;
         
         "),

         (v_procedure -name "$($name)_IncrementPosSender" -body "
            if IsValid(this) and IsReady(this) then 
              this.position := this.position + 1;
             

              if isLast(this) then
                this.position := 0;
              end if;
              resetSender(this);
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
            IncrementPosReceiver(this);
            ResetReceiver(this);
          "),
         (v_procedure -name pushReceiver -argumentList "signal RX_Ready : out AxiDataReady_t" -body  "
            RX_Ready <= this.Ready after 1 ns;
            
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
            return this.Ready0 = '1';
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
