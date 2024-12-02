$UserInfo= Get-MgUser -Filter "DisplayName eq 'Test.gouthamBG'" -Property *
$UserGroups= Get-MgUserMemberOf -UserId $UserInfo.Id
foreach($Usergroup in $UserGroups)
    {
    $GroupInfo= Get-MgGroup -GroupId $Usergroup.id

    }