function Get-AVInfo {
    <#
    .SYNOPSIS
    The script looks for and returns many different AVs on a system. It also displays detailed information on either Vipre, Bitdefender, or Windows Defender, depending on the switch you run with the command. The script can also be used to either enable Vipre, or update Vipre, Windows Defender or Bitdefender definitions, as well as test if the machine can reach intellisecure.myvipre.com.
    .DESCRIPTION
    This script first queries the machine for a bunch of different AVs, from a predefined list, by searching installed services. It then uses CIM (or WMI) to retrieve any AVs registered with Windows. The script then retrieves more detailed information about the specific AV you specify (Vipre, Bitdefender, or Windows Defender); if nothing is specified, the default is Vipre, unless the 'DefaultOverride' parameter is used. Finally, the script retrieves basic information about the hardware and operating system, often helpful when troubleshooting things like out-of-date definitions.
    The script can do other things as well, like update definitions for the different antiviruses, as well as other useful checks and actions. For more information about what the script can do, read the README.md file in GitHub (link below), and check out the PowerShell help on the parameters, provided with this script. There are also tests and checks that happen in the background that are not listed here or in the parameter help (but are in the GitHub README.md file), and that only show up in the script results if found to be true. For more on that, you'll have to read through the actual script :)
    GitHub link: https://github.com/IntelliScripts/Get-AVInfo
    .PARAMETER Bitdefender
    Returns detailed information about Bitdefender installed on the system. Cannot be used with Vipre and Windows Defender parameters.
    .PARAMETER UpdateBDDefs
    Updates Bitdefender definitions. Cannot be used with any other parameter.
    .PARAMETER UninstallBitdefender
    Uninstalls password-protected Bitdefender. Must know the password to uninstall. The script will prompt for the password.
    .PARAMETER WindowsDefender
    Returns detailed information about Windows Defender installed on the system. Cannot be used with Vipre and Bitdefender parameters.
    When specifying this parameter, the script will also look for the registry key that disables Windows Defender and prevents it from starting.
    .PARAMETER UpdateWDDefs
    Updates Windows Defender definitions. Cannot be used with any other parameter.
    .PARAMETER Vipre
    Returns detailed information about Vipre installed on the system. This is the default, if no AV is specified. Cannot be used with Bitdefender and Windows Defender parameters.
    When specifying this parameter, the script will also test that the machine can reach intellisecure.myvipre.com.
    Vipre is the default, when no AV is specified.
    .PARAMETER DefaultOverride
    Overrides the default behavior of retrieving Vipre information, when no other AV is specified. This cannot be used with any parameter other than the 'MachineInfo' parameter.
    .PARAMETER InstallVipre
    Downloads the Vipre installer from our LTShare and runs it.
    .PARAMETER UpdateVipreDefs
    Updates Vipre definitions. Can only be used with the EnableVipre parameter.
    .PARAMETER MachineInfo
    When specifying this parameter, the script checks for hardware and OS information. The script does not perform these checks by default.
    Cannot be used with the 'action' parameters (such as UpdateVipreDefs).
    .PARAMETER EnableVipre
    Enables SBAMSvc. For when the SBAMSvc service is in a disabled state. Can only be used with the UpdateVipreDefs parameter.
    .PARAMETER EnableVipreAP
    Enables Vipre's Active Protection when it is disabled. This does not make changes to the services themselves.
    .PARAMETER RenameDefsFolder
    Renames the definitions folder, for when defs are corrupted. NOTE: The SBAMSvc service must be in a stopped state, or else permission to rename the folder will be denied.
    .PARAMETER CleanWipe
    The script looks for the CleanWipe utility in two different places, and runs it.
    On Windows 7 machines, the CleanWipe utility cannot be run from where ScreenConnect puts it. If the utility is found in that location, PowerShell will move it to 'C:\Windows\Temp\CleanWipe', and then run it from there.
    .PARAMETER UninstallVipre
    Uninstalls Vipre using the built-in uninstaller.
    .PARAMETER McAfeeUninstall
    Uninstalls McAfee products using the built-in uninstallers.
    .PARAMETER McAfeeUninstall_MCPR
    Uninstalls McAfee using the MCPR (McAfee Consumer Product Removal) Tool.
    .PARAMETER SophosUninstall
    Uninstalls Sophos using the built-in uninstaller (assuming tamper protection is not enabled).
    .PARAMETER CiscoUninstall
    Uninstalls Cisco Secure Endpoint using the built-in uninstaller.
    .PARAMETER MalwarebytesUninstall
    Uninstalls Malwarebytes using the built-in uninstaller.
    .PARAMETER KasperskyUninstall
    Uninstalls Kaspersky applications that cannot be removed completely using standard Windows tools.
    .PARAMETER ESETUninstall
    Uninstalls ESET Endpoint Antivirus.
    .PARAMETER UnregisterAV
    Unregisters AVs from the Windows Security Center using WMI.
    .PARAMETER UnregisterWebroot
    Unregisters Webroot from the Windows Security Center.
    .PARAMETER UninstallWebroot
    Uninstalls Webroot by installing an MSI on top of the existing install then uninstalling with the same MSI right after.
    .PARAMETER UninstallWebroot1
    Uninstalls older Webroot software using the CleanWDF tool.
    .PARAMETER HPWolfUninstall
    Uninstalls HP Wolf Security products, in a specific order, to avoid issues with the uninstallation process.
    .PARAMETER OpenIE
    Opens Internet Explorer.
    .PARAMETER FindRMM
    Finds other RMM tools on the machine.
    .PARAMETER RebootStatus
    Checks if the machine is pending a reboot.
    .EXAMPLE
    PS C:\> Get-AVInfo -WindowsDefender
    This retrieves AVs installed on the system, as well as detailed information on Windows Defender.
    .EXAMPLE
    PS C:\> Get-AVInfo -Vipre -MachineInfo
    This retrieves AVs installed on the system, as well as detailed information on Vipre.
    Specifying the 'MachineInfo' switch parameter causes the command to perform hardware and OS checks as well.
    .EXAMPLE
    PS C:\> Get-AVInfo -EnableVipre
    Running this enables the SBAMSvc service and starts it.
    .EXAMPLE
    PS C:\> Get-AVInfo -UpdateBDDefs
    Updates Bitdefender definitions on the machine.
    .EXAMPLE
    PS C:\> Get-AVInfo -UninstallVipre
    Uninstalls Vipre using the built-in uninstaller.
    .EXAMPLE
    PS C:\> Get-AVInfo -McAfeeUninstall_MCPR
    Uninstalls McAfee using the MCPR (McAfee Consumer Product Removal) Tool.
    .EXAMPLE
    PS C:\> Get-AVInfo -UnregisterAV
    Unregisters AVs from the Windows Security Center.
    .EXAMPLE
    PS C:\> Get-AVInfo -RebootStatus
    Checks if the machine is pending a reboot.
    .EXAMPLE
    PS C:\> Get-AVInfo -MachineInfo -DefaultOverride
    This retrieves detailed information about the hardware and operating system of the machine.
    The 'DefaultOverride' parameter prevents the script from defaulting to retrieving Windows Defender information.
    .INPUTS
    None. You cannot pipe objects to this script.
    .OUTPUTS
    Various. The script outputs information about the AVs installed on the system, as well as other relevant information.
    .NOTES
    This script can be run on a machine in Automate, backstage. Simply paste the contents of this function into the shell and press enter, to load the script into memory. Then, just run 'Get-AVInfo', along with whatever parameters, if any, you want to add.
    You can also run the code below to download and load the script into memory:
    "wget -uri 'https://raw.githubusercontent.com/IntelliScripts/Get-AVInfo/master/Get-AVInfo.ps1' -UseBasicParsing | iex"
    # For machines that do not support wget (e.g., older PowerShell versions), use:
    "(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/IntelliScripts/Get-AVInfo/master/Get-AVInfo.ps1') | iex"
    If you get an error "The request was aborted: Could not create SSL/TLS secure channel.", run this command first: 
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
    .LINK
    https://github.com/IntelliScripts/Get-AVInfo
    =================================
    Author: THH
    Email: estengel@intellicomp.net
    Comments and suggestions welcome!
    =================================
    #>
    [CmdletBinding(#SupportsShouldProcess = $True,
        #ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'WindowsDefender')]
    param (
        [Parameter(parametersetname = 'Bitdefender',
            Mandatory = $false)]
        [Alias("BD")]
        [Switch]$Bitdefender,

        [Parameter(parametersetname = 'WindowsDefender',
            Mandatory = $false)]
        [Alias("WD")]
        [switch]$WindowsDefender,

        [Parameter(parametersetname = 'Vipre',
            Mandatory = $false)]
        [switch]$Vipre,

        [Parameter(parametersetname = 'Default_Override',
            Mandatory = $false)]
        [Switch]$DefaultOverride,

        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$EnableVipre,
        
        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$UpdateVipreDefs,

        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$EnableVipreAP,

        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$RenameDefsFolder,

        [Parameter(parametersetname = 'Vipre_Install',
            Mandatory = $false)]
        [Switch]$InstallVipre,

        [Parameter(parametersetname = 'Vipre_Uninstall',
            Mandatory = $false)]
        [Switch]$UninstallVipre,
        
        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$VipreUpdateCheck,

        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$AgentShutdownCheck,
        
        [Parameter(parametersetname = 'Vipre_Action',
            Mandatory = $false)]
        [Switch]$VipreRemovalTool,

        [Parameter(parametersetname = 'WindowsDefender',
            Mandatory = $false)]
        [switch]$WDSignaturesDetailed,
        
        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$EnableWDRegKey,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$EnableWD,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$UpdateWDDefs,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$ResetWDDefs,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$GetMpCmdRunLog,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$DisableUILockdown,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$EnableUILockdown,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$InstallWDFeature,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$UpdateNISDefs,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$RestartLTServices,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$RestartHuntressServices,

        [Parameter(parametersetname = 'WindowsDefender_Action',
            Mandatory = $false)]
        [Switch]$HuntressInfo,

        [Parameter(ParameterSetName = 'Bitdefender_Action',
            Mandatory = $false)]
        [Switch]$UpdateBDDefs,

        [Parameter(parametersetname = 'Bitdefender_Action',
            Mandatory = $false)]
        [Switch]$UninstallBitdefender,

        [Parameter(parametersetname = 'Vipre')]
        [Parameter(parametersetname = 'Bitdefender')]
        [Parameter(parametersetname = 'WindowsDefender')]
        [Parameter(parametersetname = 'Default_Override')]
        [Parameter(parametersetname = 'AV_Folders')]
        [Switch]$AVFolders,

        [Parameter(parametersetname = 'Vipre')]
        [Parameter(parametersetname = 'Bitdefender')]
        [Parameter(parametersetname = 'WindowsDefender')]
        [Parameter(parametersetname = 'Default_Override')]
        [Parameter(parametersetname = 'AV_Folders')]
        [Switch]$DeleteAVFolders,

        [Parameter(parametersetname = 'Vipre')]
        [Parameter(parametersetname = 'Bitdefender')]
        [Parameter(parametersetname = 'WindowsDefender')]
        [Parameter(parametersetname = 'Default_Override')]
        [Switch]$MachineInfo,

        [Parameter(parametersetname = 'Vipre')]
        [Parameter(parametersetname = 'Bitdefender')]
        [Parameter(parametersetname = 'WindowsDefender')]
        [Parameter(parametersetname = 'Default_Override')]
        [Switch]$IncludeProcesses,

        # for the TT Symantec ticket only
        [Parameter(parametersetname = 'Symantec',
            Mandatory = $false)]
        [Switch]$CleanWipe,

        [Parameter(parametersetname = 'Avast',
            Mandatory = $false)]
        [Switch]$AvastUninstall,

        [Parameter(parametersetname = 'Norton',
            Mandatory = $false)]
        [Switch]$NortonUninstall,

        [Parameter(parametersetname = 'McAfee_Action',
            Mandatory = $false)]
        [Switch]$McAfeeUninstall,

        [Parameter(parametersetname = 'McAfee_Action',
            Mandatory = $false)]
        [Switch]$McAfeeUninstall_MCPR,

        [Parameter(parametersetname = 'Sophos_Action',
            Mandatory = $false)]
        [Switch]$SophosUninstall,

        [Parameter(parametersetname = 'Cisco_Action',
            Mandatory = $false)]
        [Switch]$CiscoUninstall,

        [Parameter(parametersetname = 'Malwarebytes_Action',
            Mandatory = $false)]
        [Switch]$MalwarebytesUninstall,

        [Parameter(parametersetname = 'Kaspersky_Action',
            Mandatory = $false)]
        [Switch]$KasperskyUninstall,

        [Parameter(parametersetname = 'ESET_Action',
            Mandatory = $false)]
        [Switch]$ESETUninstall,

        [Parameter(parametersetname = 'WSC_Action',
            Mandatory = $false)]
        [Switch]$UnregisterAV,

        # for the P-PP Webroot machines
        [Parameter(parametersetname = 'Webroot_Action',
            Mandatory = $false)]
        [Switch]$UnregisterWebroot,

        [Parameter(parametersetname = 'Webroot_Action',
            Mandatory = $false)]
        [Switch]$UninstallWebroot,
        
        [Parameter(parametersetname = 'Webroot_Action',
            Mandatory = $false)]
        [Switch]$UninstallWebroot1,

        [Parameter(parametersetname = 'HP_Wolf_Action',
            Mandatory = $false)]
        [Switch]$HPWolfUninstall,
        
        # for troubleshooting access to AV update URLs backstage
        [Parameter(ParameterSetName = 'IE',
            Mandatory = $false)]
        [Switch]$OpenIE,

        [Parameter(parametersetname = 'RMM',
            Mandatory = $false)]
        [Switch]$FindRMM,

        [Parameter(parametersetname = 'PendingReboot',
            Mandatory = $false)]
        [Switch]$RebootStatus
    )

    BEGIN {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.MyCommand)"
    }
    PROCESS {
        # Write-Debug "Started PROCESS block"
        function UninstallApp {
            [CmdletBinding()]
            param (
                [string[]]$Name
            )
            $RegUninstallPath = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            $Apps = Get-ItemProperty $RegUninstallPath -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*$($Name)*"
            if (!$Apps) {
                Write-Host "$Name is not installed.`nExiting."
            } # if !$Apps
            else {
                Write-Host -ForegroundColor Green "The following product(s) are installed on the machine:"
                $Apps.DisplayName
            
                $Answer = Read-Host "`nUninstall the product(s) listed above? ('Y' to uninstall all / 'C' to choose which to uninstall / 'N' to cancel)"
                if ($Answer -eq 'Y') {
                    foreach ($A in $Apps) {
                        Write-Host -ForegroundColor Green "`nUninstalling $($A.DisplayName)"
                        # Wrap the exe part of the uninstall string with quotes, if spaces are included in the string
                        # $UninstallString = $A.UninstallString -replace '^(.*?\.exe)', '"$1"'
                        $UninstallString = $A.UninstallString -replace '^(.*?\.exe)(.*)', '"`"$1`""$2"'
                        # Execute a silent uninstall in the background with no UI.
                        $UninstallCommand = "$($UninstallString.Replace('/I', '/X')) /qn /noreboot REBOOT=REALLYSUPPRESS"
                        Write-Debug "UninstallString: $UninstallString`nUninstall command: $UninstallCommand"
                        cmd.exe /c $UninstallCommand
                    } # foreach 
                } # if 'Y'
                elseif ($Answer -eq 'C') {
                    foreach ($A in $Apps) {
                        $Answer = Read-Host "`nUninstall $($A.DisplayName)? (Y/N)"
                        if ($Answer -eq 'Y') {
                            Write-Host -ForegroundColor Green "`nUninstalling $($A.DisplayName)"
                            # Wrap the exe part of the uninstall string with quotes, if spaces are included in the string
                            $UninstallString = $A.UninstallString -replace '^(.*?\.exe)', '"$1"'
                            # Execute a silent uninstall in the background with no UI.
                            $UninstallCommand = "$($UninstallString.Replace('/I', '/X')) /qn /noreboot REBOOT=REALLYSUPPRESS"
                            cmd.exe /c $UninstallCommand
                        }
                        else {
                            Write-Host "Cancelling uninstall of $($A.DisplayName)."
                        }   
                    } # foreach
                } # elseif 'C' 
                else {
                    Write-Host -ForegroundColor Green "Uninstallation canceled.`nExiting Script."
                    break
                } # else 'N'
            } # else $Apps   
        } # function UninstallApp

        switch ($PSCmdlet.ParameterSetName) {
            'Vipre_Action' { 
                if ($EnableVipre) {
                    Write-Verbose "Enabling SBAMSvc"
                    if (!(Get-Service SBAMSvc -ErrorAction SilentlyContinue)) {
                        Write-Warning "No SBAMSvc service present. Cannot enable Vipre."
                    }
                    elseif ( ((Get-Service SBAMSvc).StartType -eq 'Automatic') -and ((Get-Service SBAMSvc).status -eq 'Running')) {
                        Write-Host -ForegroundColor Green "SBAMSvc is already set to auto-start, and is running."
                    }
                    else {
                        Write-Verbose "Enabling SBAMSvc and starting it"
                        Set-Service SBAMsvc -StartupType Automatic -Status Running
                        Get-Service SBAMSvc | Format-Table Name, DisplayName, Status, StartType
                    }
                } # if $EnableVipre
                if ($UpdateVipreDefs) {
                    if (!(Test-Path 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe')) {
                        Write-Warning "Cannot update Vipre definitions. Core Vipre files are missing. Please (re)install Vipre and try again."
                    }
                    else {
                        Write-Verbose "Updating Vipre definitions"
                        & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /updatedefs
                        Write-Host -ForegroundColor Green 'Date & time definitions last updated:'
                        $Date = (& 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /displaylocaldefversion).Substring('9'); $Date1 = $Date.split('T'); "Date: $($Date1[0]) Time: $($Date1[1])"
                    } # if Test-Path
                } # if $UpdateVipreDefs
                if ($EnableVipreAP) {
                    if (!(Test-Path 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe')) {
                        Write-Warning "Cannot enable active protection. Core Vipre files are missing. Please (re)install Vipre and try again."
                    }
                    else {
                        Write-Verbose "Enabling Vipre Active Protection"
                        $APState = & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /apstate
                        if ($APState -eq 'Enabled') {
                            Write-Host -ForegroundColor Green "Vipre Active Protection is already enabled."
                        }
                        else {
                            & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /enableap
                            $APState = & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /apstate
                            if ($APState -eq 'Enabled') {
                                Write-Host -ForegroundColor Green "Vipre Active Protection successfully enabled."                        
                            }
                            else {
                                Write-Warning "Vipre Active Protection is still not enabled. Please look into this."
                            }
                        }
                    } # if Test-Path
                } # if $EnableVipreAP
                # Run the following parameter after sending an agent shutdown command from the Vipre portal, to see when Vipre is actually stopped 
                if ($AgentShutdownCheck) {
                    if (!(Get-Service SBAMSvc -ErrorAction SilentlyContinue)) {
                        Write-Warning "No Vipre service detected.`nExiting"
                    }
                    else {
                        while ( (Get-Service SBAMSvc).Status -ne 'Stopped' ) {
                            for ($i = 0; $i -lt 20; $i++) {
                                Get-Service SBAMSvc; Start-Sleep -Seconds 2
                            } # for loop
                        } # while
                        Write-Host "Service SBAMSvc is in a stopped state"
                    }
                } # if $AgentShutdownCheck
                if ($VipreUpdateCheck) {
                    if ( !((Get-ChildItem "C:\Program Files (x86)\VIPRE Business Agent\Definitions\Beetle\*" -ErrorAction SilentlyContinue).Name -like "*_PENDING*") ) {
                        Write-Host "Vipre definitions are not currently being updated."                        
                    }
                    else {
                        While ((Get-ChildItem "C:\Program Files (x86)\VIPRE Business Agent\Definitions\Beetle\*" -ErrorAction SilentlyContinue).Name -like "*_PENDING*" ) {
                            Write-Host -ForegroundColor Green "Vipre definitions are updating. Please wait.."; Start-Sleep -Seconds 2
                        }
                    }
                } # if $VipreUpdateCheck
                if ($RenameDefsFolder) {
                    # Checking for admin rights
                    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                        Write-Warning "Renaming the definitions folder must be done from an admin shell. Please launch an admin shell and try again."
                        Break
                    }
                    Write-Verbose "Checking for presence of the definitions folder"
                    if (!(Test-Path 'C:\Program Files*\VIPRE Business Agent\Definitions')) {
                        Write-Warning "Cannot rename definitions folder. Definitions folder is not present."
                    }
                    else {
                        Write-Verbose "Checking the state of the Vipre service"
                        if ((Get-Service SBAMSvc).Status -eq 'Stopped') {
                            Write-Host -ForegroundColor Green "Renaming Vipre definitions folder"
                            Rename-Item -Path 'C:\Program Files (x86)\VIPRE Business Agent\Definitions\' -NewName "Definitions.old$(Get-Random)"
                        }
                        else {
                            Write-Host -ForegroundColor Green "Cannot rename the definitions folder while the SBAMSvc service is running. `nStop Vipre from the portal, and then try again."
                        }
                    } # if Test-Path
                } # if $RenameDefsFolder
                if ($VipreRemovalTool) {
                    Write-Verbose "Downloading the Vipre Removal Tool"
                    Invoke-WebRequest -Uri "https://go.vipre.com/?linkid=1914" -OutFile "C:\Windows\Temp\VipreRemovalTool.exe" -ErrorAction SilentlyContinue
                    if (Test-Path "C:\Windows\Temp\VipreRemovalTool.exe") {
                        Write-Verbose "Download complete"
                        $Answer = Read-Host "The Vipre Removal Tool will reboot the computer.`nProceed? (Y/N)"
                        if ($Answer -eq 'Y') {
                            & "C:\Windows\Temp\VipreRemovalTool.exe" # -spquiet   
                        }
                        elseif ($Answer -eq 'N') {
                            Write-Host "Not running the Vipre Removal Tool.`nClosing."
                            Break
                        }
                    }
                    else {
                        Write-Warning "The tool did not download successfully.`nPlease download it manually from 'https://go.vipre.com/?linkid=1914'."
                    }
                }
            } # if ParameterSet 'Vipre_Action'
            'WindowsDefender_Action' {
                if ($EnableWDRegKey) {
                    Write-Verbose "Creating or setting the applicable Windows Defender registry keys"
                    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 0 -ErrorAction SilentlyContinue
                    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 0 -ErrorAction SilentlyContinue
                    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name 'DisableAntiVirus' -Value 0 -ErrorAction SilentlyContinue
                }
                if ($EnableWD) {
                    Write-Verbose "Enabling Windows Defender"
                    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -wdenable
                    Start-Service WinDefend -ErrorAction SilentlyContinue
                }
                if ($UpdateWDDefs) {
                    Write-Verbose "Updating Windows Defender definitions"
                    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -SignatureUpdate
                    # Can also use 'Update-MpSignature', but it returns less verbose output than the above command
                    # Error codes and their meanings: https://learn.microsoft.com/en-us/archive/technet-wiki/15260.windows-update-agent-error-codes
                }
                if ($ResetWDDefs) {
                    Write-Verbose "Removing the current definitions and reloading them"
                    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -RemoveDefinitions -All
                    Write-Verbose "Reset definitions complete. Initiating signature update."
                    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -SignatureUpdate
                }
                if ($GetMpCmdRunLog) {
                    # open the MpCmdRun.log logfile
                    if (Test-Path "C:\Windows\Temp\MpCmdRun.log") {
                        Notepad C:\Windows\Temp\MpCmdRun.log
                    }
                    else {
                        Write-Host -ForegroundColor Red "The MpCmdRun.log file is not present."
                    }
                }
                if ($EnableUILockdown) {
                    Write-Verbose "Hiding the Windows Defender UI"
                    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration\' -Name 'UILockdown' -Value 1 -ErrorAction SilentlyContinue
                }
                if ($DisableUILockdown) {
                    Write-Verbose "Unhiding the Windows Defender UI"
                    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration\' -Name 'UILockdown' -Value 0 -ErrorAction SilentlyContinue
                    Write-Host "Keep in mind the 'Notification_Supress' Registry key may still be enabled"
                }
                if ($InstallWDFeature) {
                    if ( (Get-WmiObject Win32_OperatingSystem).producttype -ne 1 ) {
                        Write-Verbose "Installing the Windows-Defender feature"
                        Get-WindowsFeature | Where-Object { $_.Name -like 'Windows-Defender' } | Add-WindowsFeature
                    }
                    else {
                        Write-Host -ForegroundColor Yellow "The 'InstallWDFeature' parameter can only be used on a server OS.`nExiting script."
                        break
                    }
                }
                if ($UpdateNISDefs) {
                    # for when NISEnabled is $True but NISSignatureLastUpdated is empty, and manually updating defs the usual way doesn't help 
                    if ((Get-MpComputerStatus).AMProductVersion -gt '4.1.522.0') {
                        try {
                            # Download page: https://www.microsoft.com/en-us/wdsi/defenderupdates
                            Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkID=187316&arch=x64&nri=true" -OutFile 'C:\Windows\Temp\NISDefs.exe' -ErrorAction Stop | Out-Null
                            & 'C:\Windows\Temp\NISDefs.exe'
                            Write-Host -ForegroundColor Green "NIS definitions update complete."
                            Write-Host -ForegroundColor Green "NIS defs last updated: $((Get-MpComputerStatus).NISSignatureLastUpdated)"
                            Remove-Item 'C:\Windows\Temp\NISDefs.exe' -Force -ErrorAction SilentlyContinue
                        }
                        catch {
                            Write-Warning "Failed to download the NIS definitions update. Error: $($_.Exception.Message)"
                            break
                        }
                    }
                    else {
                        Write-Warning "The Antimalware Client version on the machine is older than version 4.1.522.0. Please manually download a compatible version NIS updates."
                        break
                    }
                }
                if ($RestartLTServices) {
                    Write-Host -ForegroundColor Green "Stopping LT Services"
                    Stop-Service LTService, LTSvcMon -ErrorAction SilentlyContinue -PassThru
                    Write-Host -ForegroundColor Green "`nStarting LT Services"
                    Start-Service LTService, LTSvcMon -ErrorAction SilentlyContinue -PassThru
                }
                if ($RestartHuntressServices) {
                    Write-Host -ForegroundColor Green "Stopping Huntress Services"
                    Stop-Service Huntress* -ErrorAction SilentlyContinue -PassThru
                    Write-Host -ForegroundColor Green "`nStarting Huntress Services"
                    Start-Service Huntress* -ErrorAction SilentlyContinue -PassThru
                }
                if ($HuntressInfo) {
                    Write-Verbose "Retrieving services, processes and Registry info"
                    $Services = Get-Service Huntress* | Format-Table Name, DisplayName, Status, StartType -AutoSize
                    $Processes = Get-Process Huntress*, *RIO* | Select-Object Name, Description, ProductVersion, StartTime, Id | Format-Table -AutoSize
                    Write-Host -ForegroundColor Green "Huntress Services:"
                    $Services
                    if (!(Get-Service Huntress*)) {
                        Write-Host "No Huntress services detected.`n"
                    }
                    Write-Host -ForegroundColor Green "Huntress Processes:"
                    $Processes
                    if (!(Get-Process Huntress*, *RIO*)) {
                        Write-Host "No Huntress processes running.`n"
                    }
                    # Check Huntress Tamper Protection Mode
                    # https://support.huntress.io/hc/en-us/articles/34614410683795-Huntress-Agent-Tamper-Protection
                    if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Huntress\' -Name 'UninstallMode' -ErrorAction SilentlyContinue).UninstallMode -eq 1) {
                        Write-Host -ForegroundColor Cyan "Huntress Protection mode is enabled.`n"
                    }
                }
            } # if ParameterSet 'WindowsDefender_Action'
            'Bitdefender_Action' {
                if ($UpdateBDDefs) {
                    Write-Verbose "Updating Bitdefender definitions"
                    & "C:\Program Files\Bitdefender\Endpoint Security\product.console.exe" /c StartUpdate
                }
                if ($UninstallBitdefender) {
                    # https://www.bitdefender.com/business/support/en/77209-80124-using-the-uninstall-tool-to-remove-bitdefender-endpoint-security-tools.html
                    $Password = Read-Host -Prompt "Enter the password for the Bitdefender uninstall tool" -AsSecureString
                    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
                    $ToolPath = "C:\Windows\Temp\BEST_uninstallTool.exe"

                    Write-Host "Downloading the Bitdefender uninstall tool"
                    $originalProgressPreference = $ProgressPreference
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri "https://download.bitdefender.com/SMB/Hydra/release/bst_win/uninstallTool/BEST_uninstallTool.exe?_gl=1*1oh7zs8*_ga*ODQ1ODU2MjY1LjE3NDYwNDExMzg.*_ga_6M0GWNLLWF*MTc0NjA0MTEzNy4xLjEuMTc0NjA0MTE0MC41Ny4wLjU5MzUwOTE4NA.." -OutFile $ToolPath
                    $ProgressPreference = $originalProgressPreference

                    Write-Debug "Bitdefender download complete. Path: $ToolPath. UNinstall password: $PlainTextPassword"
                    if (Test-Path $ToolPath) {
                        Write-Host "Running the Bitdefender uninstall tool"
                        Start-Process -FilePath $ToolPath -ArgumentList "/bdparams /password=`"$PlainTextPassword`"" -Wait
                        Write-Host -ForegroundColor Green "Bitdefender uninstall tool has completed."
                        Remove-Item $ToolPath -Force
                        Write-Host "The uninstall tool has been removed from the machine."
                    }
                    else {
                        Write-Warning "Failed to download the Bitdefender uninstall tool. Please try again."
                    }
                }
            } # if ParameterSet 'Bitdefender_Action'
            'Vipre_Install' {
                $Answer = Read-Host "Would you like to download the Vipre installer to the machine? (Y/N)"
                if ($Answer -eq 'Y') {
                    Write-Verbose "Checking for presence of Vipre installer on the machine"
                    if ((Test-Path 'C:\Windows\Temp\VipreInstaller.msi')) {
                        Write-Host -ForegroundColor Green "The Vipre installer is already present on the machine, at 'C:\Windows\Temp\VipreInstaller.msi'"
                    } # if Test-Path
                    else {
                        Write-Host -ForegroundColor Green "Downloading Vipre installer from LTShare. Please wait.."
                        # To account for Windows 7 machines I do not use the Invoke-WebRequest or Invoke-RestMethod cmdlets for downloading the installer
                        try {
                            (New-Object Net.WebClient).DownloadFile("https://labtech.intellicomp.net/labtech/transfer/Tools/vipre_agent_intellisecure_12.3.8160.msi", "C:\Windows\Temp\VipreInstaller.msi")   
                        }
                        catch {}
                        if (Test-Path 'C:\Windows\Temp\VipreInstaller.msi') { 
                            Write-Host -ForegroundColor Green "Download complete (version 12.3.8160).`nInstaller saved to 'C:\Windows\Temp\VipreInstaller.msi'." 
                        }
                        else {
                            Write-Warning "Download failed. Exiting script."
                            break
                        }
                    } # if !Test-Path
                    $Answer1 = Read-Host "Run the installer? (Y/N)"
                    if ($Answer1 -eq 'Y') {
                        Write-Verbose "Running the installer"
                        & "C:\Windows\Temp\VipreInstaller.msi"
                    }
                    elseif ($Answer1 -eq 'N') {
                        Write-Host -ForegroundColor Green "Installer will NOT be run.`nExiting script."
                    }
                } # if $Answer -eq 'Y'
                elseif ($Answer -eq 'N') {
                    Write-Host -ForegroundColor Green "Cancelling the installer download.`nExiting the script."  
                } # if $Answer -eq 'N'
            } # if ParameterSet 'Vipre_Install'
            'Vipre_Uninstall' {
                if ($UninstallVipre) {
                    <#
                    $App = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object displayname -like *vipre*
                    if (!$App) {
                        Write-Host "Vipre is not installed.`nExiting."
                    }
                    else {
                        foreach ($A in $App) {
                            $Answer = Read-Host "Are you sure you want to uninstall $($A.DisplayName)? (Y/N)"
                            if ($Answer -eq 'Y') {
                                # killing off Vipre processes that seem to cause the built-in uninstaller to hang at times
                                # $PIDs = Get-Process | Where-Object Company -like "*Vipre*"
                                # Get-WmiObject Win32_Service | Where-Object { ($_.processid -ne 0) -and ($_.processid -in $PIDs) } | Stop-Process  -Force -ErrorAction SilentlyContinue
                                Get-Process | Where-Object Company -like "*Vipre*" | Stop-Process -Force -ErrorAction SilentlyContinue

                                Write-Verbose "Retrieving uninstall string for app $($A.DisplayName)"
                                $UninstallString = $A.UninstallString
                                if (($UninstallString -match '.exe') -and ($UninstallString -notmatch '\.exe"')) {
                                    # Wrap the exe part of the uninstall string with quotes, if spaces are included in the string
                                    $UninstallString = $UninstallString -replace '^(.*?\.exe)', '"$1"'
                                }
                                if ($UninstallString -like '*/I*') {
                                    $UninstallCommand = $UninstallString.Replace('/I', '/X')
                                }
                                else {
                                    $UninstallCommand = $UninstallString
                                }
                                Write-Verbose "Uninstalling $A.DisplayName"
                                cmd.exe /c $($uninstallcommand)
                            } # if $Answer -eq 'Y'
                            else {
                                Write-Host "Cancelling uninstall of $($A.DisplayName)."
                            } # else $Answer -eq 'N'
                        } # foreach $A in $App
                    } # else $App
                    #>
                    UninstallApp -Name "Vipre"
                } # if $UninstallVipre
            } # if ParameterSet 'Vipre_Uninstall'
            'Symantec' {
                if ( (Test-Path 'C:\Windows\Temp\CleanWipe') -and (([version](Get-ChildItem 'C:\Windows\Temp\CleanWipe\CleanWipe.exe').versioninfo.fileversion).Build -ge 8259) ) {
                    Write-Verbose "The CleanWipe utility is present at 'C:\Windows\Temp\CleanWipe'.`nRunning the utility."
                    Start-Process "C:\Windows\Temp\CleanWipe\CleanWipe.exe"
                }
                elseif (Test-Path 'C:\Windows\system32\config\systemprofile\Documents\IntelliCare Control\Files\*cleanwipe*') {
                    # if SC was used to transfer the utility to the machine, it's found at this location, 
                    # and since the utility cannot typically be run from where ScreenConnect drops it, moving it is nec.
                    Write-Verbose "Moving the Symantec CleanWipe tool to C:\Windows\Temp"
                    Move-Item -Path 'C:\Windows\system32\config\systemprofile\Documents\IntelliCare Control\Files\*cleanwipe*' -Destination 'C:\Windows\Temp\CleanWipe'
                    Start-Process 'C:\Windows\Temp\CleanWipe\CleanWipe.exe'
                }
                else {
                    Write-Host "The CleanWipe folder cannot be found, or an older version of the utility is present on the machine."
                    $Answer = Read-Host "Would you like to download the latest version of the CleanWipe utility? (Y/N)"
                    if ($Answer -eq 'Y') {
                        # remove the old version if present, otherwise expand-archive will not overwite existing file
                        if ( Test-Path 'C:\Windows\Temp\CleanWipe*' ) { Get-ChildItem 'C:\Windows\Temp\CleanWipe*' | Remove-Item -Recurse -Force -Confirm:$false }
                        Write-Verbose 'Downloading the CleanWipe utility version 14.3.9205.6000'
                        # To account for Windows 7 machines, I don't use the typical Invoke-WebRequest cmdlet below
                        (New-Object Net.WebClient).DownloadFile("https://labtech.intellicomp.net/labtech/transfer/Tools/1667853049028__CleanWipe_14.3.9205.6000.zip", "C:\Windows\Temp\CleanWipe.zip")
                        Write-Verbose "Download complete"
                        Write-Verbose "Expanding the downloaded zip file and running it"
                        # Using the .NET method, to account for Windows 7 machines that don't support the 'Expand-Archive' cmdlet
                        Add-Type -AssemblyName "System.IO.Compression.Filesystem"
                        [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\Windows\Temp\CleanWipe.zip", "C:\Windows\Temp\CleanWipe")
                        Start-Process "C:\Windows\Temp\CleanWipe\CleanWipe.exe"
                    } # if 'Y'
                    elseif ($Answer -eq 'N') {
                        Write-Host "Exiting script."
                    } # if 'N'
                }
            } # if ParameterSet 'Symantec'
            'Avast' {
                # Check if avastclear.exe is already present on the machine
                if (-not (Test-Path "C:\Windows\Temp\avastclear.exe")) {
                    $Answer = Read-Host "Would you like to download and run the Avast Clear Tool? (Y/N)"
                    if ($Answer -eq 'N') {
                        Write-Host "Exiting script."
                        return
                    } # if 'N'     
                    elseif ($Answer -eq 'Y') {   
                        Write-Verbose 'Downloading the Avast Removal tool and saving to "C:\Windows\Temp\avastclear.exe".'
                        # To account for Windows 7 machines, I don't use the Invoke-WebRequest cmdlet below
                        (New-Object Net.WebClient).DownloadFile("https://files.avast.com/iavs9x/avastclear.exe", "C:\Windows\Temp\avastclear.exe")
                        Write-Verbose "Download complete. Running avastclear.exe."
                    } # if 'Y'
                } # if !Test-Path                   
                Start-Process "C:\Windows\Temp\avastclear.exe"
                # If the Avast Clear uninstaller doesn’t work, you can uninstall Avast using the Command Prompt:
                # https://www.avast.com/en-us/uninstall-utility#pc:~:text=Uninstall%20Avast%20using%20Command%20Prompt            
            } # if ParameterSet 'Avast'
            'Norton' {
                $Answer = Read-Host "Would you like to download and run the Norton Remove and Reinstall tool? (Y/N)"
                if ($Answer -eq 'Y') {   
                    if (!(Test-Path "C:\Windows\Temp\NRnR.exe")) {
                        Write-Verbose 'Downloading the Norton Remove and Reinstall tool and saving to "C:\Windows\Temp\NRnR.exe".'
                        # To account for Windows 7 machines I don't use the Invoke-WebRequest cmdlet below
                        (New-Object Net.WebClient).DownloadFile("https://norton.com/nrnr", "C:\Windows\Temp\NRnR.exe")
                        Write-Verbose "Download complete. Running NRnR.exe."
                        Write-Host -ForegroundColor Green "Download saved to 'C:\Windows\Temp\NRnR.exe'"
                    }
                    else {
                        Write-Host -ForegroundColor Green "Tool already present at 'C:\Windows\Temp\NRnR.exe'"
                    }
                    Write-Host -ForegroundColor Green "Running the tool. Please wait."
                    Write-Warning "If you're using CWC backstage the GUI won't show properly.`nYou can try blindly navigating the GUI using the following tutorial:`
                    https://www.youtube.com/watch?v=x3jqCV1bgSQ&list=PLMHhjKfBkIZSd1UlxoZXsq5_m3E3HPtED"
                    Start-Process "C:\Windows\Temp\NRnR.exe"
                } # if 'Y'
                elseif ($Answer -eq 'N') {
                    Write-Host "Exiting script."
                } # if 'N'
            } # if ParameterSet 'Norton
            'McAfee_Action' {
                if ($McAfeeUninstall) {
                    # Uninstall McAfee products using the built-in uninstallers
                    <#
                    $App = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object displayname -like *mcafee*
                    if (!$App) {
                        Write-Host "McAfee is not installed.`nExiting."
                    }
                    else {
                        foreach ($A in $App) {
                            $Answer = Read-Host "Are you sure you want to uninstall $($A.DisplayName)? (Y/N)"
                            if ($Answer -eq 'Y') {
                                Write-Verbose "Retrieving uninstall string for app $($A.DisplayName)"
                                $UninstallString = $A.UninstallString
                                if (($UninstallString -match '.exe') -and ($UninstallString -notmatch '\.exe"')) {
                                    # Wrap the exe part of the uninstall string with quotes, if spaces are included in the string
                                    $UninstallString = $UninstallString -replace '^(.*?\.exe)', '"$1"'
                                }
                                if ($UninstallString -like '*/I*') {
                                    $UninstallCommand = $UninstallString.Replace('/I', '/X')
                                }
                                else {
                                    $UninstallCommand = $UninstallString
                                }
                                Write-Verbose "Uninstalling $A.DisplayName"
                                cmd.exe /c $($uninstallcommand)
                            } # if $Answer -eq 'Y'
                            else {
                                Write-Host "Cancelling uninstall of $($A.DisplayName)."
                            } # else $Answer -eq 'N'
                        } # foreach $A in $App
                    } # else $App
                    #>
                    UninstallApp -Name "McAfee"
                } # if $McAfeeUnintsall
                elseif ($McAfeeUninstall_MCPR) {
                    # for uninstalling McAfee using MCPR when the built-in McAfee uninstall methods aren't working

                    Write-Warning "The tool may reboot the machine after running, without prompting for confirmation.`nPlease confirm the machine can be rebooted before proceeding."
                    $Answer6 = Read-Host "Proceed? (Y/N)"
                    if ($Answer6 -eq 'N') {
                        Write-Host "Exiting script."
                        break
                    } # if 'N'

                    # Check if the MCPR tool is already present on the machine and matches the expected hash value
                    if ( (Test-Path 'C:\MCPR.exe') -and (((Get-FileHash -Path 'C:\MCPR.exe' -Algorithm SHA256).Hash -eq 'D4D2266A19876BECCC95A97E1E5821EF42D98D503818C1E3F19BE75E9358B100')) ) {
                        Write-Host -ForegroundColor Green "The MCPR tool is already present on the machine, at 'C:\MCPR.exe'"
                        $Answer5 = Read-Host "Run the tool? (Y/N)"
                        if ($Answer5 -eq 'Y') {
                            Write-Verbose "Running the tool"
                            & "C:\MCPR.exe"
                            break
                        }
                        elseif ($Answer5 -eq 'N') {
                            Write-Host -ForegroundColor Green "NOT running the tool.`nExiting script."
                        }
                    } # if Test-Path
                    else {
                        Write-Host "The MCPR tool is not present on the machine, or it is present but does not match the expected file hash."
                    }

                    Write-Host -ForegroundColor Green "Downloading the MCPR (McAfee Consumer Product Removal) Tool"
                    # Retrieve the current value for $ProgressPreference, set it to 'SilentlyContinue' to suppress the progress bar for a much quicker download, then reset it to its original value
                    $originalProgressPreference = $ProgressPreference
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri 'https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe' -OutFile 'C:\MCPR.exe'
                    $ProgressPreference = $originalProgressPreference
                    
                    # Check that the file downloaded successfully using the expected hash value
                    $expectedHash = 'D4D2266A19876BECCC95A97E1E5821EF42D98D503818C1E3F19BE75E9358B100'
                    $actualHash = (Get-FileHash -Path 'C:\MCPR.exe' -Algorithm SHA256).Hash
                    if ($actualHash -ne $expectedHash) {
                        Write-Warning "The downloaded file's hash does not match the expected hash. 
                        Please download the file manually from 'https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe', save it to 'C:\MCPR.exe', then run this script again."
                        break
                    }

                    Write-Host -ForegroundColor Green "Download saved to 'C:\MCPR.exe'"
                    $Answer3 = Read-Host "Run the tool? (Y/N)"
                    if ($Answer3 -eq 'Y') {
                        Write-Verbose "Running the tool"
                        & "C:\MCPR.exe"
                    }
                    elseif ($Answer3 -eq 'N') {
                        Write-Host -ForegroundColor Green "NOT running the tool.`nExiting script."
                    }
                }
            } # if ParameterSet 'McAfee_Action'
            'Sophos_Action' {
                if (Test-Path 'C:\Program Files\Sophos\Sophos Endpoint Agent\SophosUninstall.exe') {
                    Write-Host -ForegroundColor Green "Uninstalling Sophos."
                    Write-Host "If you're not rebooting now, make sure to un-check the 'Reboot' checkbox before hitting 'Close' at the end, or the machine will reboot."
                    & 'C:\Program Files\Sophos\Sophos Endpoint Agent\SophosUninstall.exe'
                    # to run the uninstaller quietly add the --quiet switch to the command above
                }
                else {
                    Write-Host -ForegroundColor Green "Cannot find the Sophos uninstaller.`nExiting script."
                }   
            } # if parameterSet 'Sophos_Action'
            'Cisco_Action' {
                # uninstall Cisco Secure Endpoint using the built-in uninstaller
                # https://www.cisco.com/c/en/us/support/docs/security/amp-endpoints/215704-installation-and-configuration-of-amp-co.html
                Write-Host -ForegroundColor Green "Uninstalling Cisco Secure Endpoint"
                $uninstallPath = Get-ChildItem -Path "C:\Program Files\Cisco\AMP" -Directory | Where-Object { $_.Name -match "^\d+\.\d+\.\d+\.\d+$" } | Select-Object -ExpandProperty FullName | ForEach-Object { Join-Path -Path $_ -ChildPath "uninstall.exe" }
                Start-Process $uninstallPath -ArgumentList "/R /S /remove 1"
            } # if parameterSet 'Cisco_Action'            
            'Malwarebytes_Action' {
                # for uninstalling Malwarebytes using the built-in uninstaller
                Write-Verbose "Running the Malwarebytes uninstaller"
                & "C:\Program Files\Malwarebytes\Anti-Malware\mb5uns.exe"
                # can also use the Support Tool if needed: https://support.malwarebytes.com/hc/en-us/articles/360039023473-Uninstall-and-reinstall-Desktop-Security-with-the-Support-Tool
            } # if ParameterSet 'Malwarebytes_Action'
            'Kaspersky_Action' {
                # tool for removing Kaspersky applications that cannot be removed completely using standard Windows tools
                # https://support.kaspersky.com/common/uninstall/1464#block1
                Write-Host -ForegroundColor Green "Downloading the kavremover tool"
                Invoke-WebRequest -Uri 'https://media.kaspersky.com/utilities/ConsumerUtilities/kavremvr.exe' -OutFile 'C:\kavremvr.exe'
                Write-Host -ForegroundColor Green "Download saved to 'C:\kavremvr.exe'"
                $Answer4 = Read-Host "Run the tool? (Y/N)"
                if ($Answer4 -eq 'Y') {
                    Write-Verbose "Running the tool"
                    & "C:\kavremvr.exe"
                }
                elseif ($Answer4 -eq 'N') {
                    Write-Host -ForegroundColor Green "NOT running the tool.`nExiting script."
                }
            } # if ParametreSet 'Kaspersky_Action'
            'ESET_Action' {
                Write-Verbose "Uninstalling ESET Endpoint Antivirus"
                <#
                $APP = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*ESET Endpoint Antivirus*"
                $UninstallString = $App.UninstallString.Replace('/I', '/X')
                $UninstallCommand = "$uninstallString /qn /noreboot REBOOT=REALLYSUPPRESS"
                cmd.exe /c $UninstallCommand
                #>
                UninstallApp -Name "ESET"
            } # if ParameterSet ESET_Action
            'WSC_Action' {
                Write-Host -ForegroundColor Green "The folowing AVs are registered with the Windows Security Center:"
                $AVP = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).DisplayName
                $ASP = (Get-WmiObject -Namespace root\securitycenter2 -Class AntispywareProduct).DisplayName
                $AVP
                $ASP
                Write-Debug "AVs in the Windows Security Center are: $AVP / $ASP"
                [String[]]$AV_List = Read-Host "`nType the names of the AVs to unregister, exactly as they appear in the above list (seperate multiple entries with commas and use quotes around names that contain spaces)"
                $AV_List = $AV_List.Split(',')
                $AV_List | ForEach-Object {
                    #if ( ($_ -notin $AVP) -and ($_ -notin $ASP) ) {
                    #    Write-Host -ForegroundColor Green "$_ is not in the list of AV(s) above. Skipping $_."
                    #    continue
                    #}
                    Write-Host -ForegroundColor Green "This action will remove $_ from the Windows Security Center. $_ will no longer be registered as an Antivirus with Windows. Proceed only if $_ isn't actually installed on the machine, otherwise uninstall it properly first."
                    $AV_Answer = Read-Host "Would you like to proceed? (Y/N)"
                    if ($AV_Answer -eq 'Y') {
                        Write-Host "Removing $_ from the Windows Security Center"
                        Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -Filter "displayname=$_" -ErrorAction SilentlyContinue | Remove-WmiObject # ForEach-Object { $_.Delete() }
                        Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiSpywareProduct -Filter "displayname=$_" -ErrorAction SilentlyContinue | Remove-WmiObject # ForEach-Object { $_.Delete() }
                        $AVP = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).DisplayName
                        $ASP = (Get-WmiObject -Namespace root\securitycenter2 -Class AntispywareProduct).DisplayName
                        Write-Host -ForegroundColor Green "`nAVs still registered with the Windows Security Center:"
                        $AVP
                        $ASP
                    } # answer = Y
                    elseif ($AV_Answer -eq 'N') {
                        Write-Host -ForegroundColor Green "NOT unregistering $_ from the Windows Security Center."
                    } # answer = N
                } # foreach-object
                Write-Host "`nExiting Script"
            } # if ParameterSet 'WSC_Action'
            'Webroot_Action' {
                if ($UnregisterWebroot) {
                    Write-Host "Removing Webroot from the Windows Security Center"
                    Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct -Filter "displayname='Webroot SecureAnywhere'" | Remove-WmiObject
                    Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiSpywareProduct -Filter "displayname='Webroot SecureAnywhere'" | Remove-WmiObject
                    $AVP = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).DisplayName
                    $ASP = (Get-WmiObject -Namespace root\securitycenter2 -Class AntispywareProduct).DisplayName
                    Write-Host -ForegroundColor Green "`nAVs still registered with the Windows Security Center:"
                    $AVP
                    $ASP
                }
                if ($UninstallWebroot) {
                    # for uninstalling webroot by installing with an msi on top of the existing install then uninstalling with the same msi right after
                    Write-Host -ForegroundColor Green "Downloading Webroot installer"
                    Invoke-WebRequest -Uri 'http://anywhere.webrootcloudav.com/zerol/wsasme.msi' -OutFile 'C:\wsasmi.msi'
                    Write-Host -ForegroundColor Green "Installing Webroot"
                    Start-Process msiexec.exe '/i "C:\wsasmi.msi" /quiet /norestart' -Wait
                    Write-Host -ForegroundColor Green "Uninstalling Webroot"
                    Start-Process msiexec.exe '/x "C:\wsasmi.msi" /quiet /norestart' -Wait
                    # deleting the installer
                    Remove-Item 'C:\wsasmi.msi'
                    Write-Host -ForegroundColor Green "Uninstall complete. Please wait a minute or two and then check for success including for the now disabled WRSVC service, then manually reboot.`
                    `nYou will typically still need to unregister Webroot from the Windows Security Center as well as get rid of leftover folders manually."
                }
                if ($UninstallWebroot1) {
                    # for uninstalling older Webroot software using the CleanWDF tool (when the first method doesn't work)
                    # https://answers.webroot.com/Webroot/ukp.aspx?pid=17&app=vw&vw=1&solutionid=1034&t=SecureAnywhere-You-need-help-uninstalling-legacy-Webroot-software
                    Write-Host -ForegroundColor Green "Downloading Webroot's CleanWDF removal/cleanup tool"
                    Invoke-WebRequest -Uri 'https://download.webroot.com/CleanWDF.exe' -OutFile 'C:\CleanWDF.exe'                   
                    Write-Host -ForegroundColor Green "Running the tool`nClick the Clean button to begin the cleanup process. This process runs very quickly."
                    Start-Process 'C:\CleanWDF.exe' -Wait
                    # deleting the tool
                    Remove-Item 'C:\CleanWDF.exe'
                    Write-Host -ForegroundColor Green "Uninstall Complete. Please reboot."
                }
            } # if ParameterSet 'Webroot_Action'
            'HP_Wolf_Action' {
                # Custom sort function to handle wildcards in the sortOrder array
                # This function returns the index of the matching display name in the sortOrder array
                # or [int]::MaxValue if no match is found, which will sort it to the end of the list
                function Get-SortIndex {
                    param (
                        [string]$displayName
                    )
                    for ($i = 0; $i -lt $sortOrder.Count; $i++) {
                        if ($sortOrder[$i] -like $displayName) {
                            return $i
                        }
                    }
                    return [int]::MaxValue
                }
                function Uninstall-HPWolf {
                    # Retrieve HP Wolf Security entries from the Registry
                    $HP_Wolf = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*HP*security*" -or $_.DisplayName -like "*HP*Sure*" }
                    if ($HP_Wolf) {
                        # Define a custom sort order for uninstallation (see https://enterprisesecurity.hp.com/s/article/How-to-uninstall-HP-Wolf-Pro-Security)
                        $sortOrder = @(
                            "HP Wolf Security"
                            "HP Wolf Security - Console"
                            "HP Security Update Service"
                            "HP Wolf Security Application Support for Sure Sense"
                            "HP Wolf Security Application Support for Office"
                            "HP Wolf Security Application Support for Chrome*"
                            "HP Sure*"
                        )
                        # $sorted_HP_Wolf = $HP_Wolf | Sort-Object -Property { $sortOrder.IndexOf($_.DisplayName) }
                        # Not using this ^ since I need to account for wilcards in the $sortOrder array                       
                        $sorted_HP_Wolf = $HP_Wolf | Sort-Object -Property { Get-SortIndex $_.DisplayName }
                        Write-Host -ForegroundColor Green "The following HP Wolf Security products are installed on the machine:"
                        $sorted_HP_Wolf.DisplayName
                        $Answer = Read-Host "`nUninstall the HP products listed above? ('Y' to uninstall silently / 'B' to uninstall with basic UI / 'C' to choose which to uninstall (no UI) / 'N' to cancel)"
                        if ($Answer -eq 'Y' -or $Answer -eq 'B') {
                            foreach ($App in $sorted_HP_Wolf) {
                                Write-Host -ForegroundColor Green "`nUninstalling $($App.DisplayName)"
                                $UninstallString = $App.UninstallString.Replace('/I', '/X')
                                if ($Answer -eq 'Y') {
                                    # Execute a silent uninstall in the background with no UI.
                                    $UninstallCommand = "$uninstallString /qn /noreboot REBOOT=REALLYSUPPRESS"
                                }
                                elseif ($Answer -eq 'B') {        
                                    # Execute a silent uninstall with a basic UI.
                                    $UninstallCommand = "$uninstallString /qr /noreboot REBOOT=REALLYSUPPRESS"
                                }
                                cmd.exe /c $UninstallCommand 
                                # Start-Process cmd -ArgumentList "/c $($UninstallCommand)" -NoNewWindow
                            } # foreach
                        } # if 'Y' or 'B'
                        elseif ($Answer -eq 'C') {
                            foreach ($App in $sorted_HP_Wolf) {
                                $UninstallString = $App.UninstallString.Replace('/I', '/X')
                                # Execute a silent uninstall in the background with a basic UI.
                                # $UninstallCommand = "$uninstallString /qr /noreboot REBOOT=REALLYSUPPRESS"
                                # Execute a silent uninstall in the background with no UI.
                                $UninstallCommand = "$uninstallString /qn /noreboot REBOOT=REALLYSUPPRESS"
                                $Answer = Read-Host "`nUninstall $($App.DisplayName)? (Y/N)"
                                if ($Answer -eq 'Y') {
                                    Write-Host -ForegroundColor Green "`nUninstalling $($App.DisplayName)"
                                    cmd.exe /c $UninstallCommand
                                    # Start-Process cmd -ArgumentList "/c $($UninstallCommand)" -NoNewWindow
                                }
                                else {
                                    Write-Host "Cancelling uninstall of $($App.DisplayName)."
                                }   
                            } # foreach
                        } # elseif 'C' 
                        else {
                            Write-Host -ForegroundColor Green "Uninstallation canceled.`nExiting Script."
                            break
                        } # else 'N'  
                    } # if $HP_Wolf
                    else {
                        Write-Host "No HP Wolf Security products found."
                    } # if !$HP_Wolf
                    function Unregister-HPWolf {
                        $AVP = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).DisplayName
                        if ($AVP -match "Wolf") {
                            Write-Host "================================================"
                            Write-Host -ForegroundColor Green "`nAVs registered with the Windows Security Center:"
                            $AVP
                            $Answer = Read-Host "`nUnregister HP Wolf Security from the Windows Security Center? (Y/N)`n(Only choose 'Y' if the main HP Wolf security products successfully uninstalled.)"
                            if ($Answer -eq 'Y') {
                                Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object DisplayName -like "*HP Wolf*" | Remove-WmiObject
                                $AVP = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).DisplayName
                                Write-Host -ForegroundColor Green "`nAVs still registered with the Windows Security Center:"  
                                $AVP
                            }
                            else {
                                Write-Host -ForegroundColor Green "NOT unregistering HP Wolf from the Windows Security Center."
                            }   
                        } # if HP Wolf is registered in WSC  
                    } # function Unregister-HPWolf
                    Unregister-HPWolf 
                } # Function Uninstall-HPWolf   
                Uninstall-HPWolf    
            } # if ParameterSet 'HP_Wolf_Action'
            'IE' {
                & 'C:\Program Files\Internet Explorer\iexplore.exe'
            } # if ParameterSet 'IE'
            'RMM' {
                $Apps = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue
                $Folders = Get-ChildItem 'C:\Program Files', 'C:\Program Files (x86)'
                $RMMs = @()
                if (($Apps.DisplayName -like "*kaseya*") -and ($Folders.Name -contains "Kaseya") -and (Get-Process KaseyaEndpoint -ErrorAction SilentlyContinue)) {
                    $RMMs += "KaseyaEndpoint"
                }
                if (($Folders.Name -like "Advanced Monitoring Agent") -and (Get-Process winagent -ErrorAction SilentlyContinue)) {
                    $RMMs += "N-Able"
                }
                if ($RMMs) {
                    Write-Host -ForegroundColor Green "Other RMM tools found on this machine:"
                    $RMMs  
                }
                break
            } # if ParameterSet 'RMM'
            'PendingReboot' {
                # checks if machine is pending a reboot using the below PowerShell module from Brian Wilhite
                # https://www.powershellgallery.com/packages/PendingReboot/0.9.0.6
                if (!(Get-Module PendingReboot -ListAvailable)) {
                    if ("NuGet" -notin (Get-PackageProvider).Name) {
                        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null
                    }
                    if ((Get-PSRepository -Name 'PSGallery').InstallationPolicy -ne 'Trusted') {
                        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
                    }
                    Install-Module -Name PendingReboot -Confirm:$false
                } # if module not installed
                $ExecutionPolicy = Get-ExecutionPolicy
                if ($ExecutionPolicy -eq "Restricted") {
                    Set-ExecutionPolicy RemoteSigned
                }
                Import-Module PendingReboot
                Test-PendingReboot -SkipConfigurationManagerClientCheck -Detailed   
                if ($ExecutionPolicy -eq "Restricted") {
                    Set-ExecutionPolicy Restricted
                }            
            } # if ParameterSet 'PendingReboot'       
            Default {
                Write-Verbose -Message "Retrieving AVs by querying services"
                $Services = Get-Service -DisplayName *vipre*, *SBAMSvc*, *defend*, *trend*, *sophos*, *eset*, *symantec*, *webroot*, *cylance*, *mcafee*, *avg*, `
                    *santivirus*, *segurazo*, *avira*, *norton*, *malware*, *kaspersky*, *sentinel*, *avast*, *spyware*, *spybot*, *WRCoreService*, *WRSkyClient*, *WRSVC*, `
                    *WRSMSVC*, *CrowdStrike*, *Rapport*, *Reason*, '*Cisco Secur*', '*HP Sure*', 'HP Security Update Service', '*SAS Core*', "360 Total Security" `
                    -Exclude *firewall*, '*AMD Crash*', '*LDK License Manager', '*Sophos Connect*', '*Avast SecureLine VPN*', '*browser*', '*%1!s! Update Service*' -ErrorAction SilentlyContinue
                # , '*Take Control Agent*', '*N-able Remote*'
        
                Write-Verbose -Message "Retrieving AVs registered with the Windows Security Center (by querying WMI)"
                # The AVs registered with the Windows Security Center are stored in the Registry at 'HKLM:\SOFTWARE\Microsoft\Security Center\Provider\Av\*'.
                # You can't edit that part of the Registry directly. One way to interface with that is by using WMI.
                # For a GUI option use WBEMTEST (https://support.cloudradial.com/hc/en-us/articles/360049084271-Removing-Old-Antivirus-Listings-from-Security-Center)
                # Or from PowerShell run: Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object displayname -like *<AV_To_Delete>* | ForEach-Object { $_.Delete() }
                if ( (Get-WmiObject Win32_OperatingSystem).producttype -ne 1 ) {
                    # Servers don't have the 'securitycenter2' namespace
                    $Server = $true
                    $AV = Get-CimInstance -Namespace root\Microsoft\protectionmanagement -class MSFT_MpComputerStatus -ErrorAction SilentlyContinue
                } # if server OS
                else {
                    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
                        $AV_antivirus = Get-CimInstance antivirusproduct -Namespace root\securitycenter2 -ErrorAction SilentlyContinue -Verbose:$false
                        $AV_antispyware = Get-CimInstance antispywareproduct -Namespace root\securitycenter2 -ErrorAction SilentlyContinue -Verbose:$false
                        $AV = $AV_antivirus , $AV_antispyware
                    } # if Get-CimInstance
                    else {
                        $AV_antivirus = Get-WmiObject antivirusproduct -Namespace root\securitycenter2 -ErrorAction SilentlyContinue -Verbose:$False
                        $AV_antispyware = Get-WmiObject antispywareproduct -Namespace root\securitycenter2 -ErrorAction SilentlyContinue -Verbose:$False
                        $AV = $AV_antivirus , $AV_antispyware
                    } # if !Get-CimInstance
                } # if non-server OS

                Write-Verbose "Retrieving AVs by querying the Registry"
                $RegAV = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Security Center\Provider\Av\*' -ErrorAction SilentlyContinue
        
                if ($Bitdefender) {
                    Write-Verbose -Message "Retrieving Bitdefender info"
                    if ($BDProc = Get-Process EPSecurityService -ErrorAction SilentlyContinue) {
                        # Bitdefender definitions update info
                        $UpdateStatus = & "C:\Program Files\Bitdefender\Endpoint Security\product.console.exe" /c GetUpdateStatus antivirus
                        # Bitdefender version number
                        $BDVersion = & 'C:\Program Files\Bitdefender\Endpoint Security\product.console.exe' /c GetVersion antivirus
                        Write-Verbose "Performing epoch time conversion"
                        try {
                            # save last update time to variable
                            $EpochTimeUpdate = ($UpdateStatus.Split(': ')[2]).split('')[0]
                            # convert from epoch time to standard time
                            $ConvertedUpdateTime = (([System.DateTimeOffset]::FromUnixTimeSeconds($EpochTimeUpdate)).DateTime)
                            # save last attempted update time to variable
                            $EpochTimeAttempt = ($UpdateStatus.Split(': ')[5]).split('')[0]
                            # convert from epoch time to standard time
                            $ConvertedAttemptTime = (([System.DateTimeOffset]::FromUnixTimeSeconds($EpochTimeAttempt)).DateTime)
                            # last update exit status
                            $Num = $UpdateStatus.Split(': ')[8]
                            if ($Num -eq '0') {
                                $Var = $true
                            }
                            else {
                                $Var = $false
                            }
                            $BDProps = [Ordered]@{
                                'Product version'                   = $BDProc.FileVersion
                                'Engine version'                    = $BDVersion
                                'Definitions last updated'          = $ConvertedUpdateTime
                                'Definitions update last attempted' = $ConvertedAttemptTime
                                'Last update successfull'           = $Var
                            }
                            $BDVar = New-Object -TypeName psobject -Property $BDProps
                        } # try
                        catch {
                            # suppresses the error that occurs when attempting to call a method on a null-valued expression, 
                            # which happens when Bitdefender feeds error codes to $UpdateStatus instead of meaningful data
                        }
                    } # if $BDProc
                    else {
                        $BDVar = "Bitdefender is either not installed or else not running."
                    } # else $BDProc
                } # if $BitDefender
                if ($Vipre) {
                    try {
                        Write-Verbose -Message "Retrieving Vipre info"
                        if (Get-Process SBAM* -ErrorAction Stop) {
                            if (!(Get-Process SBAMTray -ErrorAction SilentlyContinue)) { Start-Process 'C:\Program Files (x86)\Vipre Business Agent\SBAMTray.exe' } # For when SBAMSvc is running, while SBAMTray is not
                            # check that SBAMCommandLineScanner is working before AP check and if not output error message
                            $SBAMAPState = & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /apstate
                            if ($SBAMAPState[0] -eq "ERROR:Couldn't access service interface") { $SBAMMessage = "SBAMCommandLineScanner is not working" } else { $SBAMMessage = $SBAMAPState }
                            # check that SBAMCommandLineScanner is working before Defs check and if not output error message
                            $SBAMDefs = & 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /displaylocaldefversion
                            if ($SBAMDefs[0] -eq "ERROR:Couldn't access threat definition interface") { $SBAMMessage1 = "SBAMCommandLineScanner is not working" }
                            $VipreVar = Get-Process SBAMTray -ErrorAction SilentlyContinue | Select-Object -First 1 | Format-Table `
                            @{ n = 'Vipre Version'; e = { $_.FileVersion } },
                            @{ n = 'Active Protection State'; e = { $SBAMMessage } }, 
                            @{ n = 'Date/Time definitions last updated'; e = { if ($SBAMMessage1) { $SBAMMessage1 } else { $Date = (& 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /displaylocaldefversion).Substring('9'); $Date1 = $Date.split('T'); "Date: $($Date1[0]) Time: $($Date1[1])" } } }
                            #[datetime](($var -split '- ')[1])
                        }
                        elseif ((Get-Service SBAMsvc -ErrorAction SilentlyContinue).StartType -eq 'Disabled') { 
                            $VipreVar = "Vipre is installed, but SBAMSvc is in a disabled state.`nTo enable the service and start it, re-run Get-AVInfo with the 'EnableVipre' parameter."
                        }
                        else { 
                            $VipreVar = "Vipre is either not installed or else not running." 
                        } # if SBAM*
                    }
                    catch {
                        $Message = $($Error[0])
                    }
                    
                    # check for AP in disabled state while defs download and update for the first time after a Vipre install
                    if ( ($SBAMAPState -eq 'Disabled') -and ((Get-ChildItem "C:\Program Files (x86)\VIPRE Business Agent\Definitions\Beetle\*" -ErrorAction SilentlyContinue).Name -like "*_PENDING*" )) {
                        $VipreUpdateStatus = 1
                        $DefsMessage = "Vipre Active protection is disabled. Vipre definitions are currently updating.`nIf you just installed Vipre please wait for the definitions update to complete and then check on the Active Protection again."
                    }

                    if ( $PSVersionTable.PSVersion.Major -ne 2 ) { 
                        # no Invoke-WebRequest in PS version 2
                        Write-Verbose "Checking if machine can reach intellisecure.myvipre.com"
                        try {
                            $Pref = $ProgressPreference
                            $ProgressPreference = 'SilentlyContinue'
                            $WebFilter = (Invoke-WebRequest intellisecure.myvipre.com -UseBasicParsing -ErrorAction Stop -Verbose:$false).content 
                            $ProgressPreference = $Pref
                            if ($WebFilter -like "*<title>Website Filtered</title>*") {
                                $Blocked = "`nThe machine cannot reach out to Vipre on domain intellisecure.myvipre.com. It may be blocked by a web content filter, or other network issue."
                            }
                        }
                        catch {
                            $Blocked = "Failed to test connection to intellisecure.myvipre.com. `nPlease test manually if services won't start, or if Vipre is otherwise not working as expected."
                        } 
                    } # if PowerShell version 2

                    Write-Verbose "Testing for ARM Processor"
                    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
                        if ((Get-CimInstance Win32_Processor -Verbose:$false).Caption -like "*arm*") {
                            $ARM = "ARM processor detected. Vipre is not compatible with this machine."
                        } 
                    } # if Get-Command

                    Write-Verbose "Testing for Vipre version 12.0 "
                    if ( ( (Get-Process SBAM* | Select-Object -First 1).FileVersion -like "12.0*" ) -and 
                        ( (& 'C:\Program Files*\VIPRE Business Agent\SBAMCommandLineScanner.exe' /apstate) -eq "Disabled" ) ) {
                        $Buggy_Version = "Vipre 12.0.x is installed. There is a bug in version 12.0 that prevents Vipre Active Protection from turning on. If you can't enable Active Protection, install Vipre version 12.3 or higher and try again."
                    } # if Get-Process
                } # if $Vipre
                elseif (!$DefaultOverride -or $WindowsDefender) {
                    if ( ((Get-WmiObject Win32_OperatingSystem).producttype -ne 1 ) -and ((Get-WindowsFeature -Verbose:$false | Where-Object { $_.Name -like 'windows-defender' }).Installed) -eq $false ) {
                        $FeatureNotInstalled = $true
                    } # if running server OS
                    else {
                        try {
                            Write-Verbose -Message "Retrieving Windows Defender info"
                            $WDStatus = Get-MpComputerStatus -ErrorAction Stop
                            # $WDPreference = Get-MpPreference -ErrorAction Stop
                            # $WDServices = $WDStatus | Select-Object *enable*
                            $WDProps = [Ordered]@{
                                'AMServiceEnabled'                                                  = $WDStatus.AMServiceEnabled
                                'AntispywareEnabled'                                                = $WDStatus.AntispywareEnabled
                                'AntivirusEnabled'                                                  = $WDStatus.AntivirusEnabled
                                'BehaviorMonitorEnabled'                                            = $WDStatus.BehaviorMonitorEnabled
                                'IoavProtectionEnabled (Scan all downloaded files and attachments)' = $WDStatus.IoavProtectionEnabled
                                'NISEnabled (Network Realtime Inspection)'                          = $WDStatus.NISEnabled
                                'OnAccessProtectionEnabled (file and program activity monitoring)'  = $WDStatus.OnAccessProtectionEnabled
                                'RealTimeProtectionEnabled'                                         = $WDStatus.RealTimeProtectionEnabled
                                #'Reboot Required'                                                   = $WDStatus.RebootRequired
                            }
                            $WDObjEnabled = New-Object -TypeName psobject -Property $WDProps
                            <#    
                        $Props = [Ordered]@{
                            'Signatures version'               = $WDStatus.AntispywareSignatureVersion
                            'Version created on'               = $WDStatus.AntispywareSignatureLastUpdated
                            'Last update in days (0 is today)' = $WDStatus.AntispywareSignatureAge
                            # the below boolean value is only accurate if wuaserv is running, otherwise it will show false even if signatures are out of date
                            'Signatures out of date'           = $WDStatus.DefenderSignaturesOutOfDate
                        }
                        #>
                            $Props = [Ordered]@{
                                'Antivirus Signatures'   = $WDStatus.AntivirusSignatureLastUpdated
                                'Antispyware Signatures' = $WDStatus.AntispywareSignatureLastUpdated
                                'NIS Signatures'         = $WDStatus.NISSignatureLastUpdated
                            }
                            $WDObj = New-Object -TypeName psobject -Property $Props

                            $Props_detailed = [Ordered]@{
                                'Antispyware Signatures created on' = $WDStatus.AntispywareSignatureLastUpdated
                                'Antispyware Signatures age'        = $WDStatus.AntispywareSignatureAge
                                'Antispyware Signatures version'    = $WDStatus.AntispywareSignatureVersion
                                "`nAntivirus Signatures created on" = $WDStatus.AntivirusSignatureLastUpdated
                                'Antivirus Signatures age'          = $WDStatus.AntivirusSignatureAge
                                'Antivirus Signatures version'      = $WDStatus.AntivirusSignatureVersion
                                "`nNIS Signatures created on"       = $WDStatus.NISSignatureLastUpdated
                                'NIS Signatures age'                = $WDStatus.NISSignatureAge
                                'NIS Signatures version'            = $WDStatus.NISSignatureVersion
                            }
                            $WDObj_detailed = New-Object -TypeName psobject -Property $Props_detailed
                        } # try
                        catch {
                            $WDMessage = $($Error[0])
                        }
                    } # if not running server OS
                    Write-Verbose 'Checking WD UILockdown status'
                    $UIStatus = (Get-ItemProperty 'hklm:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration\' -ErrorAction SilentlyContinue).UILockdown

                    Write-Verbose 'Checking Windows Defender Tamper Protetion'
                    if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
                        $TPStatus = (Get-MpComputerStatus -ErrorAction SilentlyContinue).IsTamperProtected
                    }
                    else {
                        $TPStatus = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\' -ErrorAction SilentlyContinue).TamperProtection
                    }

                    Write-Verbose "Checking value of Windows Defender Registry keys"
                    $RegKey = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue).DisableAntiSpyware,
                    (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue).DisableAntiVirus,
                    (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -Name 'DisableAntiVirus' -ErrorAction SilentlyContinue).DisableAntiVirus

                    <#
                    if ( ($RegKey -contains 1) -and ($WDStatus.AntispywareSignatureAge -gt 1) ) {
                        if ( (Get-Service wuauserv).Status -eq 'Stopped') {
                            $WU = Read-Host "Windows Defender signatures are out of date. The Windows Update service is not running.`nStart the service? (Y/N)"
                            if ($WU -eq 'Y') {
                                try {
                                    Write-Verbose "Attempting to start the wuauserv service"
                                    Start-Service wuauserv -ErrorAction Stop
                                }
                                catch {
                                    Write-Verbose "Failed to start the service"
                                    Write-Verbose "Attempting to disable and then re-enable the wuauserv service"
                                    Set-Service wuauserv -StartupType Disabled
                                    Set-Service wuauserv -StartupType Manual -Status Running
                                }
                                if ( (Get-Service wuauserv).Status -eq 'Running' ) {
                                    Write-Host "wuauserv service successfully started`nUpdating Windows Defender signatures.."
                                    & 'C:\Program Files\Windows Defender\MpCmdRun.exe' -signatureupdate
                                }
                                else {
                                    Write-Warning "Could not successfully start the wuauserv service. Please look into this."
                                }
                            } # if answer 'Y'
                            elseif ($WU -eq 'N') {
                                Write-Host -ForegroundColor Yellow "NOT starting the wuauserv service"
                            } # if answer 'N'
                        } # if wuauserv is stopped
                    } # if signatures out of date more than 1 day
                    #>

                    Write-Verbose "Checking for the presence and value of the 'Real-Time Protection' Registry key"
                    $RTP_Key = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -ErrorAction SilentlyContinue
                    # checking for disabled Windows Defender services
                    # converting from ordered dictionary to array for enumeration purposes
                    $Array2 = @($WDProps.Values)
                    foreach ($A in $Array2) {
                        if ($A -ne $true) { $WD_Services_Disabled = $true; break }
                    } # foreach
                    if (!$RTP_Key -and $WD_Services_Disabled) {
                        $RTP_Message = "The 'Real-Time Protection' Registry key is not present on this machine. One or more of the Windows Defender engines listed above are not enabled. Assuming no third-party AVs are running, try setting the 'Turn off real-time protection' setting in Local Group Policy to 'Disabled' and re-run this script." 
                    } # if !$RTP_Key
                    elseif (($RTP_Key).DisableRealtimeMonitoring -eq 1) { 
                        $RTP_Message = "The 'DisableRealtimeMonitoring' reg key is set to 1. One or more of the Windows Defender engines listed above are not enabled. Assuming no third-party AVs are running, try setting the 'Turn off real-time protection' setting in Local Group Policy to 'Disabled'." 
                    } # elseif $RTP_Key

                    if ($Server) {
                        # checking if the Windows-Defender feature is installed on the server
                        Write-Verbose "Checking for the Windows-Defender feature"
                        $Pref = $ProgressPreference
                        $ProgressPreference = 'SilentlyContinue'
                        $WD_Feature = (Get-WindowsFeature -Verbose:$false | Where-Object { $_.Name -like 'windows-defender' }).Installed
                        $ProgressPreference = $Pref
                        if ($WD_Feature -eq $false) {
                            $Server_Message = "The Windows-Defender feature is not installed on this server. To install, remove any 3rd party AVs then run 'Get-AVInfo -InstallWDFeature'."
                        }
                    }
                } # elseif !$DefaultOverride -or $WindowsDefender

                if (Test-Path 'C:\Program Files\Sophos' -PathType Container) {
                    Write-Verbose "Checking Sophos Tamper Protection status"
                    # https://support.sophos.com/support/s/article/KB-000043008?language=en_US
                    try {
                        $Sophos = & 'C:\Program Files\Sophos\Endpoint Defense\SEDcli.exe' -status
                    }
                    catch {}
                    if ($Sophos -like "*Enabled*") {
                        $SophosTPEnabled = $true
                    }
                }

                if (Test-Path 'C:\Program Files (x86)\Trend Micro' -PathType Container) {
                    Write-Verbose "Checking Trend Micro Tamper Protection status"
                    try {
                        $TrendTP = (Get-ItemProperty 'HKLM:\SOFTWARE\\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion\Misc.' -ErrorAction SilentlyContinue).('Allow Uninstall')
                    }
                    catch {}
                    if ($TrendTP -eq '0') {
                        $TrendTPEnabled = $true
                    }
                }

                # if ( (Get-ItemProperty hklm:\SOFTWARE\LabTech\Service -ErrorAction SilentlyContinue).clientID -eq 113 ) {
                if ( $env:NINJA_ORGANIZATION_NAME -eq 'Beth Tfiloh' ) {
                    $BT = "This machine is at BT. BT uses Sophos."
                }


                # If SentinelOne is present, check for SentinelOne tamper protection
                if (Test-Path 'C:\Program Files\SentinelOne' -PathType Container) {
                    Write-Verbose "Checking SentinelOne tamper protection status"
                    
                    $TamperProtection = & 'C:\Program Files\SentinelOne\Sentinel Agent*\sentinelctl.exe' configure | Select-String -Pattern "agent.antiTampering", "agent.safeBootProtection"
                    
                    $TamperProtection = & 'C:\Program Files\SentinelOne\Sentinel Agent*\sentinelctl.exe' configure | 
                    Select-String -Pattern "agent.antiTampering", "agent.safeBootProtection" | 
                    ForEach-Object {
                        # Split the line into key and value, then trim and format
                        $Parts = $_.Line -split '\s{2,}' # Split on two or more spaces
                        "{0,-30} {1}" -f $Parts[0].Trim(), $Parts[1].Trim()
                    }
                    
                    if ($TamperProtection) {
                        $SentinelOneTamperProtection = $true
                    }    
                } # if SentinelOne present
                
            
                Write-Verbose "Testing for the presence of the Techloq content filter"
                if (Get-Process WindowsFilterAgentWPFClient -ErrorAction SilentlyContinue | Where-Object { $_.Company -eq 'Techloq' }) {
                    $Techloq = "The Techloq content filter is installed and running on this machine."
                }

                if ($MachineInfo -and (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
                    Write-Verbose -Message "Retrieving OS info" 
                    # Verbose messages from Get-CimInstance are suppressed, even if the -Verbose parameter is specified when running the function
                    $BIOS = Get-CimInstance -ClassName win32_Bios -Verbose:$false
                    $OS = Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$false
                    $UT = (Get-Date) - $OS.LastBootUpTime # needed for formating the timespan object for on-screen output
                    $CS = Get-CimInstance -ClassName Win32_ComputerSystem -Verbose:$false
                    $SD = $OS.SystemDrive
                    $LD = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceId='$SD'" -Verbose:$false
                    $Manufacturer = (Get-CimInstance -ClassName Win32_bios -Verbose:$false).Manufacturer
                    if ($CS.Manufacturer) {
                        $M = $CS.Manufacturer
                    }
                    else {
                        $M = $Manufacturer
                    }
                    $FastBoot = (Get-ItemProperty 'HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Power\').HiberBootEnabled
                  
                    $Props = [Ordered]@{
                        'SerialNumber'                         = $BIOS.SerialNumber
                        'WindowsVersion'                       = $OS.Caption
                        'BuildNumber'                          = $OS.BuildNumber
                        'Domain'                               = $CS.Domain
                        'UserName'                             = $CS.UserName
                        'Manufacturer'                         = $M
                        'Model'                                = $CS.Model
                        'Architecture'                         = $OS.OSArchitecture
                        'Total Installed Memory (GB, rounded)' = $CS.TotalPhysicalMemory / 1GB -as [int]
                        'SysDriveSize (GB)'                    = $LD.Size / 1GB -as [int]
                        'SysDriveFreeSpace (GB)'               = $LD.FreeSpace / 1GB -as [int]
                        'LastBootTime'                         = $OS.LastBootUpTime
                        'Uptime'                               = "{0:dd}d: {0:hh}h: {0:mm}m" -f $UT
                        'FastBoot'                             = if ( $null -ne $FastBoot ) { if ($FastBoot -eq 0) { 'Not enabled' } else { 'Enabled' } } else { 'RegKeyNotPresent' }
                    }
                    $Obj = New-Object -TypeName psobject -Property $Props
                } # if $MachineInfo

                if ($AVFolders -or $DeleteAVFolders) {
                    Write-Verbose "Looking for AV folders"
                    $Name = "*vipre*", "*trend*", "*sophos*", "*symantec*", "*eset*", "*webroot*", "*cylance*", "*mcafee*", "*avg*", "*santivirus*", "*segurazo*", "*avira*", "*norton*", `
                        "*malware*", "*kaspersky*", "*sentinel*", "*avast*", "*spyware*", "*spybot*", "*WRCore*", "*WRData*", "*Trusteer*", "*SuperAntiSpyware*", "*CrowdStrike*", `
                        "*Managed Antivirus*", "*ReasonLabs*", "Bitdefender", "bdkitinstaller", "bdlogging", "*Cisco*", "*Cybereason*". "*ITbrain*" #,"*N-able*"
                    $Folders = Get-Item -Path 'C:\Program Files\*', 'C:\Program Files (x86)\*', 'C:\ProgramData\*' -Include $Name -Exclude "*RemoteSetup*", "*SafeNet*" -ErrorAction SilentlyContinue
                    $AV_Folders = $Folders | Select-Object @{n = 'FolderName'; e = { $_.Name } }, @{n = 'FullPath'; e = { $_.FullName } }, CreationTime
                    if ($DeleteAVFolders) {
                        if (!$AV_Folders) {
                            Write-Host -ForegroundColor Green "No AV folders to delete.`nExiting."
                            break
                        }
                        Write-Host -ForegroundColor Green "`nAV folder(s) on the machine (excluding Windows Defender):"
                        $AV_Folders | Sort-Object FolderName, FullPath | Format-Table
                        $Answer2 = Read-Host "Delete the above folder(s)? (Y/N)"
                        if ($Answer2 -eq 'Y') {
                            Write-Verbose "Deleting the AV folder(s)"
                            Remove-Item $Folders -Recurse -Force
                            $Folders1 = Get-Item -Path 'C:\Program Files\*', 'C:\Program Files (x86)\*', 'C:\ProgramData\*' -Include $Name -Exclude "*RemoteSetup*" -ErrorAction SilentlyContinue
                            $AV_Folders1 = $Folders1 | Select-Object @{n = 'FolderName'; e = { $_.Name } }, @{n = 'FullPath'; e = { $_.FullName } }, CreationTime
                            Write-Host -ForegroundColor Green "`nAV folder(s) still on the machine (excluding Windows Defender):"
                            $AV_Folders1 | Sort-Object FolderName, FullPath | Format-Table
                            break
                        }
                        elseif ($Answer2 -eq 'N') {
                            Write-Host -ForegroundColor Green "NOT deleting AV folders`nExiting"
                            break
                        }
                    } # if $DeleteAVFolders
                } # if $AVFolders -or $DeleteAVFolders

                Write-Verbose -Message "Writing results to the screen"

                Write-Host -ForegroundColor Green "`nAntivirus services present on the machine:"
                if (!$Services) {
                    Write-Output `n
                }
                else {
                    Write-Output $Services | Sort-Object DisplayName | Format-Table Status, StartType, Name, DisplayName -AutoSize
                }

                if ($IncludeProcesses) {
                    Write-Debug "start IncludeProcesses"
                    Write-Host -ForegroundColor Green "`nAntivirus processes running on the machine (tied to the services listed above):"
                    $WMI_Services = Get-WmiObject Win32_Service | Where-Object { $_.Name -in $Services.Name }
                    if ($WMI_Services) {
                        $Processes = @()
                        foreach ($S in $Services) {
                            $ProcessID = ($WMI_Services | Where-Object { $_.Name -eq $S.Name }).ProcessID
                            if ($ProcessID -ne 0) {
                                $Proc = Get-Process -Id $ProcessID
                                $Processes += $Proc
                            }
                        }
                        Write-Output $Processes | Format-Table `
                        @{n = "ServiceName"; e = { ($WMI_Services | Where-Object ProcessID -eq ($_.Id)).Name } },
                        @{n = "ProcessName"; e = { $_.Name } }, 
                        @{n = "ProcessID"; e = { $_.Id } }, 
                        StartTime, Company -AutoSize    
                    }
                    if (!$WMI_Services -or !$Processes) {
                        # if $WMI_Services is empty or if no processes with id not equal to 0 were found
                        Write-Host "No processes (with the process ID not equal to 0) found for the services listed above.`n"
                    }
                    Write-Debug "end IncludeProcesses"
                } # if $IncludeProcesses
                
                Write-Host -ForegroundColor Green "Antivirus software registered with the Windows Security Center (queried from the SecurityCenter2 namespace using WMI):"
                # using "if ($AV.Count -eq 0)" as opposed to "if (!$AV)" to account for $AV existing but as an empty array
                if ( ($AV | Measure-Object).Count -eq 0 ) {
                    Write-Warning "Failed to retrieve the Antivirus software from the SecurityCenter2 namespace."
                    Write-Host "`n"
                }
                else {
                    if ($Server) {
                        Write-Host -ForegroundColor Yellow "Not relevant to machines running server OS."
                        # $AV | Format-List AMRunningMode, *enabled*
                    }
                    else {
                        <#
                        # Based on https://www.cyberdrain.com/monitoring-with-powershell-chapter-2-anti-virus-installation-status/
                        $uniqueProductStates = $AV[0] | Sort-Object DisplayName | Select-Object -Unique productState
                        foreach ($state in $uniqueProductStates) {
                            switch ($state.productState) {
                                "262144" { $UpdateStatus = "Up to date" ; $RealTimeProtectionStatus = "Disabled" }
                                "262160" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Disabled" }
                                "266240" { $UpdateStatus = "Up to date" ; $RealTimeProtectionStatus = "Enabled" }
                                "266256" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Enabled" }
                                "393216" { $UpdateStatus = "Up to date" ; $RealTimeProtectionStatus = "Disabled" }
                                "393232" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Disabled" }
                                "393488" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Disabled" }
                                "397312" { $UpdateStatus = "Up to date" ; $RealTimeProtectionStatus = "Enabled" }
                                "397328" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Enabled" }
                                "397584" { $UpdateStatus = "Out of date" ; $RealTimeProtectionStatus = "Enabled" }
                                "397568" { $UpdateStatus = "Up to date"; $RealTimeProtectionStatus = "Enabled" }
                                "393472" { $UpdateStatus = "Up to date" ; $RealTimeProtectionStatus = "Disabled" }
                                default { $UpdateStatus = "Unknown" ; $RealTimeProtectionStatus = "Unknown" }
                            }
                            $productStateDescriptions += "ProductState: $($state.productState) - UpdateStatus: $UpdateStatus, RealTimeProtectionStatus: $RealTimeProtectionStatus"
                            Write-Host -ForegroundColor Cyan ($productStateDescriptions -join " / ")
                            Write-Debug "ProductState Switch"
                        } # foreach $state
                        #>

                        # Combine the two arrays in $AV and flatten them (to expose the properties from both CIM queries/arrays to Sort-Object) and remove null values
                        Write-Output $AV | ForEach-Object { $_ } | Where-Object { $_ } | Sort-Object DisplayName | Format-Table DisplayName, ProductState, TimeStamp, InstanceGUID -AutoSize -Wrap
                    } # if -not $Server
                } # else $AV

                Write-Host -ForegroundColor Green "`nAntivirus software as seen in the Registry:"
                if (!$RegAV) {
                    if ( (Get-WmiObject Win32_OperatingSystem).Caption -like '*7*' ) {
                        Write-Warning "This machine is running Windows 7.`nAntivirus info is not logged in the usual place in the Registry."
                    }
                    elseif ($Server) {
                        Write-Host -ForegroundColor Yellow "Not relevant to machines running server OS."
                    }
                    else {
                        Write-Warning "Failed to retrieve Antivirus software from Registry."
                    }
                    Write-Host "`n"
                }
                else {
                    Write-Output $RegAV | Sort-Object DisplayName | Format-Table DisplayName, State, GUID -AutoSize -Wrap
                }

                if ($Bitdefender) {
                    Write-Host -ForegroundColor Green "Bitdefender Product and Engine (antimalware signatures) versions:"
                    $BDVar | Format-List
                }
                elseif ($Vipre) {
                    Write-Host -ForegroundColor Green "Version of Vipre on the machine, and the date the definitions last updated:"
                    if ($Message) {
                        Write-Warning "Error retrieving Vipre info.`nError message:`n$($Message) "
                    }
                    else {
                        Write-Output $VipreVar
                        if ($VipreUpdateStatus -eq 1) {
                            Write-Host -ForegroundColor Cyan "$($DefsMessage)"
                        }
                    }
                    Write-Host -ForegroundColor Cyan "$($Blocked)"  
                } # elseif $Vipre
                elseif (!$DefaultOverride) {
                    if ($FeatureNotInstalled) {
                        Write-Host -ForegroundColor Green "This machine is running server OS and the Windows Defender feature is NOT installed."
                    }
                    elseif ($WDMessage) {
                        Write-Host -ForegroundColor Green "Windows Defender Info:"
                        Write-Warning "Error retrieving Windows Defender info.`nError message: $($WDMessage)"
                    }
                    else {
                        Write-Host -ForegroundColor Green "Windows Defender base engines:"
                        $WDObjEnabled | Format-List
                        Write-Host -ForegroundColor Cyan $RTP_Message
                        if ($WDSignaturesDetailed) {
                            Write-Host -ForegroundColor Green "Windows Defender Signatures:"
                            $WDObj_detailed | Format-List
                        }
                        else {
                            Write-Host -ForegroundColor Green "Windows Defender Signatures last updated:"
                            $WDObj | Format-List
                        }
                    }
                    if ( $RegKey -and ($RegKey -contains 1) ) {
                        Write-Host -ForegroundColor Green "Windows Defender Registry key:"
                        # "Windows Defender is disabled via the 'DisableAntiSpyware' Registry key at the following location: $($RegKey.PSPath.split('::')[2]).`nTo re-enable, either set the value back to '0', delete the key, or simply re-run this script with the 'EnableWDRegKey' parameter (use the 'EnableWD' parameter to then turn on Windows Defender)."
                        Write-Host -ForegroundColor Red "Windows Defender is disabled in the Registry."#"`nTo re-enable, assuming no third-part AVs are running, either set the value of the applicable key(s) back to '0', delete the key(s), or simply re-run this script with the 'EnableWDRegKey' parameter (use the 'EnableWD' parameter to then turn on Windows Defender)."
                        #"`nNote: If Group Policy is configured to disable Windows Defender, the registry key will revert back to '1', with the next group policy update. To test, run 'gpupdate /force' afer the Registry change.`n"
                    }
                    if ($UIStatus -eq 1) {
                        Write-Host -ForegroundColor Cyan "`nWindows Defender UI is locked down"
                    }
                    if ($TPStatus -eq $true -or $TPStatus -eq 1) {
                        Write-Host -ForegroundColor Cyan "Windows Defender Tamper Protection is enabled (configurable from the Windows Security app only)"
                    }
                    if ($SentinelOneTamperProtection) {
                        Write-Host -ForegroundColor Red "`nSentinelOne Tamper Protection and Safe Boot Status:"
                        $TamperProtection
                    }
                    if ($Server_Message) {
                        Write-Host -ForegroundColor Cyan "$Server_Message"
                    }
                    if ($Techloq) {
                        Write-Host -ForegroundColor Cyan "`n$Techloq"
                    }
                } # elseif !$DefaultOverride

                if ($Vipre) {
                    if ($ARM) {
                        Write-Warning $ARM
                    }

                    if ($Buggy_Version) {
                        Write-Warning $Buggy_Version
                    }
                }
                
                if ($SophosTPEnabled -eq $true) {
                    Write-Warning "Sophos Tamper Protection is enabled on this machine."
                    if (!(((Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }).Name) -like '*Ethernet*')) {
                        Write-Host -ForegroundColor Yellow "You'll need to boot to Safe Mode. Keep in mind this machine is on Wi-fi."
                    }
                }

                if ($TrendTPEnabled -eq $true) {
                    Write-Warning "Trend Micro Tamper Protection is enabled on this machine."
                }

                if ($BT) { Write-Host -ForegroundColor Cyan $BT }

                if ($AVFolders) {
                    if ($AV_Folders) {
                        Write-Host -ForegroundColor Green "`nAV folders on the machine (excluding Windows Defender):"
                        $AV_Folders | Sort-Object FolderName, FullPath | Format-Table
                    }
                }

                if ($MachineInfo) { 
                    Write-Host -ForegroundColor Green "`nHardware, OS and User info:"
                    if ($Obj) {
                        Write-Output $Obj | Format-List
                        # Format-List is needed for the last verbose message to appear in the right place on screen
                    }
                    else {
                        Write-Warning "Get-CimInstance is not supported on this machine.`nOS info check skipped."
                    } # if $Obj
                } # if $MachineInfo

                # The below warning will display even if $MachineInfo is not specified
                if ( ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceId='$((Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$false).SystemDrive)'" -Verbose:$false).FreeSpace / 1GB -as [int]) -lt 1) {
                    Write-Warning "<<< Free space on the system drive is very low. >>>"
                }
            } # Default
        } # switch
    } # PROCESS
    END {
        Write-Verbose "[END  ] Ending: $($MyInvocation.MyCommand)"
    }
    
} # function Get-AVInfo