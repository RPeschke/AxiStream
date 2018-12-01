enum InOutType {

In
Out
Internal
InternalMaster
InternalSlave

}


function v_member($name,$type,$default,[switch]$NoDefault,$DoUse,[InOutType]$InOut){
if($DoUse -eq $null){
    $DoUse = $true
}

if($default -eq $null){
    $default = v_record_null -Name $type
}
if($NoDefault){
    $default =""
}



return [vc_member]::new($name,$type,$default,$InOut,$DoUse)
}


class vc_member{
    [string]$name
    [string]$type
    [string]$default
    [bool]$doUse
    [InOutType]$InOut
    vc_member($name,$type, $default,$InOut ,$doUse){
        $this.name = $name
        $this.type = $type
        $this.default = $default
        $this.doUse=$doUse
        $this.InOut = $InOut
    }

    [string]getEntry(){
        if($this.doUse -eq $false){
          return "";
        }
        $ret ="$($this.name) : $($this.type); `n"
        return $ret
    }

    [string]getDefault(){
        if($this.doUse -eq $false){
            return "";
        }

        $ret =""

        if($this.default.Length -gt 0){
            $ret = "$($this.name) => $($this.default),`n" 
        }
        return $ret
    }
}




class vc_class{
[System.Object[]]$entries;
[string]$name;
[string]$MasterBeforePull;
[string]$SlaveBeforePull;
[string]$MasterAfterPull;
[string]$SlaveAfterPull;
[string]$MasterBeforePush;
[string]$SlaveBeforePush;
[string]$MasterAfterPush;
[string]$SlaveAfterPush;

[string]$MasterRecName;
[string]$SlaveRecName;

[string]$M2S_recName;
[string]$S2M_recName;

    vc_class($name,$entries){
        $this.name = $name
        $this.entries = $entries
        $this.MasterRecName = "$($name)_master"
        $this.SlaveRecName = "$($name)_slave"
        $this.M2S_recName = "$($name)_m2s"
        $this.S2M_recName = "$($name)_s2m"
    }

    append($entry){
        $this.entries +=$entry

    }

    [System.Object[]]getEntries_Master(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.MasterRecName)`n" -body "`n`n-- Starting Pseudo class $($this.MasterRecName)`n"

            $member = $this.entries | where{$_.GetType().name -eq "vc_member"} |where{$_.InOut -ne 'InternalSlave' }
            $function =  $this.entries | where{$_.GetType().name -ne "vc_member"} |where{$_.masterSlave -eq 'Master' -or  $_.masterSlave -eq 'MasterSlave' }

            $b1 = v_record -Name $this.MasterRecName -entries $member


            $ret += $b1;
            foreach($x in $function){
                $x.setClass($this.MasterRecName )
                $header  = $x.getHeader()
                $body = $x.getBody()
                $ret += make_packet_entry -header $header -body $body
            }

