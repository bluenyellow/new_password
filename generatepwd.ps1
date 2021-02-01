<#USAGE: example with name John Smith ()
.\generatedpwd.ps1 smith
#>

﻿$user= $args[0]
$menim=Get-ADUser -Filter * -Properties Name,SamAccountName | Where {$_.SamAccountName -eq "$user"} | Select -ExpandProperty  Name #,SamAccountName 

$adcheck=Get-ADUser -Filter * -Properties Name,SamAccountName | Where {$_.Name -like "*$user*"} | Select  Name,SamAccountName | Format-Table
[int]$usernum=$adcheck.Count

if($usernum -gt 1){Write-Host "Pod zadanym hladanim sa nachadzaju dve osoby" ; $adcheck}


Write-Host "Generujem heslo" 
$menim

$plist=Get-Content C:\Users\adamica.JOJ\Desktop\generatingpwd\words.txt

$much=$plist.Count

$one= Get-Random -Minimum 0 -Maximum $much

do{
    
    $two= Get-Random -Minimum 0 -Maximum $much    

} until($one -ne $two)



[string]$prve=$plist[$one]
[string]$druhe=$plist[$two]

$prve=$prve.substring(0,1).toupper()+$prve.substring(1).tolower()
$druhe=$druhe.substring(0,1).toupper()+$druhe.substring(1).tolower()
$cislo=Get-Random -Minimum 0 -Maximum 99

$zrezaneprve=$prve.substring(0, [System.Math]::Min(4, $prve.Length))
$zrezanedruhe=$druhe.substring(0, [System.Math]::Min(4, $druhe.Length))



[string]$hsl=$zrezaneprve+$zrezanedruhe+$cislo
 


 Read-Host -Prompt "For password set, press any key or CTRL+C to quit" 

Set-ADAccountPassword $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText “$hsl” -Force) –PassThru

Write-Host "heslo" $hsl
