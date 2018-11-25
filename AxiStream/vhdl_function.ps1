function v_function($name,$argumentList,$returnType,$body){

$ret = [vc_function]::new($name, $argumentList,$returnType,$body)
return $ret

}

class vc_function{
    [string]$name
    [string]$argumentList
    [string]$returnType
    [string]$body
    [string]$ClassName
    
    [string]$Modifier

    vc_function($name,$argumentList,$returnType,$body){
        $this.name=$name
        $this.argumentList=$argumentList
        $this.returnType=$returnType
        $this.body=$body
        $this.Modifier="in"
    }
    setClass($className){
        
        $this.ClassName = $className
        
    }
    setModifier($Modifier){
        $this.Modifier=$Modifier
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