import os
path = os.getcwd()

with open('make.sh','w') as f:
    f.write("cd build\n")
    f.write("xst -intstyle ise -filter \"" + path + "/build/iseconfig/filter.filter\" -ifn \""+path +"/build/klmscint_top.xst\" -ofn \""+path +"/build/klmscint_top.syr\"\n")
    f.write("ngdbuild -filter \"iseconfig/filter.filter\" -intstyle ise -dd _ngo -sd coregen/ipcore -nt timestamp -uc " +path + "/source/constraints/pin_mappings_SCROD_revA5_TX_MB_REVC_KEKDAQ.ucf -p xc6slx150t-fgg676-3 klmscint_top.ngc klmscint_top.ngd\n")
    f.write("LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/Xilinx/14.7/ISE_DS/ISE/lib/lin64/\n")
    f.write("/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/unwrapped/ngdbuild -filter iseconfig/filter.filter -intstyle ise -dd _ngo -sd coregen/ipcore -nt timestamp -uc "+path + "/source/constraints/pin_mappings_SCROD_revA5_TX_MB_REVC_KEKDAQ.ucf -p xc6slx150t-fgg676-3 klmscint_top.ngc klmscint_top.ngd\n")
    f.write("map -filter \"" +path +"/build/iseconfig/filter.filter\" -intstyle ise -p xc6slx150t-fgg676-3 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o klmscint_top_map.ncd klmscint_top.ngd klmscint_top.pcf\n")
    f.write("par -filter \"" + path +"/build/iseconfig/filter.filter\" -w -intstyle ise -ol high -mt off klmscint_top_map.ncd klmscint_top.ncd klmscint_top.pcf\n")
    f.write("trce -filter "+path +"/build/iseconfig/filter.filter -intstyle ise -v 3 -s 3 -n 3 -fastpaths -xml klmscint_top.twx klmscint_top.ncd -o klmscint_top.twr klmscint_top.pcf\n")
    f.write("bitgen -filter \"iseconfig/filter.filter\" -intstyle ise -f klmscint_top.ut klmscint_top.ncd\n")
    f.write("cp klmscint_top.bit ../bin/\n")
    f.write("cd ..\n")


with open('make_synt.sh','w') as f:
    f.write("cd build\n")
    f.write("xst -intstyle ise -filter \"" + path + "/build/iseconfig/filter.filter\" -ifn \""+path +"/build/klmscint_top.xst\" -ofn \""+path +"/build/klmscint_top.syr\"\n")
    f.write("cd ..\n")