enum UseMasterSlave{
DontUse
Master
Slave
MasterSlave

}

function v_function($name,$argumentList,$returnType,$body,[UseMasterSlave]$masterSlave){


if($masterSlave -eq $null){
    $masterSlave = [UseMasterSlave]::MasterSlave
}

$ret = [vc_function]::new($name, $argumentList,$returnType,$body,$masterSlave)
return $ret

}

class vc_function{
    [string]$name
    [string]$argumentList
    [string]$returnType
    [string]$body
    [string]$ClassName
    [string]$SignalClass
    [string]$Modifier
    [UseMasterSlave]$masterSlave

    vc_function($name,$argumentList,$returnType,$body,$masterSlave){
        $this.name=$name
        $this.argumentList=$argumentList
        $this.returnType=$returnType
        $this.body=$body
        $this.Modifier=" "
        $this.masterSlave=$masterSlave
        $this.SignalClass=""
    }
    setClass($className){
        
        $this.ClassName = $className
        
    }
    setSignalClass($signal){
     $this.SignalClass = $signal
    }
    setModifier($Modifier){
        $this.Modifier=$Modifier
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

    [string]getHeader(){
        $arglist=$this.getArgList()
        $header = "function  $($this.name)($arglist) return $($this.returnType);`n";
        return $header
    }
    [string]getBody(){
        $arglist=$this.getArgList()
        $p_body = "function  $($this.name)($arglist) return $($this.returnType) is begin `n";
        $p_body += "$($this.body) `n";
        $p_body += "end function $($this.name); `n`n";
        return $p_body

    }

}