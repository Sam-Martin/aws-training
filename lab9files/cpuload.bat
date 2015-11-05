powershell.exe -Command "& {ForEach ($Loopnumber in 1..2147483647) {$Result=1;ForEach ($Number in 1..2147483647) {$Result = $Result * $Number};$Result}}"

