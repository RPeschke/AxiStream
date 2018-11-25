class vc_procedure{
    [string]$name
    [string]$argumentList
    [string]$body
    [string]$ClassName
    [string]$Modifier

    vc_procedure($name,$argumentList,$body){
        $this.argumentList=$argumentList
        $this.name=$name
        $this.body=$body
        $this.Modifier="inout"
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
    [string]getArgList(){

        if($this.ClassName){
           
            $classArgs="this : $($this.Modifier) $($this.ClassName)"
        }else {
            $classArgs=""
        }
        $a  = ($classArgs, $this.argumentList) |where {$_ -ne ""}; 
        $classArgs = $a -join "; "
        return $classArgs
    }

}

function v_procedure($name,$argumentList,$body,[switch]$const){

    $ret = [vc_procedure]::new($name,$argumentList,$body)
    if($const){
        $ret.Modifier = "in"
    }
    return $ret

}


