do{
$SAM= Read-Host "Enter the SAM account name of the user you want to promote:"
try {
    $SAMADInfo= Get-ADUser -Identity $SAM -Properties * -ErrorAction Stop
    Write-Host "Found user with SAM account Name $SAM | User current Job Title is $($SAMADInfo.Title) and Department is $($SAMADInfo.Department)"
}
catch {
    Write-Error $_
}
$NewTitle= Read-Host "Enter the new title of the user"
$NewDepartment= Read-Host "Enter the new department of the user"
$NewManager= Read-Host "Enter the SAM of the new manager"
$EffectiveDate= Read-Host "Enter the promotion date"
$JIRATicket= Read-Host "Enter JIRA ticket Number"
$Information ="|| Promotion date: $EffectiveDate | JIRA Ticket: $JIRATicket ||"
if($null -ne $NewDepartment)
    {
    try{
        Set-ADUser -Identity $SAMADInfo.SamAccountName -Title $NewTitle -Department $NewDepartment -Manager $NewManager -Add @{info=$Information} -ErrorAction Stop
        get-aduser -Identity $SAMADInfo.SamAccountName -Properties * | Select-Object DisplayName, Title, Department, Manager, info | Format-Table -AutoSize
        }
    catch
        {
        
        }
    }
else {
    Set-ADUser -Identity $SAMADInfo.SamAccountName -Title $NewTitle -Manager $NewManager -Add @{info=$Information}
    }
$Continue= Read-Host "Do you want to promote another user?(Y?N)"    
} while ($Continue -eq "Y")