library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all; 

  package AxiInt_p is
subtype  AxiInt_data_t is integer;
procedure reset(data : inout AxiInt_data_t);

type AxiInt is record 
ctrl : AxiCtrl; 
data : AxiInt_data_t; 
Ready : AxiDataReady_t; 
Ready0 : AxiDataReady_t; 
Ready1 : AxiDataReady_t; 
pos : size_t; 
call_pos : size_t; 

end record AxiInt; 



type AxiToMaster_AxiInt is record 
TX_Ready : AxiDataReady_t; 

end record AxiToMaster_AxiInt; 



type AxiFromMaster_AxiInt is record 
TX_ctrl : AxiCtrl; 
TX_Data : AxiInt_data_t; 

end record AxiFromMaster_AxiInt; 




-- Starting Pseudo class AxiRXTXMaster_AxiInt
 
type AxiRXTXMaster_AxiInt is record 
tx : AxiInt; 

end record AxiRXTXMaster_AxiInt; 


 procedure AxiPullData(this : inout AxiRXTXMaster_AxiInt; signal tMaster : in AxiToMaster_AxiInt);
 procedure AxiTxIncrementPos(this : inout AxiRXTXMaster_AxiInt);
 procedure AxiPushData(this : inout AxiRXTXMaster_AxiInt; signal fromMaster : out AxiFromMaster_AxiInt);
 procedure txSetData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t);
 procedure txSetLast(this : inout AxiRXTXMaster_AxiInt; last : in sl := '1');
 procedure txPushData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t);
 procedure txPushData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t; position : in size_t);
 procedure txPushLast(this : inout AxiRXTXMaster_AxiInt);
 procedure txSetValid(this : inout AxiRXTXMaster_AxiInt; valid : in sl := '1');
 function  txIsLast(this : in AxiRXTXMaster_AxiInt) return boolean;
 function  txIsValid(this : in AxiRXTXMaster_AxiInt) return boolean;
 function  txGetData(this : in AxiRXTXMaster_AxiInt) return AxiInt_data_t;
 procedure AxiReset(this : inout AxiRXTXMaster_AxiInt);
 -- End Pseudo class AxiRXTXMaster_AxiInt



-- Starting Pseudo class AxiRXTXSlave_AxiInt
 
type AxiRXTXSlave_AxiInt is record 
RX : AxiInt; 

end record AxiRXTXSlave_AxiInt; 


 procedure AxiPullData(this : inout AxiRXTXSlave_AxiInt; signal fromMaster : in AxiFromMaster_AxiInt);
 procedure AxiTxIncrementPos(this : inout AxiRXTXSlave_AxiInt);
 procedure AxiPushData(this : inout AxiRXTXSlave_AxiInt; signal toMaster : out AxiToMaster_AxiInt);
 function  rxIsDataReady(this : in AxiRXTXSlave_AxiInt) return boolean;
 function  rxGetPosition(this : in AxiRXTXSlave_AxiInt) return size_t;
 procedure rxSetDataReady(this : inout AxiRXTXSlave_AxiInt);
 function  rxGetData(this : in AxiRXTXSlave_AxiInt) return size_t;
 function  rxIsLast(this : in AxiRXTXSlave_AxiInt) return boolean;
 function  rxIsValid(this : in AxiRXTXSlave_AxiInt) return boolean;
 function  rxIsValidAndReady(this : in AxiRXTXSlave_AxiInt) return boolean;
 function  rxIsPosition(this : in AxiRXTXSlave_AxiInt; position :size_t) return boolean;
 procedure rxPullData(this : inout AxiRXTXSlave_AxiInt; data :out AxiInt_data_t; position :in size_t);
 procedure rxPullData(this : inout AxiRXTXSlave_AxiInt; data :out AxiInt_data_t);
 procedure AxiReset(this : inout AxiRXTXSlave_AxiInt);
 -- End Pseudo class AxiRXTXSlave_AxiInt

end AxiInt_p;


package body AxiInt_p is
procedure reset(data : inout AxiInt_data_t) is begin 
data := 0; 
end procedure reset; 



-- Starting Pseudo class AxiRXTXMaster_AxiInt
  procedure AxiPullData(this : inout AxiRXTXMaster_AxiInt; signal tMaster : in AxiToMaster_AxiInt) is begin 

            this.tx.Ready1 := this.tx.Ready0;   
            this.tx.Ready0 := this.tx.Ready;
  	        this.tx.ready :=tMaster.tx_ready;
            reset(this.tx.Data);
            AxiReset(this);
          
end procedure AxiPullData; 

 procedure AxiTxIncrementPos(this : inout AxiRXTXMaster_AxiInt) is begin 

            if txIsValid(this) and txIsDataReady(this) then 
              this.tx.pos := this.tx.pos + 1;
              if txIsLast(this) then
                this.tx.pos := 0;
              end if;
            end if;
          
end procedure AxiTxIncrementPos; 

 procedure AxiPushData(this : inout AxiRXTXMaster_AxiInt; signal fromMaster : out AxiFromMaster_AxiInt) is begin 

            fromMaster.TX_Data  <= this.tx.Data after 1 ns;
            fromMaster.TX_ctrl.DataLast <= this.tx.ctrl.DataLast after 1 ns;
            fromMaster.TX_ctrl.DataValid <= this.tx.ctrl.DataValid after 1 ns;
            AxiTxIncrementPos(this);
          
end procedure AxiPushData; 

 procedure txSetData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t) is begin 

            if not txIsDataReady(this) then 
                report  
