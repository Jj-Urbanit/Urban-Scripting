#Obviously only works if you know the device ID.
Set-CASMailbox -Identity: "username" -ActiveSyncAllowedDeviceIDs: "<DeviceID_1>","<DeviceID_2>"