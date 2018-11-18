library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use work.UtilityPkg.all;
  use STD.textio.all;

package text_io_export_csv is

  constant NUM_COL : integer := 30;
  constant Integer_width : integer := 5;

  type csv_exp_file is record
    data_vecotor_buffer  : t_integer_array(NUM_COL downto 0);
    lineBuffer : line ;
    Index : integer ;
    IsOpen : STD_LOGIC;
    columns: integer;
  end record;


  procedure csv_openFile(variable csv : inout csv_exp_file ; file F: Text; FileName :  string; Header : string; NumOfcolumns : integer := NUM_COL);
  procedure csv_close( csv : inout csv_exp_file; file F: Text);
  procedure csv_reset(csv :inout csv_exp_file);
  procedure csv_set(csv : inout csv_exp_file ; index : in integer ; data :in integer);
  procedure csv_write(csv : inout csv_exp_file; file F: Text);
  function csv_isOpen(csv : csv_exp_file) return boolean;
end text_io_export_csv;

package body text_io_export_csv is
  procedure csv_openFile(variable csv : inout csv_exp_file ; file F: Text; FileName :  string; Header : string; NumOfcolumns : integer := NUM_COL) is begin
    --      csv_reset(csv);
    csv.columns := NumOfcolumns;
    file_open(F, FileName,  write_mode); 
    WRITE(csv.lineBuffer,Header,right, Integer_width);
    writeline(F, csv.lineBuffer);
    csv.IsOpen := '1';

  end csv_openFile;

  procedure csv_reset(csv :inout csv_exp_file) is begin
    csv.columns := NUM_COL;
    csv.data_vecotor_buffer := (others => 0) ;
    csv.IsOpen := '0';
    csv.Index := 0;
  end csv_reset;

  procedure csv_close( csv : inout csv_exp_file; file F: Text) is begin
    file_close(F);
    csv_reset(csv);

  end csv_close;

  function csv_isOpen(csv : csv_exp_file) return boolean is begin
    return csv.IsOpen = '1';
  end;

  procedure csv_set(csv : inout csv_exp_file ; index : in integer ; data :in integer) is begin
    csv.data_vecotor_buffer(index) := data;

  end csv_set;
  procedure csv_write(csv : inout csv_exp_file ; file F: Text) is begin
    for i in 0 to csv.columns loop
      if i > 0 then 
        write(csv.lineBuffer,  "; " , right, 2);        
      end if;
      write(csv.lineBuffer,  csv.data_vecotor_buffer(i) , right, Integer_width);
    end loop;
    writeline(F, csv.lineBuffer);
  end csv_write;

end text_io_export_csv;