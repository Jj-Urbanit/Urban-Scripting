#
# All_DFSR_Backlog.ps1
#
 Clear-Host;

            $DFSR_List = Get-DFSReplicatedFolder * | Select FolderName,GroupName;
            $DFSR_Conx = Get-DFSRConnection | Select GroupName,SourceComputerName,DestinationComputerName;

            ## WRITING INFO TO CONSOLE -- COMMENT THESE OUT IF YOU DON'T NEED TO SEE THIS
            Write-Host `n `n `n `n `n `n `n `n `n `n; #Ten New lines to prevent status bar overlay
            Write-Host -ForegroundColor Yellow "Collecting replicated folder list...";
            Write-Host -ForegroundColor Magenta "Found " $DFSR_List.count "items!" `n;
            Write-Host -ForegroundColor Yellow "Collecting replication connections...";
            Write-Host -ForegroundColor Magenta "Found " $DFSR_Conx.count "connections!" `n;

            $ResultTbl = @();

            foreach ($Backlog in $DFSR_List)
                {
                $Folder = $Backlog.FolderName;
                $Group = $Backlog.GroupName;
                $ConxMem = $DFSR_Conx | ?{$_.GroupName -like $Group};

                #STATUS BAR
                $PercentComplete = ($DFSR_List.IndexOf($Backlog)/$DFSR_Conx.count*100);
                $PercentComplete = [math]::Round($PercentComplete,1);
                $ConxCount = $DFSR_Conx.Count;
                Write-Progress -activity "Processing $ConxCount connections ($Group)" -status "Progress: % $PercentComplete" -PercentComplete ($PercentComplete);
                #END STATUS BAR


                foreach ($Status in $ConxMem)
                    {
                    $SendMem = $Status.SourceComputerName;
                    $RecMem = $Status.DestinationComputerName;

            ## For use on LEGACY DFSRDIAG backlogs (Server 2012R2 and earlier) -- Comment this section out to disable
                    #DFSRDIAG backlog /rgname:$Group /rfname:$Folder /ReceivingMember:$RecMem /SendingMember:$SendMem > E:\Scripts\_Utility\Temp.txt ;
                    #$Report = (Get-Content E:\Scripts\_Utility\Temp.txt).Split(':')[2] ;
            ## END Legacy code
    

            ## For use on newer FS running DFSR. 2012R2 lacks the powershell commands for this. Script will need mild restructuring.
                   $Report = (Get-DfsrBacklog -GroupName $Group -FolderName $Folder -SourceComputerName $SendMem -DestinationComputerName $RecMem -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Verbose 4>&1).message.split(':')[2];
            ## END powershell code

                    $ResultTbl += New-Object psobject -Property @{ReplicationGroup=$Status.GroupName;SendingMember=$SendMem;ReceivingMember=$RecMem;BacklogCount=$Report};

                    }
                }

            ## Use these for LEGACY DFSRDIAG backlogs - Comment out to DISABLE
            $ResultTbl | Export-Csv DFSRBacklog.CSV -Force -NoTypeInformation;
            $ResultTbl | ?{$_.BacklogCount -ne ""} | sort BacklogCount | Out-GridView -Title (Get-Date);

            ##Use these for PowerShell Get-DFSRBacklog - Uncomment to ENABLE
            <#
            $ResultTbl | Export-Csv DFSRBacklog.CSV -Force -NoTypeInformation;
            $ResultTbl | ?{$_.BacklogCount -ne $null} | sort BacklogCount | Out-GridView -Title (Get-Date);
            #>