Read-Host -Prompt Password -AsSecureString | ConvertFrom-SecureString |Out-File "C:\Temp\EncryptedPassword.txt"




