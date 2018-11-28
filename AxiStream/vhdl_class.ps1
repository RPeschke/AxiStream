class vc_member{
    [string]$name
    [string]$type
    [string]$default
    vc_member($name,$type, $default){
        $this.name = $name
        $this.type = $type
        $this.default = $default
    }

    [string]getEntry(){
        $ret ="$($this.name) : $($this.type); `n"
        return $ret
    }

    [string]getDefault(){
        $ret =""
        if($this.default.Length -gt 0){
            $ret = "$($this.name) => $($this.default),`n" 
        }
        return $ret
    }
}
function v_member($name,$type,$default,[switch]$NoDefault){
if($default -eq $null){
    $default = v_record_null -Name $type
}
if($NoDefault){
    $default =""
}
return [vc_member]::new($name,$type,$default)
}

class vc_class{
[System.Object[]]$entries;
[string]$name;


    vc_class($name,$entries){
        $this.name = $name
        $this.entries = $entries
    }

    append($entry){
        $this.entries +=$entry

    }

    [System.Object[]]getEntries(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.name)`n" -body "`n`n-- Starting Pseudo class $($this.name)`n"

            $member = $this.entries | where{$_.GetType().name -eq "vc_member"}
            $function =  $this.entries | where{$_.GetType().name -ne "vc_member"}

            $b1 = v_record -Name $this.name -entries $member


            $ret += $b1;
            foreach($x in $function){
                $x.setClass($this.name )
                $header  = $x.getHeader()
                $body = $x.getBody()
                $ret += make_packet_entry -header $header -body $body
            }

            $ret+= make_packet_entry -header "-- End Pseudo class $($this.name)`n`n" -body "-- End Pseudo class $($this.name)`n`n"
            return $ret
    }
    [string]getHeader(){
        $ret="";
        $Local_entries = $this.getEntries();
        foreach($x in $Local_entries){
            $ret += $x.getHeader()
        }
        return $ret
    }
    [string]getBody(){
        $ret="";
        $Local_entries = $this.getEntries();
        foreach($x in $Local_entries){
            $ret += $x.getBody()
        }
        return $ret

    }
}

function v_class($name,$entries){

$ret = [vc_class]::new($name, $entries);
return $ret


}


 
