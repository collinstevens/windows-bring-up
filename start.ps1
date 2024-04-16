param(
    [Parameter(HelpMessage="Excludes packages which shouldn't be installed on an employer-provided machine.")]
    [switch]$IsEmployerMachine
)

$env:POWERSHELL_TELEMETRY_OPTOUT = 1
[Environment]::SetEnvironmentVariable('POWERSHELL_Telemetry_OPTOUT', 1 , [System.EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', 1, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('MSBUILDTERMINALLOGGER', 'auto', [EnvironmentVariableTarget]::Machine)

# Create Dev Drive
# diskpart /s create-dev-drive.diskpart
# Get-Disk 2 | New-Volume -DriveLetter E -FriendlyName E | Format-Volume -DevDrive

[Environment]::SetEnvironmentVariable('CARGO_HOME', 'D:\packages\cargo', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('MAVEN_OPTS', 'D:\packages\maven', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('npm_config_cache', 'D:\packages\npm', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('PIP_CACHE_DIR', 'D:\packages\pip', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('PNPM_HOME', 'D:\packages\pnpm', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('VCPKG_DEFAULT_BINARY_CACHE', 'D:\packages\vcpkg', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('TEMP', 'D:\TEMP', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('TMP', 'D:\TEMP', [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('TEMP', $null, [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable('TMP', $null, [EnvironmentVariableTarget]::User)

$MachineEnvironmentKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
$MachinePath = $MachineEnvironmentKey.GetValue('Path', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
$MachinePathSplit = $MachinePath -Split ';'

if ($MachinePathSplit -notcontains '%PNPM_HOME%') {
    $MachinePath += ';%PNPM_HOME%'
}

$MachineEnvironmentKey.SetValue('Path', $MachinePath, [Microsoft.Win32.RegistryValueKind]::ExpandString)

# Set the Windows Time service to start automatically:
Set-Service -Name W32Time -StartupType Automatic

TryDisable-Service 'Razer Game Scanner Service'

# Disable Microsoft Office Telemetry
TryDisable-ScheduledTask -TaskName 'OfficeTelemetryAgentFallBack2016'
TryDisable-ScheduledTask -TaskName 'OfficeTelemetryAgentLogOn2016'
TryDisable-ScheduledTask -TaskName 'OfficeTelemetryAgentFallBack'
TryDisable-ScheduledTask -TaskName 'OfficeTelemetryAgentLogOn'

# Disable Office Subscription Heartbeat
TryDisable-ScheduledTask -TaskName 'Microsoft\Office\Office 15 Subscription Heartbeat'
TryDisable-ScheduledTask -TaskName 'Microsoft\Office\Office 16 Subscription Heartbeat'

# Disable Visual Studio Telemetry
TryDisable-Service 'VSStandardCollectorService150' 

# Disable Unnecessary Windows Services
TryDisable-Service 'MessagingService' 
TryDisable-Service 'PimIndexMaintenanceSvc' 
TryDisable-Service 'RetailDemo' 
TryDisable-Service 'MapsBroker' 
TryDisable-Service 'DoSvc' 
TryDisable-Service 'OneSyncSvc' 
TryDisable-Service 'UnistoreSvc' 

# Disable Windows Error Reporting
TryDisable-ScheduledTask -TaskName 'QueueReporting'

# Disable NVIDIA Telemetry
TryDisable-Service NvTelemetryContainer 

# Delete NVIDIA telemetry files
Remove-Item -Recurse "$env:SystemDrive\System32\DriverStore\FileRepository\NvTelemetry*.dll"
Remove-Item -Recurse "$env:ProgramFiles\NVIDIA Corporation\NvTelemetry" | Out-Null

# Disable Windows Media Player Telemetry
TryDisable-Service WMPNetworkSvc 

# Disable Mozilla Firefox Telemetry
TryDisable-ScheduledTask '\Mozilla\Firefox Default Browser Agent 308046B0AF4A39CB'
TryDisable-ScheduledTask '\Mozilla\Firefox Default Browser Agent D2CEEC440E2074BD'

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

# Generate a self-signed certificate to enable HTTPS in development:
dotnet dev-certs https --trust

function TryDisable-Service {
    param (
        [string]$ServiceName
    )

    if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
        Write-Host "The service '$ServiceName' does not exist."
        return
    }

    Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue -PassThru | Stop-Service -ErrorAction SilentlyContinue

    Write-Host "The service '$ServiceName' has been stopped and disabled."
}

function TryDisable-ScheduledTask {
    param (
        [string]$TaskName
    )

    if (-not (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
        Write-Host "The scheduled task '$TaskName' does not exist."
        return
    }

    Disable-ScheduledTaskCustom -TaskName $TaskName

    Write-Host "The scheduled task '$TaskName' has been disabled."
}