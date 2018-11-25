class vc_packet_entry{
    [string]$header
    [string]$body
    vc_packet_entry($header, $body){
        $this.body = $body
        $this.header = $header
    }


    [string]getHeader(){
        
        return $this.header
    }
    [string]getBody(){
        return $this.body

    }

}

function make_packet_entry($header, $body){
    return [vc_packet_entry]::new($header,$body);
}
function v_subtype($name,$type){

  $r1  = make_packet_entry -header "subtype  $($name) is $($type);`n"
  return $r1
}

function v_record($Name,$entries){
  $header =  "`ntype $Name is record `n"

  if($entries.GetType().name -eq "Object[]"){
    foreach($x in $entries){
        $header += $x.getEntry();
    }
  }elseif($entries.GetType().name -eq "String"){
    $header += $entries
  }elseif ($entries.GetType().name -eq "vc_member"){
    $header += $entries.getEntry();
  }

  $header += "`nend record $Name; `n`n"

  
  $def = ""
    foreach($x in $entries){
        $def += $x.getDefault();
    }
  if ($def.length -gt 0){
    $header += "constant  $(v_record_null $Name): $Name := ("
    $header +=$def.Substring(0,$def.Length-2)
    $header += ");`n`n"
  }
  $ret = make_packet_entry -header $header
  return $ret;
}


function v_record_null($Name){
return "$($Name)_null"

}

function v_packet($name, $entries){

$ret  = "package $name is`n"
foreach($x in $entries){
    $ret += $x.getHeader()
}
$ret += "end $name;`n`n`n"


$ret += "package body $name is`n"
foreach($x in $entries){
    $ret += $x.getBody()
}
$ret += "end package body $name;`n"

return $ret
}






#class vhdl_function{
#[string]$name;
#[string]$returnType;
#[string]$argumentList;
#[string]$body;
#hdl_function($name,$returnType,$argumentList,$body){
#$this.name=$name;
#$this.returnType=$returnType;
#$this.argumentList=$argumentList;
#$this.body=$body;
#}
#[string]Declaration(){
#$ret = "function $($this.name)($($this.argumentList)) return $($this.returnType);";
#return $ret;
#}
#[string]Definition(){
#$ret = "function $($this.name)($($this.argumentList)) return $($this.returnType) is begin `n";
#$ret += "$($this.body) `n";
#$ret += "  end function $($this.name); `n";
#return $ret;
#}
#}

class vhd_signal{

[string]$name
[string]$type
[string]$InitValue

    vhd_signal($name,$type,$InitValue=""){
        $this.InitValue = $InitValue
        $this.name = $name
        $this.type  = $type
    }
    vhd_signal($name,$type){
        $this.InitValue 
        $this.name = $name
        $this.type  = $type
    }
    [string]def(){
    $ret = "signal $($this.name) : $($this.type)"
    if ($this.InitValue){
    $ret += " := $($this.InitValue)"
    }
    return $ret
    }
}

