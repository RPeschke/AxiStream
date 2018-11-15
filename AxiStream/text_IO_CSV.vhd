--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
  use work.UtilityPkg.all;
  use STD.textio.all;
  
package text_IO_CSV is

constant NUM_COL : integer := 3;
	
type csv_file is record
	 data_vecotor_buffer  : t_integer_array(1 to NUM_COL);
	 lineBuffer : line ;
	 
end record;
 

function csv_get  (csv  : in csv_file; index  : in integer) return integer;
procedure csv_readLine (variable csv  : inout csv_file; file F: TEXT);


end text_IO_CSV;

package body text_IO_CSV is

function csv_get  (csv  : in csv_file; index  : in integer) return integer is begin
return csv.data_vecotor_buffer(index);
end csv_get;

procedure csv_readLine (variable csv  : inout csv_file; file F: TEXT) is begin
	readline(F, csv.lineBuffer);
	for i in 1 to NUM_COL loop
		read(csv.lineBuffer,csv.data_vecotor_buffer(i));
	end loop;
	
end csv_readLine;


---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end text_IO_CSV;
