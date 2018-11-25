class vc_member{
[string]$name
[string]$type
vc_member($name,$type){
$this.name = $name
$this.type = $type
}

[string]getEntry(){
$ret ="$($this.name) : $($this.type); `n"
return $ret
}
}
function v_member($name,$type){
return [vc_member]::new($name,$type)
}

class vc_class{
[System.Object[]]$entries;

}

function v_class($name,$entries){

$ret=@()
$ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $name`n" -body "`n`n-- Starting Pseudo class $name`n"

$member = $entries | where{$_.GetType().name -eq "vc_member"}
$function = $entries | where{$_.GetType().name -ne "vc_member"}

$b1 = v_record -Name $name -entries $member


$ret += $b1;
foreach($x in $function){
    $x.setClass($name)
    $header  = $x.getHeader()
    $body = $x.getBody()
    $ret += make_packet_entry -header $header -body $body
}

$ret+= make_packet_entry -header "-- End Pseudo class $name`n`n" -body "-- End Pseudo class $name`n`n"
return $ret

}


 
