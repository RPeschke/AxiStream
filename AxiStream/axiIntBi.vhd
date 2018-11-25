library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

  use work.axiStreamHelper.all; 

  package axiIntbi_p is
subtype  integerM_data_t is integerM;
constant integerM_data_t_null : integerM := 0; 
procedure reset(data : inout integerM_data_t);
subtype  IntegerS_data_t is IntegerS;
constant IntegerS_data_t_null : IntegerS := 0; 
procedure reset(data : inout IntegerS_data_t);

type AxiToMaster_axiIntBi is record 
TX_Ready : AxiDataReady_t; 
RX_ctrl : AxiCtrl; 
RX_Data : IntegerS_data_t; 

end record AxiToMaster_axiIntBi; 

constant  AxiToMaster_axiIntBi_null: AxiToMaster_axiIntBi := (TX_Ready => AxiDataReady_t_null,
RX_ctrl => AxiCtrl_null,
RX_Data => IntegerS_data_t_null);


type AxiFromMaster_axiIntBi is record 
TX_ctrl : AxiCtrl; 
TX_Data : integerM_data_t; 
RX_Ready : AxiDataReady_t; 

end record AxiFromMaster_axiIntBi; 

constant  AxiFromMaster_axiIntBi_null: AxiFromMaster_axiIntBi := (TX_ctrl => AxiCtrl_null,
TX_Data => integerM_data_t_null,
RX_Ready => AxiDataReady_t_null);



-- Starting Pseudo class axiIntBi_fromMaster
 
type axiIntBi_fromMaster is record 
ctrl : AxiCtrl; 
data : integerM_data_t; 
Ready : AxiDataReady_t; 
Ready0 : AxiDataReady_t; 
Ready1 : AxiDataReady_t; 
position : size_t; 

end record axiIntBi_fromMaster; 

constant  axiIntBi_fromMaster_null: axiIntBi_fromMaster := (ctrl => AxiCtrl_null,
data => integerM_data_t_null,
Ready => AxiDataReady_t_null,
Ready0 => AxiDataReady_t_null,
Ready1 => AxiDataReady_t_null,
position => size_t_null);

 procedure resetSender(this : inout axiIntBi_fromMaster);
 procedure pullSender(this : inout axiIntBi_fromMaster; tx_ready : in AxiDataReady_t);
 procedure pushSender(this : inout axiIntBi_fromMaster; signal TX_Data : out integerM_data_t; signal DataLast: out sl; signal DataValid: out sl);
 procedure IncrementPosSender(this : inout axiIntBi_fromMaster);
 procedure ResetReceiver(this : inout axiIntBi_fromMaster);
 procedure pullReceiver(this : inout axiIntBi_fromMaster; RX_Data : in integerM_data_t; DataLast : in sl; DataValid : in sl);
 procedure pushReceiver(this : inout axiIntBi_fromMaster; RX_Ready : out AxiDataReady_t);
 procedure IncrementPosReceiver(this : inout axiIntBi_fromMaster);
 function  IsReady(this : in axiIntBi_fromMaster) return boolean;
 function  wasReady(this : in axiIntBi_fromMaster) return boolean;
 function  IsValid(this : in axiIntBi_fromMaster) return boolean;
 function  isLast(this : in axiIntBi_fromMaster) return boolean;
 procedure SetValid(this : inout axiIntBi_fromMaster; valid : in sl := '1');
 procedure SetLast(this : inout axiIntBi_fromMaster; last : in sl := '1');
 procedure SetData(this : inout axiIntBi_fromMaster; data : in integerM_data_t);
 -- End Pseudo class axiIntBi_fromMaster



-- Starting Pseudo class axiIntBi_ToMaster
 
type axiIntBi_ToMaster is record 
ctrl : AxiCtrl; 
data : IntegerS_data_t; 
Ready : AxiDataReady_t; 
Ready0 : AxiDataReady_t; 
Ready1 : AxiDataReady_t; 
position : size_t; 

end record axiIntBi_ToMaster; 

