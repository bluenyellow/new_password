<#USAGE: example with name John Smith ()
.\generatedpwd.ps1 smith
#>

$password = ConvertTo-SecureString "Kamosko744" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("adamica", $password )

$S = New-PSSession -ComputerName DC-1 -Credential $cred
Import-Module -PSsession $S -Name ActiveDirectory

$user= "marge.simpson" #$args[0]   #tu ide meno v tvare samaccountname

if($user -eq $null){Write-host "treba zadat meno(SamAccountName)";exit}     #overi ci argument mena nie je empty     

$menim=Get-ADUser -Filter * -Properties Name,SamAccountName | Where-Object {$_.SamAccountName -eq "$user"} | Select-Object -ExpandProperty Name     #extrahovanie mena z Active directory

$tel=Get-ADUser -Filter * -Properties * | Where-Object {$_.SamAccountName -eq "$user"} | Select-Object -ExpandProperty MobilePhone    #extrahovanie tel.c. z Active directory

$adcheck=Get-ADUser -Filter * -Properties Name,SamAccountName | Where-Object {$_.Name -like "*$user*"} | Select-Object  Name,SamAccountName | Format-Table     #hladanie vsetkych userov ktory maju podobny samaccount name
$unum=Get-ADUser -Filter * -Properties Name,SamAccountName | Where-Object {$_.Name -like "*$user*"} | Select-Object -ExpandProperty SamAccountName           #orezanie usernamov na holy text

[int]$usernum=$unum.Count   #spocitanie poctu userov z podobnym sammacountname

if($usernum -gt 1){Write-Host "Pod zadanym hladanim sa nachadzaju dve osoby" ; $adcheck}    #ak existuju viaceri useri pod rovnakym samaccountname tak ich vypise


Write-Host -ForegroundColor Green "Generujem heslo" 
$menim

$plist=Get-Content C:\Users\adamica\Desktop\generatingpwd\words.txt   #nacitanie wordlistu

$much=$plist.Count   #spocitanie poctu slov

$one= Get-Random -Minimum 0 -Maximum $much         #vybratie nahodneho slova z wordlistu

do{
    
    $two= Get-Random -Minimum 0 -Maximum $much          #toto je tu nato aby sa nezopakovalo slovo dva razy

} until($one -ne $two)



[string]$prve=$plist[$one]
[string]$druhe=$plist[$two]


#odtialto davam tym slovam na zaciatok velke pismeno a orezem kazde z nich na dlzku 4 znakov

$prve=$prve.substring(0,1).toupper()+$prve.substring(1).tolower()
$druhe=$druhe.substring(0,1).toupper()+$druhe.substring(1).tolower()
$cislo=Get-Random -Minimum 0 -Maximum 99

$zrezaneprve=$prve.substring(0, [System.Math]::Min(4, $prve.Length))
$zrezanedruhe=$druhe.substring(0, [System.Math]::Min(4, $druhe.Length))



[string]$hsl=$zrezaneprve+$zrezanedruhe+$cislo     #tu je heslo kopmletne vygenerovane v tvare XxxxXxxxNN
Write-Host -BackgroundColor Red "heslo" $hsl

 Read-Host -Prompt "For password set, press any key or CTRL+C to quit"       #toto je confirm ci chceme heslo setnut danemu uzivatelovi

Set-ADAccountPassword $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$hsl" -Force) #tuto sa setne vygenerovane heslo           

Write-Host -BackgroundColor Red "heslo" $hsl
Write-Host -ForegroundColor Black -BackgroundColor Yellow "telefon" $tel


$text = "Heslo do VPN a PC je: $hsl"
$tel = "$tel"

#odosielanie SMS

$params = @{
    "token"="vQpHRB3FFshqD3AH";
    #"sender"="+421900900900";
    "recipient"="$tel";
    "text"="$text";
   }
   [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
   Invoke-RestMethod -ContentType 'application/json' -Method 'Post' -Uri https://sms-gw.joj.sk/send-sms -Body ($params|ConvertTo-Json)



   <#
#odtialto je to uz len napajanie na modem a odosielanie SMSky

$serialPort = new-Object System.IO.Ports.SerialPort
# Set various COM-port settings
$serialPort.PortName = "COM9"
$serialPort.BaudRate = 19200
$serialPort.WriteTimeout = 500
$serialPort.ReadTimeout = 3000
$serialPort.DtrEnable = "true"
# Open the connection
$serialPort.Open()
# Add variables for phone number and the message.
$phoneNumber = "$tel"
$textMessage = "Heslo do VPN a PC je: $hsl"

try {
 $serialPort.Open()
}
catch {
 # Wait for 5s and try again
 Start-Sleep -Seconds 5
 $serialPort.Open()
}
If ($serialPort.IsOpen -eq $true) {
 # Tell the modem you want to use AT-mode
 $serialPort.Write("AT+CMGF=1`r`n")
 # Start feeding message data to the modem
 # Begin with the phone number, international
 # style and a <CL>... that's the `r`n part
 $serialPort.Write("AT+CMGS=`"$phoneNumber`"`r`n")
 # Give the modem some time to react...
 Start-Sleep -Seconds 1
 # Now, write the message to the modem
 $serialPort.Write("$textMessage`r`n")
 # Send a Ctrl+Z to end the message.
 $serialPort.Write($([char] 26))
 # Wait for modem to send it
 Start-Sleep -Seconds 1
}
# Close the Serial Port connection
$serialPort.Close()
if ($serialPort.IsOpen -eq $false) {
 Write-Output "Port Closed!"
}
#>



