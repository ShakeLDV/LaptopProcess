param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Input_Windows_Key {
    Set-Location $PSScriptRoot
    $windows_key = (Get-Content .\key.txt)
    slmgr -ipk $windows_key
}



if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}


if ((Get-WMIObject win32_operatingsystem).name -like "*Education*") {
    Input_Windows_Key
    if ($?){
        Write-Host("Windows key has been applied") -ForegroundColor Green
    }
    else {
        Write-Host("Something went wrong and the key has not been applied...") -ForegroundColor Red
    }
}

$current_location = $PSScriptRoot
$program_location = $current_location + "\Programs"
$software_list = Get-ChildItem -Path $program_location
$counter = 0
foreach($software in $software_list){
    Write-Host("$software is installing....")
    Start-Process $software -ArgumentList "/passive" -Wait -WorkingDirectory $program_location
    $counter++
}
Set-ExecutionPolicy Restricted
Write-Host("Number of Software Installed: $counter")
Pause