constant  axiIntBi_ToMaster_null: axiIntBi_ToMaster := (ctrl => AxiCtrl_null,
data => IntegerS_data_t_null,
Ready => AxiDataReady_t_null,
Ready0 => AxiDataReady_t_null,
Ready1 => AxiDataReady_t_null,
position => size_t_null);

 procedure resetSender(this : inout axiIntBi_ToMaster);
 procedure pullSender(this : inout axiIntBi_ToMaster; tx_ready : in AxiDataReady_t);
 procedure pushSender(this : inout axiIntBi_ToMaster; signal TX_Data : out IntegerS_data_t; signal DataLast: out sl; signal DataValid: out sl);
 procedure IncrementPosSender(this : inout axiIntBi_ToMaster);
 procedure ResetReceiver(this : inout axiIntBi_ToMaster);
 procedure pullReceiver(this : inout axiIntBi_ToMaster; RX_Data : in IntegerS_data_t; DataLast : in sl; DataValid : in sl);
 procedure pushReceiver(this : inout axiIntBi_ToMaster; RX_Ready : out AxiDataReady_t);
 procedure IncrementPosReceiver(this : inout axiIntBi_ToMaster);
 function  IsReady(this : in axiIntBi_ToMaster) return boolean;
 function  wasReady(this : in axiIntBi_ToMaster) return boolean;
 function  IsValid(this : in axiIntBi_ToMaster) return boolean;
 function  isLast(this : in axiIntBi_ToMaster) return boolean;
 procedure SetValid(this : inout axiIntBi_ToMaster; valid : in sl := '1');
 procedure SetLast(this : inout axiIntBi_ToMaster; last : in sl := '1');
 procedure SetData(this : inout axiIntBi_ToMaster; data : in IntegerS_data_t);
 -- End Pseudo class axiIntBi_ToMaster



-- Starting Pseudo class AxiRXTXMaster_axiIntBi
 
type AxiRXTXMaster_axiIntBi is record 
tx : axiIntBi_fromMaster; 
rx : axiIntBi_ToMaster; 

end record AxiRXTXMaster_axiIntBi; 

constant  AxiRXTXMaster_axiIntBi_null: AxiRXTXMaster_axiIntBi := (tx => axiIntBi_fromMaster_null,
rx => axiIntBi_ToMaster_null);

 procedure AxiPullData(this : inout AxiRXTXMaster_axiIntBi; signal tMaster : in AxiToMaster_axiIntBi);
 procedure AxiPushData(this : inout AxiRXTXMaster_axiIntBi; signal fromMaster : out AxiFromMaster_axiIntBi);
 function  txIsReady(this : in AxiRXTXMaster_axiIntBi) return boolean;
 procedure txSetData(this : inout AxiRXTXMaster_axiIntBi; data : in integerM_data_t);
 procedure txSetLast(this : inout AxiRXTXMaster_axiIntBi);
 function  txIsLast(this : in AxiRXTXMaster_axiIntBi) return boolean;
 function  txIsValid(this : in AxiRXTXMaster_axiIntBi) return boolean;
 function  txGetData(this : in AxiRXTXMaster_axiIntBi) return integerM_data_t;
 function  rxIsValidAndReady(this : in AxiRXTXMaster_axiIntBi) return boolean;
 function  rxGetData(this : in AxiRXTXMaster_axiIntBi) return IntegerS_data_t;
 procedure rxSetReady(this : inout AxiRXTXMaster_axiIntBi);
 -- End Pseudo class AxiRXTXMaster_axiIntBi



-- Starting Pseudo class AxiRXTXSlave_axiIntBi
 
type AxiRXTXSlave_axiIntBi is record 
RX : axiIntBi; 

end record AxiRXTXSlave_axiIntBi; 

