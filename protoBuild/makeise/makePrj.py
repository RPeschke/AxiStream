#!/usr/bin/python
import sys
import os
import six
try:
    import configparser
except:
    from six.moves import configparser
   
ConfigParser=configparser
fusePath = 'fuse'


def HandleSimulation(config,section,path):
    Name = config.get(section,"Name")
    Name = Name.replace('"', '')
    ExecutableName = path + "/" + Name + "_beh.exe"
    
    TopLevelModule = config.get(section,"TopLevelModule")
    tclbatchName = path + "/" +Name+"_beh.cmd"
    ProjectName = path + "/" + Name+ "_beh.prj"

    makeScript = fusePath + ' -intstyle ise -incremental -lib secureip -o ' + ExecutableName +" -prj " +ProjectName + " " + TopLevelModule
    with open(path+"/sim_"+Name+"_build.sh","w") as f : 
        f.write(makeScript)
    


    RunScript = ExecutableName + " -intstyle ise  -tclbatch " +tclbatchName + " -wdb " + path + "/" + Name + "_beh.wdb"
    inFile = config.get(section,'InputDataFile')
    OutputDataFile= config.get(section,'OutputDataFile')
    with open(path+"/sim_"+Name+"_run.sh","w") as f : 
        f.write('if [ "$1" != "" ]; then\ncp $1 '+ inFile +'\nfi\n')
        f.write(RunScript+'\n')
        f.write('if [ "$1" != "" ]; then\nrm -f '+ inFile +'\nfi\n')
        f.write('if [ "$2" != "" ]; then\ncp  ' +OutputDataFile +' $2 \nfi\n')
    onerror=config.get(section,'Onerror')
    Runtime =config.get(section,'Runtime')
    tclbatchScript = "onerror "+onerror +"\nwave add /\nrun "+Runtime + ";\nquit -f;"
    with open(tclbatchName,"w") as f : 
        f.write(tclbatchScript)
    
    with open(ProjectName,"w") as f :
        for op in config.options(section):
            opValue = config.get(section,op)
            if opValue == None:
                f.write('vhdl work "' + op+ '"\n')


def main(args = None):
    if args == None:
        args = sys.argv[1:]
    
    

    if len(args) < 1:
        sys.exit()    

    FileName = args[0]
    Path =  os.path.abspath(args[1])
    print(FileName)
    config = ConfigParser.RawConfigParser(allow_no_value=True)
    config.optionxform=str
    config.read(FileName)
    sections = config.sections()
    
    for s in sections:
        if "Simulation" not in s: 
            continue
        print(s)

        HandleSimulation(config,s,Path)
    

if (__name__ == "__main__"):
    main()