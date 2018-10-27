library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;

package axiStreamHelper is


  subtype data_t is integer;
  subtype size_t is integer ;

  type AxiData is record
    Data      : data_t;
    DataValid : sl;
    DataLast  : sl;
  end record AxiData;

  subtype AxiDataReady_t is std_logic;  
  
  type AxiStream is record
    data  : AxiData;
    Ready : AxiDataReady_t;
	 Ready0 : AxiDataReady_t;
    Ready1 : AxiDataReady_t;
    pos   :  size_t ;
    call_pos :  size_t;
  end record AxiStream;
  
  
end axiStreamHelper;