constant  AxiRXTXSlave_axiIntBi_null: AxiRXTXSlave_axiIntBi := (RX => axiIntBi_null);

 procedure AxiPullData(this : inout AxiRXTXSlave_axiIntBi; signal fromMaster : in AxiFromMaster_axiIntBi);
 procedure AxiTxIncrementPos(this : inout AxiRXTXSlave_axiIntBi);
 procedure AxiPushData(this : inout AxiRXTXSlave_axiIntBi; signal toMaster : out AxiToMaster_axiIntBi);
 function  rxIsDataReady(this : in AxiRXTXSlave_axiIntBi) return boolean;
 function  rxGetPosition(this : in AxiRXTXSlave_axiIntBi) return size_t;
 procedure rxSetDataReady(this : inout AxiRXTXSlave_axiIntBi);
 function  rxGetData(this : in AxiRXTXSlave_axiIntBi) return size_t;
 function  rxIsLast(this : in AxiRXTXSlave_axiIntBi) return boolean;
 function  rxIsValid(this : in AxiRXTXSlave_axiIntBi) return boolean;
 function  rxIsValidAndReady(this : in AxiRXTXSlave_axiIntBi) return boolean;
 function  rxIsPosition(this : in AxiRXTXSlave_axiIntBi; position :size_t) return boolean;
 procedure rxPullData(this : inout AxiRXTXSlave_axiIntBi; data :out ; position :in size_t);
 procedure rxPullData(this : inout AxiRXTXSlave_axiIntBi; data :out );
 procedure AxiReset(this : inout AxiRXTXSlave_axiIntBi);
 -- End Pseudo class AxiRXTXSlave_axiIntBi

end axiIntbi_p;


package body axiIntbi_p is
procedure reset(data : inout integerM_data_t) is begin 
data := 0; 
end procedure reset; 

procedure reset(data : inout IntegerS_data_t) is begin 
data := 0; 
end procedure reset; 



-- Starting Pseudo class axiIntBi_fromMaster
  procedure resetSender(this : inout axiIntBi_fromMaster) is begin 

            reset(this.Data);
            this.ctrl.DataLast  := '0';
            this.ctrl.DataValid := '0';
          
end procedure resetSender; 

 procedure pullSender(this : inout axiIntBi_fromMaster; tx_ready : in AxiDataReady_t) is begin 

            this.Ready1 := this.Ready0;   
            this.Ready0 := this.Ready;
  	        this.ready :=tx_ready;
            resetSender(this);
          
end procedure pullSender; 

 procedure pushSender(this : inout axiIntBi_fromMaster; signal TX_Data : out integerM_data_t; signal DataLast: out sl; signal DataValid: out sl) is begin 

            TX_Data  <= this.Data after 1 ns;
            DataLast <= this.ctrl.DataLast after 1 ns;
            DataValid <= this.ctrl.DataValid after 1 ns;
            IncrementPosSender(this);
          
end procedure pushSender; 

 procedure IncrementPosSender(this : inout axiIntBi_fromMaster) is begin 

            if IsValid(this) and IsReady(this) then 
              this.position := this.position + 1;
              if isLast(this) then
                this.position := 0;
              end if;
            end if;
          
end procedure IncrementPosSender; 

 procedure ResetReceiver(this : inout axiIntBi_fromMaster) is begin 

            this.Ready    := '0';
            this.call_pos := 0;
           
end procedure ResetReceiver; 

 procedure pullReceiver(this : inout axiIntBi_fromMaster; RX_Data : in integerM_data_t; DataLast : in sl; DataValid : in sl) is begin 

            this.Ready1 := this.Ready0;
            this.Ready0 := this.Ready;
            this.Data  := RX_Data;
            this.ctrl.DataLast  := DataLast;
            this.ctrl.DataValid := DataValid;

            ResetReceiver(this);
           
end procedure pullReceiver; 

 procedure pushReceiver(this : inout axiIntBi_fromMaster; RX_Ready : out AxiDataReady_t) is begin 

            fromMaster.RX_Ready <= this.Ready after 1 ns;
            AxiRxIncrementPos(this);
           
