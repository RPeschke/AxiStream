enum UseMasterSlave{
DontUse
Master
Slave
MasterSlave

}

function v_procedure($name,$argumentList,$body,[switch]$const,[UseMasterSlave]$masterSlave){
if($masterSlave -eq $null){
    $masterSlave = [UseMasterSlave]::MasterSlave
}
    $ret = [vc_procedure]::new($name,$argumentList,$body,$masterSlave)
    if($const){
        $ret.Modifier = "in"
    }


    return $ret

}



class vc_procedure{
    [string]$name
    [string]$argumentList
    [string]$body
    [string]$ClassName
    [string]$Modifier
    [UseMasterSlave]$masterSlave
    [string]$SignalClass

    vc_procedure($name,$argumentList,$body,$masterSlave){
        $this.argumentList=$argumentList
        $this.name=$name
        $this.body=$body
        $this.Modifier="inout"
        $this.masterSlave=$masterSlave
        $this.SignalClass =""

    }
    [string]getHeader(){
        $arglist=$this.getArgList()
        $header = "procedure $($this.name)($arglist);`n";
        return $header
    }
    [string]getBody(){
        $arglist=$this.getArgList()
        $p_body = "procedure $($this.name)($arglist) is begin `n";
        $p_body += "$($this.body) `n";
        $p_body += "end procedure $($this.name); `n`n";
        return $p_body

    }
    setClass($className){
        
        $this.ClassName = $className
        
    }
    setSignalClass($signal){
     $this.SignalClass = $signal
    }
    [string]getArgList(){

        if($this.ClassName){
           
            $classArgs="$($this.SignalClass) this : $($this.Modifier) $($this.ClassName)"
        }else {
            $classArgs=""
        }
        $a  = ($classArgs, $this.argumentList) |where {$_ -ne ""}; 
        $classArgs = $a -join "; "
        return $classArgs
    }

}


