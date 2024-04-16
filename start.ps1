param(
    [Parameter(HelpMessage="Excludes packages which shouldn't be installed on an employer-provided machine.")]
    [switch]$IsEmployerMachine,

    [Parameter(Mandatory=$true, HelpMessage="The drive to use for environment variables (typically a DevDrive")]
    [ValidateScript({
        if (-not (Test-Path "${_}:\")) {
            throw "Drive letter '$_' does not exist."
        }
        $true
    })]
    [string]$DriveLetter
)

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges. Please run it as an administrator."
    Exit
}

function Disable-ServiceIfEnabled {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    $ProgressActivity = "Disabling service '${ServiceName}'"

    Write-Progress -Activity $ProgressActivity -Status "Progress" -PercentComplete 0

    $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $Service) {
        Write-Progress -Activity $ProgressActivity -Status "Service does not exist" -Completed
        # Write-Host "The service '$ServiceName' does not exist."
        return
    }

    if ($Service.StartType -eq 'Disabled' -and $Service.Status -eq 'Stopped') {
        Write-Progress -Activity $ProgressActivity -Status "Service is already disabled" -Completed
        # Write-Host "The service '$ServiceName' is already disabled."
        return
    }

    Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue -PassThru | Stop-Service

    Write-Progress -Activity $ProgressActivity -Status "Completed" -Completed
    Write-Output "The service '$ServiceName' has been stopped and disabled."
}

function Disable-ScheduledTaskIfEnabled {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        [string]$TaskPath
    )

    if (-not $TaskPath) { 
        $TaskFullName = $TaskName
    } else {
        $TaskFullName = "${TaskPath}${TaskName}"
    }

    $ProgressActivity = "Disabling scheduled task '${TaskFullName}'"
    
    Write-Progress -Activity $ProgressActivity -Status "Progress" -PercentComplete 0
    
    if (-not $TaskPath) {
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    }
    else {
        $Task = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
    }

    if (-not $Task) {
        Write-Progress -Activity $ProgressActivity -Status "Task does not exist" -Completed
        # Write-Host "The scheduled task '${TaskFullName}' does not exist."
        return
    }

    if ($Task.State -eq 'Disabled') {
        Write-Progress -Activity $ProgressActivity -Status "Task is already disabled" -Completed
        # Write-Host "The scheduled task '${TaskFullName}' is already disabled."
        return
    }

    if (-not $TaskPath) {
        Disable-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue > $null
    }
    else {
        Disable-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue > $null
    }

    Write-Progress -Activity $ProgressActivity -Status "Completed" -Completed
    Write-Host "The scheduled task '${TaskFullName}' has been disabled."
}

function Set-EnvironmentVariableIfDifferent {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(Mandatory=$true)]
        [System.EnvironmentVariableTarget]$Target
    )

    $ExistingValue = [Environment]::GetEnvironmentVariable($Name, $Target)

    if ($Value -eq '') {
        if ($ExistingValue -ne $null) {
            [Environment]::SetEnvironmentVariable($Name, $null, $Target)
            Write-Host "Environment variable '$Name' has been unset in target '$Target'."
        }
        else {
            # Write-Host "Environment variable '$Name' does not exist in target '$Target'."
        }
    }
    elseif ($ExistingValue -ne $Value) {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
        Write-Host "Environment variable '$Name' has been set to '$Value' in target '$Target'."
    }
    else {
        # Otherwise, it already has the desired value, so no action is needed
        # Write-Host "Environment variable '$Name' already has the desired value ('$Value') in target '$Target'."
    }
}

Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 0

$env:POWERSHELL_TELEMETRY_OPTOUT = 1
Set-EnvironmentVariableIfDifferent -Name 'POWERSHELL_Telemetry_OPTOUT' -Value '1' -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 8

Set-EnvironmentVariableIfDifferent -Name 'DOTNET_CLI_TELEMETRY_OPTOUT' -Value '1' -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 16

Set-EnvironmentVariableIfDifferent -Name 'MSBUILDTERMINALLOGGER' -Value 'auto' -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 24

Set-EnvironmentVariableIfDifferent -Name 'CARGO_HOME' -Value "${DriveLetter}:\packages\cargo" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 32

Set-EnvironmentVariableIfDifferent -Name 'MAVEN_OPTS' -Value "${DriveLetter}:\packages\maven" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 40

Set-EnvironmentVariableIfDifferent -Name 'npm_config_cache' -Value "${DriveLetter}:\packages\npm" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 48