end procedure pushReceiver; 

 procedure IncrementPosReceiver(this : inout axiIntBi_fromMaster) is begin 

             if rxIsValidAndReady(this) then 
                this.position := this.position + 1;
                if isLast(this) then
                    this.position := 0;
                end if;
             end if;
           
end procedure IncrementPosReceiver; 

 function  IsReady(this : in axiIntBi_fromMaster) return boolean is begin 

             return this.Ready = '1';
           
end function IsReady; 

 function  wasReady(this : in axiIntBi_fromMaster) return boolean is begin 

            return this.Ready1 = '1';
           
end function wasReady; 

 function  IsValid(this : in axiIntBi_fromMaster) return boolean is begin 

             return this.ctrl.DataValid = '1';
           
end function IsValid; 

 function  isLast(this : in axiIntBi_fromMaster) return boolean is begin 

            return this.ctrl.DataLast = '1';
           
end function isLast; 

 procedure SetValid(this : inout axiIntBi_fromMaster; valid : in sl := '1') is begin 

            if not IsReady(this) then 
                report "Error receiver not ready";
            end if;
            this.ctrl.DataValid := valid;
           
end procedure SetValid; 

 procedure SetLast(this : inout axiIntBi_fromMaster; last : in sl := '1') is begin 

            if not IsValid(this) then 
                report "Error data not set";
            end if;
            this.tx.ctrl.DataLast := last;
          
end procedure SetLast; 

 procedure SetData(this : inout axiIntBi_fromMaster; data : in integerM_data_t) is begin 

            if not IsReady(this) then 
                report "Error slave is not ready";
            end if;
            if IsValid(this) then 
                report "Error data already set";
            end if;
            this.tx.Data := data;
            SetValid(this);
          
end procedure SetData; 

 -- End Pseudo class axiIntBi_fromMaster



-- Starting Pseudo class axiIntBi_ToMaster
  procedure resetSender(this : inout axiIntBi_ToMaster) is begin 

            reset(this.Data);
            this.ctrl.DataLast  := '0';
            this.ctrl.DataValid := '0';
          
end procedure resetSender; 

 procedure pullSender(this : inout axiIntBi_ToMaster; tx_ready : in AxiDataReady_t) is begin 

            this.Ready1 := this.Ready0;   
            this.Ready0 := this.Ready;
  	        this.ready :=tx_ready;
            resetSender(this);
          
end procedure pullSender; 

 procedure pushSender(this : inout axiIntBi_ToMaster; signal TX_Data : out IntegerS_data_t; signal DataLast: out sl; signal DataValid: out sl) is begin 

            TX_Data  <= this.Data after 1 ns;
            DataLast <= this.ctrl.DataLast after 1 ns;
            DataValid <= this.ctrl.DataValid after 1 ns;
            IncrementPosSender(this);
          
end procedure pushSender; 

 procedure IncrementPosSender(this : inout axiIntBi_ToMaster) is begin 

            if IsValid(this) and IsReady(this) then 
              this.position := this.position + 1;
              if isLast(this) then
                this.position := 0;
              end if;
            end if;
          
end procedure IncrementPosSender; 

 procedure ResetReceiver(this : inout axiIntBi_ToMaster) is begin 

            this.Ready    := '0';
            this.call_pos := 0;
           
end procedure ResetReceiver; 

 procedure pullReceiver(this : inout axiIntBi_ToMaster; RX_Data : in IntegerS_data_t; DataLast : in sl; DataValid : in sl) is begin 

            this.Ready1 := this.Ready0;
            this.Ready0 := this.Ready;
            this.Data  := RX_Data;
            this.ctrl.DataLast  := DataLast;
            this.ctrl.DataValid := DataValid;

            ResetReceiver(this);
           
end procedure pullReceiver; 

 procedure pushReceiver(this : inout axiIntBi_ToMaster; RX_Ready : out AxiDataReady_t) is begin 

            fromMaster.RX_Ready <= this.Ready after 1 ns;
            AxiRxIncrementPos(this);
           