            $ret+= make_packet_entry -header "-- End Pseudo class $($this.MasterRecName)`n`n" -body "-- End Pseudo class $($this.MasterRecName)`n`n"
            return $ret
    }

    [System.Object[]]getEntries_Slave(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.SlaveRecName)`n" -body "`n`n-- Starting Pseudo class $($this.SlaveRecName)`n"

            $member = $this.entries | where{$_.GetType().name -eq "vc_member"} |where{$_.InOut -ne 'InternalMaster' }
            $function =  $this.entries | where{$_.GetType().name -ne "vc_member"}|where{$_.masterSlave -eq 'Slave' -or  $_.masterSlave -eq 'MasterSlave' }

            $b1 = v_record -Name $this.SlaveRecName -entries $member


            $ret += $b1;
            foreach($x in $function){
                $x.setClass($this.SlaveRecName )
                $header  = $x.getHeader()
                $body = $x.getBody()
                $ret += make_packet_entry -header $header -body $body
            }

            $ret+= make_packet_entry -header "-- End Pseudo class $($this.SlaveRecName)`n`n" -body "-- End Pseudo class $($this.SlaveRecName)`n`n"
            return $ret
    }
    [System.Object[]]getEntries_M2S(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.M2S_recName)`n" -body "`n`n-- Starting Pseudo class $($this.M2S_recName)`n"

            $member = $this.entries | where{$_.GetType().name -eq "vc_member"}
            $member =  $member|where{$_.inout -eq "out"}

            $b1 = v_record -Name "$($this.M2S_recName)" -entries $member
            $ret += $b1;


            $ret+= make_packet_entry -header "-- End Pseudo class $($this.M2S_recName)`n`n" -body "-- End Pseudo class $($this.M2S_recName)`n`n"
            return $ret
    }

    [System.Object[]]getEntries_S2M(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.S2M_recName)`n" -body "`n`n-- Starting Pseudo class $($this.S2M_recName)`n"

            $member = $this.entries | where{$_.GetType().name -eq "vc_member"}
            $member =  $member|where{$_.inout -eq "in"}

            $b1 = v_record -Name "$($this.S2M_recName)" -entries $member
            $ret += $b1;


            $ret+= make_packet_entry -header "-- End Pseudo class $($this.S2M_recName)`n`n" -body "-- End Pseudo class $($this.S2M_recName)_m2s`n`n"
            return $ret
    }

    [System.Object[]]make_connection_pull($master){
            $ret=@()
            $body = ""
            $member = $this.entries | where{$_.GetType().name -eq "vc_member"}
            if($master -eq $true){
                $member =  $member|where{$_.inout -eq "in"}
                $type = "$($this.name)_s2m"
                
                $className = $this.MasterRecName
                $body += "$($this.MasterBeforePull)`n"
                $afterPull = "$($this.MasterAfterPull)`n"
            }else{
                $member =  $member|where{$_.inout -eq "out"}
                $type = "$($this.name)_m2s"
                $className = $this.SlaveRecName                

                $body += "$($this.SlaveBeforePull)`n"
                $afterPull = "$($this.SlaveAfterPull)`n"
            }

            $functionName = "pull_$($className)"            
            foreach($x in $member){
                $body += "this.$($x.name) := DataIn.$($x.name);`n"
            }
            $body+=$afterPull
            $pull = (v_procedure -name   $functionName  -argumentList "signal DataIn : in  $type" -body $body)
            $pull.setClass($className)
            $header  = $pull.getHeader()
            $body    = $pull.getBody()
            $ret    += make_packet_entry -header $header -body $body

            return $ret
    }

    [System.Object[]]make_connection_push($master){
            $ret=@()
            $body = ""
            
            $member = $this.entries | where{$_.GetType().name -eq "vc_member"}
            if($master -eq $true){
                $member       =  $member|where{$_.inout -eq "out"}
                $type         =  $this.M2S_recName
                $className    =  $this.MasterRecName
                
                $body        += "$($this.MasterBeforePush)`n"
                $afterPush    = "$($this.MasterAfterPush)`n"
            }else{
                $member       =  $member|where{$_.inout -eq "in"}
                
                $type         = $this.S2M_recName
                $className    =  $this.SlaveRecName
                $body        += "$($this.SlaveBeforePush)`n"
                $afterPush    = "$($this.SlaveAfterPush)`n"
            }

            $functionName = "push_$($className)"
            foreach($x in $member){
                $body += "DataOut.$($x.name) <= this.$($x.name);`n"
            }
            $body+=$afterPush;
            $push = (v_procedure -name   $functionName  -argumentList "signal DataOut : out  $type" -body $body)
            $push.setClass($className )
            $header  = $push.getHeader()
            $body    = $push.getBody()
            $ret    += make_packet_entry -header $header -body $body

            return $ret
    }
    [System.Object[]]getEntries_Connections(){
            $ret=@()
            $ret += $this.make_connection_pull($true)
            $ret += $this.make_connection_pull($false)
            $ret += $this.make_connection_push($true)
            $ret += $this.make_connection_push($false)


            return $ret
    }
    [System.Object[]]getEntries(){
            $ret=@()
            $ret+= make_packet_entry -header "`n`n-- Starting Pseudo class $($this.name)`n" -body "`n`n-- Starting Pseudo class $($this.name)`n"
            $ret+=$this.getEntries_S2M()
            $ret+=$this.getEntries_M2S()
            $ret+=$this.getEntries_Master()
            $ret+=$this.getEntries_Slave()
            $ret+=$this.getEntries_Connections()
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


 