Set-EnvironmentVariableIfDifferent -Name 'PIP_CACHE_DIR' -Value "${DriveLetter}:\packages\pip" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 56

Set-EnvironmentVariableIfDifferent -Name 'PNPM_HOME' -Value "${DriveLetter}:\packages\pnpm" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 64

Set-EnvironmentVariableIfDifferent -Name 'VCPKG_DEFAULT_BINARY_CACHE' -Value "${DriveLetter}:\packages\vcpkg" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 72

Set-EnvironmentVariableIfDifferent -Name 'TEMP' -Value "${DriveLetter}:\TEMP" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 80

Set-EnvironmentVariableIfDifferent -Name 'TMP' -Value "${DriveLetter}:\TEMP" -Target Machine
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 88

Set-EnvironmentVariableIfDifferent -Name 'TEMP' -Value '' -Target User
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 96

Set-EnvironmentVariableIfDifferent -Name 'TMP' -Value '' -Target User
Write-Progress -Activity "Setting environment variables" -Status "Progress" -PercentComplete 100


Write-Progress -Activity "Setting environment variables" -Status "Completed" -Completed
Write-Host "Environment variables have been set"

# Create Dev Drive
# diskpart /s create-dev-drive.diskpart
# Get-Disk 2 | New-Volume -DriveLetter E -FriendlyName E | Format-Volume -DevDrive

$MachineEnvironmentKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
$MachinePath = $MachineEnvironmentKey.GetValue('Path', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
$MachinePathSplit = $MachinePath -Split ';'

if ($MachinePathSplit -notcontains '%PNPM_HOME%') {
    $MachinePath += ';%PNPM_HOME%'
}

$MachineEnvironmentKey.SetValue('Path', $MachinePath, [Microsoft.Win32.RegistryValueKind]::ExpandString)

Write-Host "PATH has been set"

# Set the Windows Time service to start automatically:
Set-Service -Name 'W32Time' -StartupType Automatic

Disable-ServiceIfEnabled 'Razer Game Scanner Service'

# Disable Microsoft Office Telemetry
Disable-ScheduledTaskIfEnabled 'OfficeTelemetryAgentFallBack2016'
Disable-ScheduledTaskIfEnabled 'OfficeTelemetryAgentLogOn2016'
Disable-ScheduledTaskIfEnabled 'OfficeTelemetryAgentFallBack'
Disable-ScheduledTaskIfEnabled 'OfficeTelemetryAgentLogOn'

# Disable Office Subscription Heartbeat
Disable-ScheduledTaskIfEnabled 'Office 15 Subscription Heartbeat' '\Microsoft\Office\'
Disable-ScheduledTaskIfEnabled 'Office 16 Subscription Heartbeat' '\Microsoft\Office\'

# Disable Visual Studio Telemetry
Disable-ServiceIfEnabled 'VSStandardCollectorService150' 

# Disable Unnecessary Windows Services
Disable-ServiceIfEnabled 'MessagingService' 
Disable-ServiceIfEnabled 'PimIndexMaintenanceSvc' 
Disable-ServiceIfEnabled 'RetailDemo' 
Disable-ServiceIfEnabled 'MapsBroker' 
Disable-ServiceIfEnabled 'DoSvc' 
Disable-ServiceIfEnabled 'OneSyncSvc' 
Disable-ServiceIfEnabled 'UnistoreSvc' 

# Disable Windows Error Reporting
Disable-ScheduledTaskIfEnabled 'QueueReporting' '\Microsoft\Windows\Windows Error Reporting'

# Disable NVIDIA Telemetry
Disable-ServiceIfEnabled 'NvTelemetryContainer'

# Delete NVIDIA telemetry files
if (Test-Path "$env:SystemDrive\System32\DriverStore\FileRepository") {
    Remove-Item -Path "$env:SystemDrive\System32\DriverStore\FileRepository\NvTelemetry*.dll" -Recurse -ErrorAction SilentlyContinue
}

if (Test-Path "$env:ProgramFiles\NVIDIA Corporation\NvTelemetry") {
    Remove-Item -Path "$env:ProgramFiles\NVIDIA Corporation\NvTelemetry" -Recurse -ErrorAction SilentlyContinue | Out-Null
}

# Disable Windows Media Player Telemetry
Disable-ServiceIfEnabled 'WMPNetworkSvc' 

# Disable Mozilla Firefox Telemetry
Disable-ScheduledTaskIfEnabled 'Firefox Default Browser Agent 308046B0AF4A39CB' -TaskPath '\Mozilla\'
Disable-ScheduledTaskIfEnabled 'Firefox Default Browser Agent D2CEEC440E2074BD' -TaskPath '\Mozilla\'

$WinGetSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
@'
{
    '$schema": "https://aka.ms/winget-settings.schema.json",
    "experimentalFeatures": {
        "configuration": true
    },
    "installBehavior": {
        "preferences": {
            "scope": "machine"
        },
        "skipDependencies": false
    },
    "logging": {
        "level": "info"
    },
    "telemetry": {
        "disable": true
    },
    "uninstallBehavior": {
        "purgePortablePackage": true
    },
    "visual": {
        "progressBar": "accent"
    }
}
'@ | Out-File "$WinGetSettingsFile"

winget install --id 7zip.7zip --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id AgileBits.1Password --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Docker.DockerDesktop --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Git.Git --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Google.Chrome --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id JetBrains.Toolbox --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.AppInstaller --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.Azure.StorageExplorer --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.6.2 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.7 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.7.1 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.7.2 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.8 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack_4 --version 4.8.1 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack.4.5 --version 4.5.1 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.Framework.DeveloperPack.4.5 --version 4.5.2 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.SDK.3_1 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.SDK.5 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.SDK.6 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.SDK.7 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.DotNet.SDK.8 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.PerfView --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.PowerShell --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.PowerToys --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.SQLServerManagementStudio --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.Sysinternals.ProcessExplorer --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.Sysinternals.ProcessMonitor --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.TimeTravelDebugging --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.UI.Xaml.2.7 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.UI.Xaml.2.8 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.VCRedist.2015+.x64 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.WinDbg --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.WindowsAppRuntime.1.5 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.WindowsSDK.10.0.22621 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.WindowsTerminal --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Microsoft.WindowsWDK.10.0.22621 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Mozilla.Firefox --accept-package-agreements --accept-source-agreements --source winget
winget install --id Python.Python.3.10 --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id SlackTechnologies.Slack --exact --accept-package-agreements --accept-source-agreements --source winget
winget install --id Spotify.Spotify --accept-package-agreements --accept-source-agreements --source winget
winget install --id voidtools.Everything --exact --accept-package-agreements --accept-source-agreements --source winget

# https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022#use-winget-to-install-or-modify-visual-studio
# winget install --source winget --exact --id Microsoft.VisualStudio.2022.Community --override "--passive --config <vsconfig-folder>\wdk.vsconfig"
# https://learn.microsoft.com/en-us/windows-hardware/drivers/install-the-wdk-using-winget#step-3-install-wdk-visual-studio-extension
# & $(& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -nologo -latest -products * -property enginePath | Join-Path -ChildPath 'VSIXInstaller.exe') "${env:ProgramFiles(x86)}\Windows Kits\10\Vsix\VS2022\10.0.22621.0\WDK.vsix"

if (!$IsEmployerMachine) {
    winget install --id Discord.Discord --exact --accept-package-agreements --accept-source-agreements --source winget
    winget install --id qBittorrent.qBittorrent --exact --accept-package-agreements --accept-source-agreements --source winget
    winget install --id Valve.Steam --exact --accept-package-agreements --accept-source-agreements --source winget
}

winget uninstall --id 'OneNoteFreeRetail - en-us' --exact
winget uninstall --id Adobe.Acrobat.Reader.32-bit --exact
winget uninstall --id Clipchamp.Clipchamp_yxz26nhyzhsrt --exact
winget uninstall --id Microsoft.BingNews_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.BingWeather_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.GetHelp_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.Getstarted_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.Getstarted_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.Ink.Handwriting.en-US.1.0_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.Ink.Handwriting.Main.en-US.1.0.1_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.MicrosoftJournal_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.OutlookForWindows_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.People_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.Whiteboard_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.WindowsCamera_8wekyb3d8bbwe --exact
winget uninstall --id microsoft.windowscommunicationsapps_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.WindowsMaps_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.WindowsNotepad_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.YourPhone_8wekyb3d8bbwe --exact
winget uninstall --id Microsoft.ZuneMusic_8wekyb3d8bbwe --exact
winget uninstall --id MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe --exact
winget uninstall --name '3D Viewer' --exact

wsl --install --no-distribution --no-launch

# Enable Windows Sandbox
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart

# Generate a self-signed certificate to enable HTTPS in development
dotnet dev-certs https --trust