end procedure pushReceiver; 

 procedure IncrementPosReceiver(this : inout axiIntBi_ToMaster) is begin 

             if rxIsValidAndReady(this) then 
                this.position := this.position + 1;
                if isLast(this) then
                    this.position := 0;
                end if;
             end if;
           
end procedure IncrementPosReceiver; 

 function  IsReady(this : in axiIntBi_ToMaster) return boolean is begin 

             return this.Ready = '1';
           
end function IsReady; 

 function  wasReady(this : in axiIntBi_ToMaster) return boolean is begin 

            return this.Ready1 = '1';
           
end function wasReady; 

 function  IsValid(this : in axiIntBi_ToMaster) return boolean is begin 

             return this.ctrl.DataValid = '1';
           
end function IsValid; 

 function  isLast(this : in axiIntBi_ToMaster) return boolean is begin 

            return this.ctrl.DataLast = '1';
           
end function isLast; 

 procedure SetValid(this : inout axiIntBi_ToMaster; valid : in sl := '1') is begin 

            if not IsReady(this) then 
                report "Error receiver not ready";
            end if;
            this.ctrl.DataValid := valid;
           
end procedure SetValid; 

 procedure SetLast(this : inout axiIntBi_ToMaster; last : in sl := '1') is begin 

            if not IsValid(this) then 
                report "Error data not set";
            end if;
            this.tx.ctrl.DataLast := last;
          
end procedure SetLast; 

 procedure SetData(this : inout axiIntBi_ToMaster; data : in IntegerS_data_t) is begin 

            if not IsReady(this) then 
                report "Error slave is not ready";
            end if;
            if IsValid(this) then 
                report "Error data already set";
            end if;
            this.tx.Data := data;
            SetValid(this);
          
end procedure SetData; 

 -- End Pseudo class axiIntBi_ToMaster



-- Starting Pseudo class AxiRXTXMaster_axiIntBi
  procedure AxiPullData(this : inout AxiRXTXMaster_axiIntBi; signal tMaster : in AxiToMaster_axiIntBi) is begin 

            pullSender(this.tx, tMaster.tx_ready);
            pullReceiver(this.rx, tMaster.RX_Data ,tMaster.RX_ctrl.DataLast,  tMaster.RX_ctrl.DataValid);

           
end procedure AxiPullData; 

 procedure AxiPushData(this : inout AxiRXTXMaster_axiIntBi; signal fromMaster : out AxiFromMaster_axiIntBi) is begin 

            pushSender(this.tx, fromMaster.TX_Data ,fromMaster.TX_ctrl.DataLast,fromMaster.TX_ctrl.DataValid );
            pushReceiver(this.rx, fromMaster.RX_Ready);
           
end procedure AxiPushData; 

 function  txIsReady(this : in AxiRXTXMaster_axiIntBi) return boolean is begin 

             return IsReady(this.tx);
          
end function txIsReady; 

 procedure txSetData(this : inout AxiRXTXMaster_axiIntBi; data : in integerM_data_t) is begin 

            SetData(this.tx, data);
          
end procedure txSetData; 

 procedure txSetLast(this : inout AxiRXTXMaster_axiIntBi) is begin 

            SetLast(this.tx);
          
end procedure txSetLast; 

 function  txIsLast(this : in AxiRXTXMaster_axiIntBi) return boolean is begin 

            return this.tx.ctrl.DataLast = '1';
          
end function txIsLast; 

 function  txIsValid(this : in AxiRXTXMaster_axiIntBi) return boolean is begin 

            return this.tx.ctrl.DataValid = '1';
          
end function txIsValid; 

 function  txGetData(this : in AxiRXTXMaster_axiIntBi) return integerM_data_t is begin 

            return this.tx.Data;
          
end function txGetData; 

 function  rxIsValidAndReady(this : in AxiRXTXMaster_axiIntBi) return boolean is begin 

            return IsValid(this.rx) and wasReady(this.rx);  
          
end function rxIsValidAndReady; 

 function  rxGetData(this : in AxiRXTXMaster_axiIntBi) return IntegerS_data_t is begin 

            if not rxIsValidAndReady(this) then 
              report "Error data already set";
            end if;
            return this.rx.data;
          
