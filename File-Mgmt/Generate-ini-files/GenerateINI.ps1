# Generate the WMStaff.ini file for the WM Tab signatures.


function Generate-List ($Source, $Property) {
    $count = 1
    $letter = $property.ToLower()[0]
    foreach ($item in ($source | sort Staff)) {
        write "$letter$count=$($item.($property))"
        $count ++
    }
}

function Generate-SignaturesPath ($path) {
    write "[SignaturesPath]"
    write "sp1=`"$path`""
}


$list =  Import-Csv .\WMStaff.ini.csv
write "[Staff]"
write "Counter=$($list.Length)"
Generate-List -Source $list -Property "Staff"

write "`r`n[Email]"
Generate-List -Source $list -Property "Email"

write "`r`n[Positions]"
Generate-List -Source $list -Property "Positions"

write "`r`n"
Generate-SignaturesPath "S:\Word 2007 Templates V2\signatures"