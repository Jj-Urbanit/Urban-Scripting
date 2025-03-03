On Error Resume Next
Const ADS_SCOPE_SUBTREE = 2
Const ADS_SCOPE_ONELEVEL = 1

' Set the necessary variables here for our script
' strOU = The OU we want to read users from in Active Directory
' strEmailTo = The email address we want to send the results to
' strEmailFrom = The email address we want to use to send the results
'
If Wscript.Arguments.Count = 0 Then
    wscript.echo "Invalid number of arguments passed to script"
    wscript.echo "Usage: cscript GetUsersFromAD.vbs 'OU String' 'email server' 'email to' 'email subject' <search top level only TRUE|FALSE>"
    wscript.quit
End If

strOU = Wscript.Arguments(0)
strEmailFrom = Wscript.Arguments(2)
strEmailTo = Wscript.Arguments(3)
strEmailSubject = Wscript.Arguments(4)

' Start our email body
'
strEmailBody = ""
strCount = 0

' Create connection to AD
'
Set objConnection = CreateObject("ADODB.Connection")
objConnection.Open "Provider=ADsDSOObject;"

' Create command
'
Set objCommand = CreateObject("ADODB.Command")
objCommand.ActiveConnection = objConnection
objCommand.Properties("Page Size") = 1000

' Are we searching sublevels or not
'
If Wscript.Arguments(5) = "TRUE" Then
    objCommand.Properties("Searchscope") = ADS_SCOPE_ONELEVEL
End If

' Execute command to get all users in OU (exclude disabled accounts though)
'
objCommand.CommandText = _
  "<LDAP://" & strOU & ">;" & _
  "(&(objectclass=user)(objectcategory=person)(!userAccountControl:1.2.840.113556.1.4.803:=2));" & _
  "distinguishedname,sAMAccountName,displayName"
Set objRecordSet = objCommand.Execute

' Show info for each user in OU
'
Do Until objRecordSet.EOF

  ' Show required info for a user
  '  
  if not isnull(objRecordSet.Fields("displayName").Value) Then
    WScript.Echo objRecordSet.Fields("displayName").Value
    strEmailBody = strEmailBody & VBCrLf & objRecordSet.Fields("displayName").Value
  End If

  ' Move to the next user
  '
  strCount = strCount+1
  objRecordSet.MoveNext

Loop

' Send email
'
Set objMessage = CreateObject("CDO.Message") 
objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = Wscript.Arguments(1)
objMessage.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
objMessage.Configuration.Fields.Update
objMessage.Subject = strEmailSubject 
objMessage.From = strEmailFrom
objMessage.To = strEmailTo
objMessage.TextBody = "User list generated at " & Now & VBCrLf & "Reading Users from OU: " & strOU & VBCrLf & "Total user count: " & strCount & VBCrLf & VBCrLf & "User List:" & strEmailBody 
objMessage.Send

' Clean up
'
objRecordSet.Close
Set objRecordSet = Nothing
Set objCommand = Nothing
objConnection.Close
Set objConnection = Nothing