end function rxGetData; 

 procedure rxSetReady(this : inout AxiRXTXMaster_axiIntBi) is begin 

            this.rx.Ready := '1';
          
end procedure rxSetReady; 

 -- End Pseudo class AxiRXTXMaster_axiIntBi



-- Starting Pseudo class AxiRXTXSlave_axiIntBi
  procedure AxiPullData(this : inout AxiRXTXSlave_axiIntBi; signal fromMaster : in AxiFromMaster_axiIntBi) is begin 

            this.RX.Ready1 := this.Rx.Ready0;
            this.RX.Ready0 := this.Rx.Ready;
            this.Rx.Data  := fromMaster.TX_Data;
            this.Rx.ctrl.DataLast  := fromMaster.TX_ctrl.DataLast;
            this.Rx.ctrl.DataValid := fromMaster.TX_ctrl.DataValid;
            AxiReset(this);
         
end procedure AxiPullData; 

 procedure AxiTxIncrementPos(this : inout AxiRXTXSlave_axiIntBi) is begin 

             if rxIsValidAndReady(this) then 
                this.rx.position := this.rx.position + 1;
                if rxIsLast(this) then
                    this.rx.position := 0;
                end if;
             end if;
         
end procedure AxiTxIncrementPos; 

 procedure AxiPushData(this : inout AxiRXTXSlave_axiIntBi; signal toMaster : out AxiToMaster_axiIntBi) is begin 

            toMaster.TX_Ready <= this.rx.Ready after 1 ns;
            AxiTxIncrementPos(this);
          
end procedure AxiPushData; 

 function  rxIsDataReady(this : in AxiRXTXSlave_axiIntBi) return boolean is begin 

            return this.rx.Ready1 = '1';
          
end function rxIsDataReady; 

 function  rxGetPosition(this : in AxiRXTXSlave_axiIntBi) return size_t is begin 

            return this.rx.position;
          
end function rxGetPosition; 

 procedure rxSetDataReady(this : inout AxiRXTXSlave_axiIntBi) is begin 

            this.rx.Ready := '1';
          
end procedure rxSetDataReady; 

 function  rxGetData(this : in AxiRXTXSlave_axiIntBi) return size_t is begin 

            return this.rx.data;
          
end function rxGetData; 

 function  rxIsLast(this : in AxiRXTXSlave_axiIntBi) return boolean is begin 

            return this.rx.ctrl.DataLast = '1';
          
end function rxIsLast; 

 function  rxIsValid(this : in AxiRXTXSlave_axiIntBi) return boolean is begin 

            return this.rx.ctrl.DataValid = '1';
          
end function rxIsValid; 

 function  rxIsValidAndReady(this : in AxiRXTXSlave_axiIntBi) return boolean is begin 

            return rxIsValid(this) and this.rx.Ready1 = '1';  
          
end function rxIsValidAndReady; 

 function  rxIsPosition(this : in AxiRXTXSlave_axiIntBi; position :size_t) return boolean is begin 

            return rxIsValidAndReady(this) and rxGetPosition(this) = position;
          
end function rxIsPosition; 

 procedure rxPullData(this : inout AxiRXTXSlave_axiIntBi; data :out ; position :in size_t) is begin 

            if rxIsPosition(this, position) then 
                data := this.rx.Data;
            end if; 
            this.rx.call_pos := this.rx.call_pos + 1;
           
end procedure rxPullData; 

 procedure rxPullData(this : inout AxiRXTXSlave_axiIntBi; data :out ) is begin 

            rxPullData(this ,data,this.rx.call_pos);
           
end procedure rxPullData; 

 procedure AxiReset(this : inout AxiRXTXSlave_axiIntBi) is begin 

            this.rx.Ready    := '0';
            this.rx.call_pos := 0;
           
end procedure AxiReset; 

 -- End Pseudo class AxiRXTXSlave_axiIntBi

end package body axiIntbi_p;