end procedure txSetData; 

 procedure txSetLast(this : inout AxiRXTXMaster_AxiInt; last : in sl := '1') is begin 

            if not txIsValid(this) then 
                report  
end procedure txSetLast; 

 procedure txPushData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t) is begin 

            txPushData(this, data, this.tx.call_pos);
           
end procedure txPushData; 

 procedure txPushData(this : inout AxiRXTXMaster_AxiInt; data : in AxiInt_data_t; position : in size_t) is begin 

            if position = this.tx.pos then  
                txSetData(this, data);
            end if;
            this.tx.call_pos := position +1;
          
end procedure txPushData; 

 procedure txPushLast(this : inout AxiRXTXMaster_AxiInt) is begin 

            if this.tx.call_pos = this.tx.pos+1 then  
                txSetLast(this);
            end if;
            this.tx.call_pos := this.tx.call_pos +1;
          
end procedure txPushLast; 

 procedure txSetValid(this : inout AxiRXTXMaster_AxiInt; valid : in sl := '1') is begin 

            this.tx.ctrl.DataValid := valid;
          
end procedure txSetValid; 

 function  txIsLast(this : in AxiRXTXMaster_AxiInt) return boolean is begin 

            return this.tx.ctrl.DataLast = '1';
          
end function txIsLast; 

 function  txIsValid(this : in AxiRXTXMaster_AxiInt) return boolean is begin 

            return this.tx.ctrl.DataValid = '1';
          
end function txIsValid; 

 function  txGetData(this : in AxiRXTXMaster_AxiInt) return AxiInt_data_t is begin 

            return this.tx.Data;
          
end function txGetData; 

 procedure AxiReset(this : inout AxiRXTXMaster_AxiInt) is begin 

            this.tx.call_pos := 0;
            this.tx.ctrl.DataLast  := '0';
            this.tx.ctrl.DataValid := '0';
          
end procedure AxiReset; 

 -- End Pseudo class AxiRXTXMaster_AxiInt



-- Starting Pseudo class AxiRXTXSlave_AxiInt
  procedure AxiPullData(this : inout AxiRXTXSlave_AxiInt; signal fromMaster : in AxiFromMaster_AxiInt) is begin 

            this.RX.Ready1 := this.Rx.Ready0;
            this.RX.Ready0 := this.Rx.Ready;
            this.Rx.Data  := fromMaster.TX_Data;
            this.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
            this.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
            AxiReset(this);
         
end procedure AxiPullData; 

 procedure AxiTxIncrementPos(this : inout AxiRXTXSlave_AxiInt) is begin 

             if rxIsValidAndReady(this) then 
                this.rx.pos := this.rx.pos + 1;
                if rxIsLast(this) then
                    this.rx.pos := 0;
                end if;
             end if;
         
end procedure AxiTxIncrementPos; 

 procedure AxiPushData(this : inout AxiRXTXSlave_AxiInt; signal toMaster : out AxiToMaster_AxiInt) is begin 

            toMaster.TX_Ready <= this.rx.Ready after 1 ns;
            AxiTxIncrementPos(this);
          
end procedure AxiPushData; 

 function  rxIsDataReady(this : in AxiRXTXSlave_AxiInt) return boolean is begin 

            return this.rx.Ready1 = '1';
          
end function rxIsDataReady; 

 function  rxGetPosition(this : in AxiRXTXSlave_AxiInt) return size_t is begin 

            return this.rx.pos;
          
end function rxGetPosition; 

 procedure rxSetDataReady(this : inout AxiRXTXSlave_AxiInt) is begin 

            this.rx.Ready := '1';
          
end procedure rxSetDataReady; 

 function  rxGetData(this : in AxiRXTXSlave_AxiInt) return size_t is begin 

            return this.rx.data;
          
end function rxGetData; 

 function  rxIsLast(this : in AxiRXTXSlave_AxiInt) return boolean is begin 

            return this.rx.ctrl.DataLast = '1';
          
end function rxIsLast; 

 function  rxIsValid(this : in AxiRXTXSlave_AxiInt) return boolean is begin 

            return this.rx.ctrl.DataValid = '1';
          
end function rxIsValid; 

 function  rxIsValidAndReady(this : in AxiRXTXSlave_AxiInt) return boolean is begin 

            return rxIsValid(this) and this.rx.Ready1 = '1';  
          
end function rxIsValidAndReady; 

 function  rxIsPosition(this : in AxiRXTXSlave_AxiInt; position :size_t) return boolean is begin 

            return rxIsValidAndReady(this) and rxGetPosition(this) = position;
          
end function rxIsPosition; 

 procedure rxPullData(this : inout AxiRXTXSlave_AxiInt; data :out AxiInt_data_t; position :in size_t) is begin 

            if rxIsPosition(this, position) then 
                data := this.rx.Data;
            end if; 
            this.rx.call_pos := this.rx.call_pos + 1;
           
end procedure rxPullData; 

 procedure rxPullData(this : inout AxiRXTXSlave_AxiInt; data :out AxiInt_data_t) is begin 

            rxPullData(this ,data,this.rx.call_pos);
           
end procedure rxPullData; 

 procedure AxiReset(this : inout AxiRXTXSlave_AxiInt) is begin 

            this.rx.Ready    := '0';
            this.rx.call_pos := 0;
           
end procedure AxiReset; 

 -- End Pseudo class AxiRXTXSlave_AxiInt

end package body AxiInt_p;

