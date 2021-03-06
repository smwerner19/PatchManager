<#
.SYNOPSIS
    PowerShell script for deploying patches via a GUI interface.
.DESCRIPTION
    PowerShell script for deploying patches via a GUI interface.
.NOTES
    Author:  Stefan M. Werner
    Website: http://getninjad.com
#>

cls

#region Startup Checks and configurations
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $('-' * 50)"
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Running Startup Checks"
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $('-' * 50)"

#Determine if running from ISE
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- Checking to see if running from console"
If ($Host.name -eq "Windows PowerShell ISE Host") {
    Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- Unable to run this from the PowerShell ISE due to issues with PSexec!"
	Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- Please run from console."
    Break
}

#Validate user is an Administrator
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- Checking for Administrator credentials"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- You are not running this as an Administrator!"
	Write-Warning "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): -- Start console as an administrator and re-run the script."
    Break
}
#endregion

# get current directoy
$scriptpath 			= $MyInvocation.MyCommand.Path
$currentdir 			= Split-Path $scriptpath

# Set date for temp dir
$d 						= Get-Date
$d 						= $d.ToString("yyyyMMdd-HHmm")

# Error Action
$ErrorActionPreference 	= "Stop"							        # Must be set to stop for try/catch statments to work

# Debug
$DebugPreference 		= "SilentlyContinue"				                # Continue = Display Debug Messages; SilentlyContinue = Hide Debug Messages

# Set Variables
$tmp 					= "$currentdir\installer\$d" 		        # temp directory for remote installer
$installType 			= 1 								        # 0 = x86 only; 1 = x86 and x64; 2 = x64 only
$threads				= 6									        # max number of threads for installer.
$fileTypes				= @('*.exe','*.msi','*.msu','*.msp')		# supported file types to include

# Define Log Files
$LogFile 				= $currentdir + "\log\Log-$d.txt"
$ErrorLogFile 			= $currentdir + "\log\ErrorLog-$d.csv"

# Set Synchronized (thread safe) objects
$script:gui 			= [Hashtable]::Synchronized(@{})
$script:runspaces 		= [System.Collections.ArrayList]::Synchronized((New-Object System.Collections.ArrayList))

# Set Switch Defaults
$defaultSwitchExe 		= '/quiet /norestart'
$defaultSwitchMsu 		= '/quiet /norestart'
$defaultSwitchMsi 		= '/qn /norestart'
$defaultSwitchMsp 		= '/qn'

# Set custom Switches to null
$script:switchExe 		= $null
$script:switchMsu 		= $null
$script:switchMsi 		= $null
$script:switchMsp 		= $null

# Required files:
. $currentdir\app\functions.ps1
. $currentdir\app\main-window.ps1
. $currentdir\app\wizard-window.ps1
. $currentdir\app\sources-window.ps1
. $currentdir\app\switch-window.ps1

# Load required .Net assemblies into memory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Enable enhanced visuals
[System.Windows.Forms.Application]::EnableVisualStyles()

# Starting Log File
Update-Log "$('-' * 50)"
Update-Log "Starting PatchManager -- $(Get-Date)"
Update-Log "$('-' * 50)"

# Load GUI
GenerateForm