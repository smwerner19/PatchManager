#region: Style

# Set position of form object
Function DrawPoint 
{
	Param (
		[int]$y,
		[int]$x
	)
	
    $Location = New-Object System.Drawing.Point("$y","$x")
    return $Location
}

# Set dimensions of form object
Function DrawSize
{
	Param (
		[int]$w,
		[int]$h
	)
	
    $Size = New-Object System.Drawing.Size("$w","$h")
    return $Size
}

#endregion

#region: Logging

## UPDATE LOG FILE
Function Update-Log
{
	Param ( 
		[string]$logstring,
		[switch]$build,
		[switch]$install
	)
	
	If ($build)
	{
		$gui.buildStatus.Items.Add($logstring)
		$gui.buildStatus.TopIndex = $gui.buildStatus.Items.Count - 1
	}
	
	If ($install)
	{
		$gui.installStatus.Items.Add($logstring)
		$gui.InstallStatus.TopIndex = $gui.InstallStatus.Items.Count - 1
	}
	
	$logstring = $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ': ' + $logstring
	Write-Host $logstring
	
	Add-content $LogFile -value $logstring
}

## REPORT ERROR INFORMATION
Function Write-ErrorLog
{
	Update-Log "$('-' * 50)"
	Update-Log "-- SCRIPT PROCESSING CANCELLED"
	Update-Log "$('-' * 50)"
	Update-Log ""
	Update-Log "Error in $($_.InvocationInfo.ScriptName)"
	Update-Log ""
	Update-Log "$('-' * 50)"
	Update-Log "-- Error Information"
	Update-Log "$('-' * 50)"
	Update-Log ""
	Update-Log "Error Details: $($_)"
	Update-Log "Line Number: $($_.InvocationInfo.ScriptLineNumber)"
	Update-Log "Offset: $($_.InvocationInfo.OffsetInLine)"
	Update-Log "Command: $($_.InvocationInfo.MyCommand)"
	Update-Log "Line: $($_.InvocationInfo.Line)"
	
	[string]$exception = $($_)
	$exception = $exception.replace('"','""')
	
	[string]$line = $($_.InvocationInfo.Line)
	$line = $line.replace('"','""')

	$row = '"' + $address + '","' + $exception + '","' + $($_.InvocationInfo.ScriptLineNumber) + '","' + $($_.InvocationInfo.OffsetInLine) + '","' + $($_.InvocationInfo.MyCommand) + '","' + $line + '"'
	Add-Content -Path $ErrorLogFile -Value $row
}

#endregion

#region: Scan IP Range

function Scan-Range 
{
    Begin 
    {
        $ip_start = $gui.start1.Text + '.' + $gui.start2.Text + '.' + $gui.start3.Text + '.' + $gui.start4.Text
        $ip_end = $gui.end1.Text + '.' + $gui.end2.Text + '.' + $gui.end3.Text + '.' + $gui.end4.Text
		
        Update-Log "$('-' * 50)"
        Update-Log "start: $ip_start"
        Update-Log "end: $ip_end"
		
        $gui.start1.Clear(); $gui.start2.Clear(); $gui.start3.Clear(); $gui.start4.Clear()
        $gui.end1.Clear(); $gui.end2.Clear(); $gui.end3.Clear(); $gui.end4.Clear()		
	
        $lastDot = $ip_start.LastIndexOf(".")
        $subnet = $ip_start.Substring(0, $lastDot+1)
        $fip = [int] $ip_start.SubString($lastDot + 1)
        $lip = [int] $ip_end.SubString($lastDot + 1)
		
        $count = ($lip - $fip) + 1
        Update-Log "count: $count"
        $i = 0
    }
	
    Process 
    {
        If (($ip_start.Text -ne '...') -and ($ip_end.Text -ne '...')) 
        {
            Update-Log "$('-' * 50)"
            Update-Log "IP Address"
			
            Do 
            { 
                $address = $subnet + $fip
                $pingStatus = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$address'"
                If ($pingStatus.StatusCode -eq 0) 
                {
                    Try
                    { 
                        $hostname = ([System.Net.DNS]::GetHostbyAddress("$address")).HostName
                        If ($hostname -match '^([a-zA-Z0-9\-]*[a-zA-Z0-9])\.*') 
                        {
                            $hostname = $matches[1]
                            Update-Log "$hostname - ON NETWORK"
                            Add-ComputerName $hostname
                        }
                    }
                    
                    Catch
                    {
                        Update-Log "$address - $_"
                    }
                } 
                Else 
                {
                    Update-Log "$address - NOT FOUND"
                }
                $fip++
            } until ($fip -gt $lip)
        } 
        Else 
        {
            Update-Log "You must specify both a starting and ending IP!"
			
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("You must specify both a starting and ending IP!",0x0)
        }
    }
	
    End 
    {
        Update-Log "$('-' * 50)"
    }
}
#endregion

#region: Build Install

# Build Directories
function buildDirs
{
	Param ( [int]$type )
	
	Update-Log "-- Install Type: $type" -build
	Update-Log "-- Temp Dir: $tmp"	-build
	
	$newDir = $tmp + '\files'
	Write-Verbose $newDir
	md $newDir
	
	If ($type -le 1) 
	{
		$script:32Dir = ($newDir + "\x86")
		md $script:32Dir
 	}
	
	If ($type -ge 1) 
	{
		$script:64Dir = ($newDir + "\x64")
		md $script:64Dir
	}
}

# Copy base script files
function copyBase 
{
	Param ( [int]$type )
	
	Update-Log "-- Copying base script." -build
	Copy-Item ($currentdir + "\installer\BasePS\*.*") $tmp
}

# Create Batch Files
function createBatchFiles 
{
	Param ( [int]$type )
	
	Update-Log "-- Creating batch files." -build
	
	if ($type -le 1) 
	{
		New-Item -Path ($script:32Dir + '\install.bat') -ItemType "file"
	}
	
	If ($type -ge 1) 
	{
		New-Item -Path ($script:64Dir + '\install.bat') -ItemType "file"
	}
}

# Move Files
function moveFiles
{
	Param ( [int]$type )
	
	$array = $gui.dgvInstall.Rows
	
	If ($array -ne $null) {       
		Foreach ($item in $array)
		{
			$folder = $gui.dgvInstall.Rows[$item.Index].Cells['Folder'].Value
			$name = $gui.dgvInstall.Rows[$item.Index].Cells['Name'].Value
			$path = $gui.dgvInstall.Rows[$item.Index].Cells['Path'].Value
			$arch = $gui.dgvInstall.Rows[$item.Index].Cells['Type'].Value
					
			If (($arch -eq "x86") -and ($type -le 1)) 
			{
				Update-Log "-- Moving file: $name" -build
				
				If ($script:xArch -eq $true)
				{
					Copy-Item ($path + '\' + $name)  -Destination ($script:32Dir + '\' + $name)
					Copy-Item ($path + '\' + $name)  -Destination ($script:64Dir + '\' + $name)
					
					If ($name -match ".exe") 
					{
						If ($switchExe -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchExe)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchExe)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchExe)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchExe)
						}
					} 
					ElseIf ($name -match ".msu") 
					{
						If ($switchMsu -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsu)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsu)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchMsu)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchMsu)
						}
					} 
					ElseIf ($name -match ".msi") 
					{
						If ($switchMsi -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsi)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsi)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x86\" + $name + " " + $switchMsi)
							Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x64\" + $name + " " + $switchMsi)
						}
					}
					ElseIf ($name -match ".msp") 
					{
						If ($switchMsi -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsp)
							Add-Content ($script:64Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsp)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x86\" + $name + " " + $switchMsp)
							Add-Content ($script:64Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x64\" + $name + " " + $switchMsp)
						}
					}
				} 
				Else 
				{
					Copy-Item ($path + '\' + $name)  -Destination ($script:32Dir + '\' + $name)
					
					If ($name -match ".exe") 
					{
						If ($switchExe -eq $null)
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchExe)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchExe)
						}
					} 
					ElseIf ($name -match ".msu") 
					{
						If ($switchMsu -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsu)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchMsu)
						}
					} 
					ElseIf ($name -match ".msi") 
					{
						If ($switchMsi -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsi)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x86\" + $name + " " + $switchMsi)
						}
					}
					ElseIf ($name -match ".msp") 
					{
						If ($switchMsi -eq $null) 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsp)
						} 
						Else 
						{
							Add-Content ($script:32Dir + '\install.bat') -Value ("msiexec /p C:\TempInstall\x86\" + $name + " " + $switchMsp)
						}
					}
				}
			} 
			ElseIf (($arch -eq "x64") -and $type -ge 1) 
			{
				Update-Log "-- Moving file: $name" -build
				
				Copy-Item ($path + '\' + $name)  -Destination ($script:64Dir + '\' + $name)
				
				If ($name -match ".exe") 
				{
					If ($switchExe -eq $null) 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchExe)
					} 
					Else 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchExe)
					}
				} 
				ElseIf ($name -match ".msu") 
				{
					if ($switchMsu -eq $null) 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsu)
					}
					Else 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchMsu)
					}
				} 
				ElseIf ($name -match ".msi") 
				{
					If ($switchMsi -eq $null) 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsi)
					} 
					Else 
					{
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT MsiExec.exe /i C:\TempInstall\x64\" + $name + " " + $switchMsi)
					}
				} 
			} 
			ElseIf (($arch -eq "all") -and $type -ge 1) 
			{
				Update-Log "-- Moving file: $name" -build
				
				Copy-Item ($path + '\' + $name)  -Destination ($script:32Dir + '\' + $name)
				Copy-Item ($path + '\' + $name)  -Destination ($script:64Dir + '\' + $name)
				
				If ($name -match ".exe") 
				{
					If ($switchExe -eq $null) 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchExe)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchExe)
					} 
					Else 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchExe)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchExe)
					}
				} 
				ElseIf ($name -match ".msu") 
				{
					If ($switchMsu -eq $null) 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsu)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsu)
					} 
					Else 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchMsu)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchMsu)
					}
				} 
				ElseIf ($name -match ".msi") 
				{
					If ($switchMsi -eq $null) 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $defaultSwitchMsi)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $defaultSwitchMsi)
					} 
					Else 
					{
						Add-Content ($script:32Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x86\" + $name + " " + $switchMsi)
						Add-Content ($script:64Dir + '\install.bat') -Value ("start /WAIT C:\TempInstall\x64\" + $name + " " + $switchMsi)
					}
				}
			}
		}    
	}
}

# Build install script
function buildit 
{
	Begin 
	{
		Update-Log " "
		Update-Log "$('-' * 50)" -build
		Update-Log "Start Build" -build
		Update-Log "$('-' * 50)" -build
	}
	
	Process 
	{
		buildDirs($installType)
		copyBase($installType)
		createBatchFiles($installType)
		moveFiles($installType)
	}
	
	End 
	{
		Update-Log "$('-' * 50)" -build
		Update-Log "Build Complete" -build
		Update-Log "$('-' * 50)" -build 
		
		$gui.btnBatch32.Enabled = $true
		$gui.btnBatch64.Enabled = $true
		$gui.nextButton.Enabled = $true
	}
}
#endregion

#region: Install

function LaunchInstall
{
    Param ( [int]$threads )
	
    Begin 
    {
        $a = Get-Date
        $script:hostnames = $gui.listComputers.Items
        $command = $tmp + "\psexec.exe"
        $script:results = @{}
        $handle64 = $installType
        $Script:i = 0
		
        Update-Log " "
		
        Update-Log "$('-' * 50)" -install
        Update-Log "Starting Install -- $a" -install
        Update-Log "$('-' * 50)" -install
		
        Update-Log "Current Dir: $currentdir" -install		
        Update-Log "Install Type Setting: $handle64" -install
		
        Update-Log "$('-' * 50)" -install
		
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspacepool = [runspacefactory]::CreateRunspacePool(1, $threads, $sessionstate, $Host)

        $runspacepool.Open()
		
        $ScriptBlock = {
            Param (
                $Computer,
                $command, 
                $remoteinstall, 
                $installpath, 
                $destpath, 
                $sourcepath
            )
			
            Write-Debug "New-Item -Path $destpath -Type Directory -Force"
            New-Item -Path $destpath -Type Directory -Force
					
            Write-Debug "copy-item $sourcepath $destpath  -r -Force"
            Copy-Item  -Path $sourcepath -Destination $destpath -Recurse -Force -ErrorAction Stop
					
            Write-Debug "& $command $remoteinstall -h -accepteula -s $installpath"
            & $command $remoteinstall -h -accepteula -s $installpath
				
            Write-Debug "Del $destpath -recurse -force"
            Del $destpath -recurse -force
        }
    }
	
    Process 
    {
        foreach($hostname in $hostnames) 
        {						
            Try 
            {
                Update-Log "-- Checking if $hostname is online" -install
				
                If (Test-Connection -ComputerName $hostname -Count 1 -Quiet) 
                {
                    Update-Log "-- Computer is online -- Processing" -install
					
                    $destpath = "\\" + $hostname + "\c$\TempInstall"
                    $OSlvl = Get-SystemType -ComputerName $hostname
                    $OSFilePath = $null
					        
                    If ($handle64 -eq 0) 
                    {
                        $OSFilePath = "\x86"
                    } 
                    ElseIf (($handle64 -eq 1) -and  ($OSlvl -match "x86")) 
                    {
                        $OSFilePath = "\x86"
                    } 
                    ElseIf (($handle64 -ge 1) -and ($OSlvl -match "x64")) 
                    {
                        $OSFilePath = "\x64"  
                    }
						
                    Update-Log "-- Install Type: $handle64 ~ Install Path: $OSFilePath" -install
						
                    If ($OSFilePath -ne $null) 
                    {
                        $sourcepath = $tmp + '\files' + $OSFilePath       
				        
                        $remoteinstall = "\\" + $hostname
                        $installpath = $destpath + $OSFilePath + "\install.bat"
						
                        # Create the powershell instance and supply the scriptblock and parameters
                        $powershell = [Management.Automation.PowerShell]::Create().AddScript($ScriptBlock).AddArgument($hostname).AddArgument($command).AddArgument($remoteinstall).AddArgument($installpath).AddArgument($destpath).AddArgument($sourcepath)
						
                        # Add the runspace to the PowerShell instance
                        $powershell.RunspacePool = $runspacepool
						
                        # Create a temporay collection for each runspace
                        $temp = "" | Select-Object PowerShell,Runspace,Computer
                        $temp.Computer = $hostname
                        $temp.PowerShell = $powershell
						
                        # Save the handle output when calling BeginInvoke(),this will be used later to end the runspace
                        $temp.Runspace = $powershell.BeginInvoke()

                        Update-Log "-- Adding $($temp.Computer) to queue." -install
                        Update-Log "$('-' * 50)" -install
						
                        $runspaces.Add($temp) | Out-Null
						
                        $script:results.Add(($hostname),(@{"Result" = ('Success'); "Type" = ("$OSlvl")}))
                    } 
                    Else 
                    {
                        Update-Log "-- ERROR: 64 bit install but OS not x64: $hostname" -install
                        Update-Log "$('-' * 50)" -install
						
                        $script:results.Add(($hostname),(@{"Result" = ('Failed'); "Type" = ('n/a')}))
                    }
                } 
                Else 
                {
                    $script:results.Add(($hostname),(@{"Result" = ('Offline'); "Type" = ('n/a')}))
					
                    Update-Log "-- $hostname is offline." -install
                    Update-Log "$('-' * 50)" -install
                }
						
            } 
			
            Catch 
            {
                Write-ErrorLog
                $script:results.Add(($hostname),(@{"Result" = ('Failed'); "Type" = ('n/a')}))
            }
        }
    }
	
    End 
    {
        Update-Log "Checking status of runspace jobs" -install
        Get-RunspaceData

        Update-Log "Closing the runspace pool" -install
        $runspacepool.close()
		
        Update-Log "$('-' * 50)" -install
        Update-Log "Generating report file... Please wait..." -install
        Update-Log "$('-' * 50)" -install
		
        # Set log file
        $d = Get-Date
        $d = $d.ToString("yyyyMMdd-HHmm")
		
        $script:ReportFile = "$currentdir\reports\results-$d.csv"
		
        $i = 0
        $files = $gui.dgvInstall.Rows
		
        foreach ($file in $files) 
        {
            [string]$kb = [regex]::match($gui.dgvInstall.Rows[$file.Index].Cells['Name'].Value,'KB\d*|kb\d*').ToString()
            Write-Debug "kb: $kb"
            If ($kb -ne '') { Add-Content -Path $currentdir\installer\temp-kb.txt -Value $kb }
        }
			
        If (Test-Path -Path "$currentdir\installer\temp-kb.txt")
        { 
            Get-Content -Path $currentdir\installer\temp-kb.txt | Get-Unique > $currentdir\installer\temp-array.txt
            $patches = Get-Content -Path $currentdir\installer\temp-array.txt
			
            Remove-Item -Path $currentdir\installer\temp-kb.txt -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $currentdir\installer\temp-array.txt -Force  -ErrorAction SilentlyContinue
		
            Write-Debug "patches: $patches"
        }
        
        Get-PatchAudit -Targets $script:hostnames -kb $patches
        
        $gui.nextButton.Enabled = $true
		
        Update-Log "$('-' * 50)" -install
        Update-Log "Install Complete" -install
        Update-Log "$('-' * 50)" -install
    }
}

Function Get-PatchAudit
{
    Param (
        [array]$Targets,
        [array]$kb
    )
    
    Begin 
    {
        Get-Job | Stop-Job -ErrorAction SilentlyContinue
        Get-Job | Remove-Job -Force
    }

    Process
    {
        Try
        {
            Invoke-Command -ComputerName $Targets -ScriptBlock { 
                Param ( [array]$kb )

                Function Test-Timeout
                {
	                Param ( [int]$timeout = '15' )
	
	                $i = 0
	
	                While ($j.State -ne 'Completed')  
	                {
		                If (($i -eq $timeout) -or ($j.State -ne 'Running'))
		                { 
			                $j | Remove-Job -Force -ErrorAction Ignore
			
			                Break
		                }
		
		                Start-Sleep 1
		                $i++
	                }
                }

                $obj = New-Object PSObject
                $obj | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $env:COMPUTERNAME

                $sb = { Get-WmiObject win32_quickfixengineering }

                $j = Start-Job -ScriptBlock $sb -ArgumentList $address
	            Test-Timeout
		
	            $Patches = $j | Receive-Job
            
                Foreach ($id in $kb)
                {
                    If ($Patches -match $id)
                    {
                        If ($id -match 'KB')
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $id -Value 'Installed'
                        }
                        Else
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $('KB' + $id) -Value 'Installed'
                        }
                    }
                    Else
                    {
                        If ($id -match 'KB')
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $id -Value 'Missing'
                        }
                        Else
                        {
                            $obj | Add-Member -MemberType NoteProperty -Name $('KB' + $id) -Value 'Missing'
                        }
                    }
                }

                $obj
            } -AsJob -ArgumentList (,$kb)

            $Count = $(Get-Job).ChildJobs.Count

            While ($(Get-Job).State -eq 'Running') 
            {
                $i = $( $x = 0; Foreach ($item in $(Get-Job).ChildJobs) { If (($item.State -eq 'Completed') -or ($item.State -eq 'Failed') -or ($item.State -eq 'Stopped') -or ($item.State -eq 'Suspended') -or ($item.State -eq 'AtBreakpoint')) { $x++ } }; $x)

                [int]$pct = ($i/$Count) * 100	
	            Write-Progress -Activity 'Querying Systems...' -CurrentOperation "$i of $Count Completed" -PercentComplete $pct
                Update-Log "$i of $Count Completed" -install

                Start-Sleep -Seconds 1
            } 

            Write-Progress -Activity 'Querying Systems...' -CurrentOperation "$i of $Count Completed" -PercentComplete $pct -Completed
        }

        Catch
        {
            Write-ErrorLog
        }
    }

    End
    {
        $cols = @()
        $cols += 'ComputerName'

        Foreach ($id in $kb)
        {
            If ($id -match 'KB')
            {
                $cols += $id
            }
            Else
            {
                $cols += $('KB' + $id)
            }
        }
        
        $result = $(Get-Job).ChildJobs.Output

        #Write-Debug $result

        $result | Select-Object $cols | Export-Csv -Path $script:ReportFile -NoTypeInformation -ErrorAction SilentlyContinue
    }
}

Function Get-RunspaceData 
{
	Do 
	{
		$more = $false        
		
		Foreach($runspace in $runspaces) 
		{
			If ($runspace.Runspace.isCompleted) 
			{
				$runspace.powershell.dispose()
				$runspace.Runspace = $null
				$runspace.powershell = $null
				$Script:i++                  
			} 
			ElseIf ($runspace.Runspace -ne $null) 
			{
				$more = $true
			}
		}
		
		If ($more) 
		{
			Start-Sleep -Milliseconds 100
		}
		
		#Clean out unused runspace jobs
		$temphash = $runspaces.clone()
		
		$temphash | Where {	$_.runspace -eq $Null } | ForEach {
			Write-Verbose ("Removing {0}" -f $_.computer)
			Update-Log "Closing runspace job: $($_.computer)" -install
			$Runspaces.remove($_)
		}            
	} while ($more)
}

#endregion

#region: Clean

# Remove Tmp Directory
function removeTmpDir 
{
	Begin 
	{
		Update-Log " "
		Update-Log "$('-' * 50)" 
		Update-Log "Start Cleanup" 
		Update-Log "$('-' * 50)" 
	}
	
	Process 
	{
		Update-Log "-- Removing $tmp" 
		rd -Recurse -Force "$tmp" 
	}
	
	End 
	{
		Update-Log "$('-' * 50)" 
		Update-Log "Cleanup Complete" 
		Update-Log "$('-' * 50)" 
	}
}

#endregion

#region: Other Functions

## GET REGISTRY VALUE
Function Get-RegValue
{
	Param ( 
		[string]$ComputerName,
		[string]$Hive,
		[string]$Key,
		[string]$Value,
		[string]$ValueType
	)
	
	Try
	{
		#Registry Hives
		Switch ($Hive)
		{
			'HKROOT' { [long]$Hive = 2147483648; Break }
			'HKCU' { [long]$Hive = 2147483649; Break }
			'HKLM' { [long]$Hive = 2147483650; Break }
			'HKU' { [long]$Hive = 2147483651; Break }
			'HKCC' { [long]$Hive = 2147483653; Break }
			'HKDD' { [long]$Hive = 2147483654; Break }
		}
		
		$sb = {
			Param ( 
				[string]$ComputerName,
				[long]$Hive,
				[string]$Key,
				[string]$Value,
				[string]$ValueType
			)
		
			$RegProv = [WMIClass]"\\$ComputerName\ROOT\DEFAULT:StdRegProv"
			
			Switch($ValueType)
			{
				'REG_SZ'
				{
					$RegValue = $RegProv.GetStringValue($Hive, $Key, $value)
					Break
				}
				'REG_EXPAND_SZ'
				{
					$RegValue = $RegProv.GetExpandedStringValue($Hive, $Key, $value)
					Break
				}
				'REG_BINARY'
				{
					$RegValue = $RegProv.GetBinaryValue($Hive, $Key, $value)
					Break
				}
				'REG_DWORD'
				{
					$RegValue = $RegProv.GetDWORDValue($Hive, $Key, $value)
					Break
				}
				'REG_MULTI_SZ'
				{
					$RegValue = $RegProv.GetMultiStringValue($Hive, $Key, $value)
					Break
				}
				'REG_QWORD'
				{
					$RegValue = $RegProv.GetQWORDValue($Hive, $Key, $value)
					Break
				}
			}
		
			If ($RegValue.ReturnValue -eq 0)
			{
				If (@($RegValue.Properties | Select-Object -ExpandProperty Name) -contains "sValue")
				{
					$RegValue.sValue
				}
				Else
				{
					$RegValue.uValue
				}
			}
		}
		
		$args = ($ComputerName,$Hive,$Key,$Value,$ValueType)
		$j = Start-Job -ScriptBlock $sb -ArgumentList $args
		Test-TimeOut $ComputerName 'Registry call timed out. Stopping Job.'
		
		$result = $j | Receive-Job -ErrorAction SilentlyContinue
		$j | Remove-Job -Force -ErrorAction SilentlyContinue
		
		Return $result
	}
	
	Catch
	{
		Write-ErrorLog
	}
}


Function Test-Timeout
{
	Param ( 
		[string]$address,
		[string]$exception,
		[int]$timeout = '15'
	)
	
	$i = 0
	
	While ($j.State -ne 'Completed')  
	{
		If (($i -eq $timeout) -or ($j.State -ne 'Running'))
		{ 
			Update-Log "-- Job timed out - Stopping Job... Please Wait"
			$j | Remove-Job -Force -ErrorAction SilentlyContinue
			
			$row = '"' + $address + '","' + $exception + '","","","",""'
			Add-Content -Path $ErrorLogFile -Value $row
			
			Break
		}
		
		Update-Log "-- Running Job... Please Wait"
		Sleep 1
		$i++
	}
}

Function Get-SystemType 
{
    Param ( [string]$ComputerName )

    Try 
	{
        $sb = {
			Param ( [string]$ComputerName )
			get-wmiobject win32_computersystem -ComputerName $ComputerName | select-object systemtype
		}
		
		$j = Start-Job -ScriptBlock $sb -ArgumentList $ComputerName
		Test-Timeout $computer 'Unable to get computer type. Job timed out.'
		
		$os = $j | Receive-Job -ErrorAction SilentlyContinue
		$j | Remove-Job -Force -ErrorAction SilentlyContinue
		
        If ($os.systemtype -eq $null) 
		{
            Write-Warning 'Hostname could not be resolved. Check for typos.'
        }
    } 
	
	Catch 
	{
        Write-Error $Error[0]
    }

    If ($os.systemtype -like [regex]'x64*') 
	{
        $type = "x64"
    } 
	ElseIf ($os.systemtype -like [regex]'x86*') 
	{
        $type = "x86"
    }
	
    Return $type
}

Function Get-AvailableFiles 
{
	$files = Get-ChildItem -Recurse -File $currentdir\files -Include $fileTypes
	$sources = Get-Content -Path $currentdir\app\data\sources.txt
	
	Foreach ($source in $sources) 
	{
		$files = $files + (Get-ChildItem -Recurse -File $source -Include $fileTypes)
	}
	
	Foreach ($file in $files) 
	{
		$type = 'n/a'
		
		If ($file.Name -match "-x86") 
		{
			$type = 'x86'
		} 
		ElseIf ($file.Name -match "-x64") 
		{
			$type = 'x64'
		} 
		ElseIf ($file.Name -match "-amd64") 
		{
			$type = 'x64'
		} 
		ElseIf ($file.Name -match "-ia64") 
		{
			$type = 'iTanium'
		} 
		Else {
			$type = 'all'
		}
		
		If ($type -ne 'iTanium') 
		{
			$gui.dgvFiles.Rows.Add($file.Directory.Name, $file.Name, $type, $file.DirectoryName) | Out-Null
		}
	}
}

Function addMenuItem 
{ 
	Param (
		[ref]$ParentItem, 
		[string]$ItemName='', 
		[string]$ItemText='', 
		[scriptblock]$ScriptBlock=$null 
	)
	
	[System.Windows.Forms.ToolStripMenuItem]$private:menuItem=`
	New-Object System.Windows.Forms.ToolStripMenuItem; 
	$private:menuItem.Name =$ItemName; 
	$private:menuItem.Text =$ItemText; 
	
	If ($ScriptBlock -ne $null) 
	{ 
		$private:menuItem.add_Click(([System.EventHandler]$handler=$ScriptBlock)) 
	} 
	
	If (($ParentItem.Value) -is [System.Windows.Forms.MenuStrip]) 
	{ 
		($ParentItem.Value).Items.Add($private:menuItem)
	}
	
	If (($ParentItem.Value) -is [System.Windows.Forms.ToolStripItem]) 
	{ 
		($ParentItem.Value).DropDownItems.Add($private:menuItem)
	} 
	
	Return $private:menuItem; 
}

Function Add-PatchFile 
{
	$files = $gui.dgvFiles.SelectedRows
	
	Foreach ($file in $files) 
	{ 
		$folder = $gui.dgvFiles.Rows[$file.Index].Cells['Folder'].Value
        $name = $gui.dgvFiles.Rows[$file.Index].Cells['Name'].Value
		$type = $gui.dgvFiles.Rows[$file.Index].Cells['Type'].Value
		$path = $gui.dgvFiles.Rows[$file.Index].Cells['Path'].Value
        $duplicate = "false"
        $gui.dgvInstall.Rows | foreach {
            $name2 = $gui.dgvInstall.Rows[$_.Index].Cells['Name'].Value
			If ($name2 -eq $name)
			{
                $duplicate = "true"
            }
        }
		
        If ($duplicate -ne "true")
		{
			$gui.dgvInstall.Rows.Add($folder, $name, $type, $path) | Out-Null
			
			If ($gui.listComputers.Items -ne $null) 
			{
				$gui.btnBuildInstall.Enabled = $true
			}
		} 
		Else 
		{
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("$name can't be added as it is already on the list.",0,"Duplicate Entry",0x0)
        }
    }
}

function Remove-PatchFile 
{
	$gui.dgvInstall.SelectedRows | foreach {
		$gui.dgvInstall.Rows.Remove($gui.dgvInstall.Rows[$_.Index])
	}

	if (($gui.dgvInstall.RowCount -eq 0) -or ($gui.listComputers.Items -eq $null)) {
		$gui.btnBuildInstall.Enabled = $false
	}
}

function Add-ComputerName 
{
	Param ([string]$computer)
	
	# Clear text box contents
	$gui.txtAddComputer.Clear()
	$gui.txtAddComputers.Clear()
	
	# Check that input value isn't blank
	If ($computer -eq '') 
	{
		Update-Log "You can't add a blank line."
		
		$wshell = New-Object -ComObject Wscript.Shell
	    $wshell.Popup("You can't add a blank line.",0,"Error",0x0)
	} 
	Else 
	{
	
		# Check that computer isn't already in list
	    $listItems = $gui.listComputers.Items
	    $duplicate = "false"
	    Foreach ($listItem in $listItems) 
		{
	        If ($listItem -eq $computer)
			{
	            $duplicate = "true"
				
				Update-Log "$computer can't be added as it is already in the list."
				
				$wshell = New-Object -ComObject Wscript.Shell
		    	$wshell.Popup("$computer can't be added as it is already in the list.",0,"Duplicate Entry",0x0)
	        }
	    }
			
	    If ($duplicate -ne "true")
		{	
#			# Test connection to avoid extended UI freeze due to connection timeouts
#			If (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Ignore)
#			{	
#				# Add to ListBox
#				$gui.listComputers.Items.Add("$computer")
#				
#				### Add to DataGridVeiw ###
#				
#				$obj = New-Object PSObject
#					
#				$obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computer
#					
#				## GET SYSTEM ARCHITECTURE
#                ## GET OS VERSION
#				$sb = {	
#					param ( [string]$computer )
#					Get-WmiObject -Computer $computer -Class Win32_OperatingSystem 
#				}
#				
#				$j = Start-Job -ScriptBlock $sb -ArgumentList $computer
#				Test-Timeout $computer 'Unable to get OS version. Job timed out.'
#				
#				$OS = $j | Receive-Job -ErrorAction SilentlyContinue 
#				$j | Remove-Job -Force -ErrorAction SilentlyContinue
#				
#                $obj | Add-Member -MemberType NoteProperty -Name "ComputerType" -Value $OS.OSArchitecture
#				$obj | Add-Member -MemberType NoteProperty -Name "OSVersion" -Value $OS.caption
#					
#				## GET IE VERSION
#				#$Hive = 'hklm'
#				#$Key = 'SOFTWARE\Microsoft\Internet Explorer'
#				#$Value = 'svcVersion'
#				#$ValueType = 'reg_sz'
#
#				#$RegValue = Get-RegValue -ComputerName $computer -Hive $Hive -Key $Key -Value $Value -ValueType $ValueType
#				
#				#$version = 0
#				#If ($RegValue -match '(\d+)\.') {
#				#	If ([int]$matches[1] -gt $version) {
#				#		$version = $matches[1]
#				#	}
#				#}
#				
#				#If ([int]$version -gt 0) {
#				#	$version = 'Internet Explorer ' + $version
#				#} else {
#				#	$version = 'Not Found'
#				#}
#							
#				#If ($version -eq 'Not Found') {
#				#	$Value = 'Version'
#				#	$RegValue = Get-RegValue -ComputerName $computer -Hive $Hive -Key $Key -Value $Value -ValueType $ValueType
#					
#				#	$version = 0
#				#	If ($RegValue -match '(\d+)\.') {
#				#		If ([int]$matches[1] -gt $version) {
#				#			$version = $matches[1]
#				#		}
#				#	}
#						
#				#	If ([int]$version -gt 0) {
#				#		$version = 'Internet Explorer ' + $version
#				#	} else {
#				#		$version = 'Not Found'
#				#	}
#				#}
#				
#				#$obj | Add-Member -MemberType NoteProperty -Name "IEVersion" -Value $version
#					
#				## GET OFFICE VERSION
#				#$version = 0
#		
#				#$sb = {
#				#	Param ( [string]$address )
#				#	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
#				#	$reg.OpenSubKey('software\Microsoft\Office').GetSubKeyNames() |% {
#				#		If ($_ -match '(\d+)\.') {
#				#			If ([int]$matches[1] -gt $version) {
#				#				$version = $matches[1]
#				#			}
#				#		}
#				#	}
#				
#				#	switch ($version) {
#				#		10 {$version = 'Office XP'; break}
#				#		11 {$version = 'Office 2003'; break}
#				#		12 {$version = 'Office 2007'; break}
#				#		14 {$version = 'Office 2010'; break}
#				#		15 {$version = 'Office 2013'; break}
#				#		default {$version = 'Not Installed'; break}
#				#	}
#					
#				#	$version
#				#}
#				
#				#$j = Start-Job -ScriptBlock $sb -ArgumentList $computer
#				#Test-Timeout $computer 'Unable to get Office version. Job timed out.'
#				
#				#$office = $j | Receive-Job
#				#$j | Remove-Job -Force -ErrorAction SilentlyContinue
#				
#				#$obj | Add-Member -MemberType NoteProperty -Name "OfficeVersion" -Value $office
#				
#				## Add to DataGridView
#				#$gui.dgvComputers.Rows.Add($obj.ComputerName, $obj.ComputerType, $obj.OSVersion, $obj.IEVersion, $obj.OfficeVersion) | Out-Null
#                $gui.dgvComputers.Rows.Add($obj.ComputerName, 'Online', $obj.ComputerType, $obj.OSVersion) | Out-Null
#				
#				Update-Log "$computer added."
#				
#				# Check dgv contents to enable/disable install button
#				If (($gui.dgvInstall.RowCount -ne 0) -and ($gui.dgvComputers.RowCount -ne 0)) 
#				{
#					$gui.btnBuildInstall.Enabled = $true
#				} 
#				Else 
#				{
#					$gui.btnBuildInstall.Enabled = $false
#				}
#				
#			} 
#			Else 
#			{
#		        Update-Log "$computer is offline. Skipping WMI calls."
#				
#				# Add to ListBox
#				$gui.listComputers.Items.Add("$computer")
#				
#				## Add to DataGridView
#				#$gui.dgvComputers.Rows.Add($computer,'','','','') | Out-Null
#                $gui.dgvComputers.Rows.Add($computer,'Offline','','') | Out-Null
#				
#				Update-Log "$computer added."
#		    }

            # Add to ListBox
			$gui.listComputers.Items.Add("$computer")
				
			## Add to DataGridView
            $gui.dgvComputers.Rows.Add($computer) | Out-Null
			
			Update-Log "$computer added."
		}
	}
}

function Remove-ComputerName 
{	
	Param ([string]$computer)
	
	$gui.listComputers.Items.Remove("$computer")
	
	Update-Log "Removing $computer from list."
	
	$rows = $gui.dgvComputers.Rows 
	Foreach ($row in $rows) 
	{
		If ($gui.dgvComputers.Rows[$row.Index].Cells['Computer Name'].Value -eq $computer) 
		{
			$gui.dgvComputers.Rows.Remove($gui.dgvComputers.Rows[$row.Index])
		}
	}
	
	If ($gui.listComputers.Items -eq $null) 
	{
		$gui.btnBuildInstall.Enabled = $false
	}
}

#endregion

#region: Get-Audit

function Get-Audit  
{
	Param ( [string]$computer )
	
	Update-Log " "
	Update-Log "$('-' * 50)"
	Update-Log "Starting Audit For: $computer"
	Update-Log "$('-' * 50)"
	
	$UserName = (Get-Item  env:\username).Value  
	$filepath = "$currentdir\audit"
	 
	Add-Content  $currentdir\audit\style.css  -Value " body { 
	font-family:Calibri; 
		font-size:10pt;   
	} 
	th {  
		background-color:black; 
		color:white; 
	} 
	td { 
		background-color:#19fff0; 
		color:black; 
	}" 
	 
	Update-Log "-- CSS File Created Successfully... Executing Inventory Report!!! Please Wait !!!"  
	#ReportDate 
	$ReportDate = Get-Date | Select -Property DateTime |ConvertTo-Html -Fragment 
	 
	#General Information 
	Update-Log "-- Getting System Info"
	$ComputerSystem = Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem |  
	Select -Property Model , Manufacturer , Description , PrimaryOwnerName , SystemType |ConvertTo-Html -Fragment 
	 
	#Boot Configuration 
	Update-Log "-- Getting Boot Config Info"
	$BootConfiguration = Get-WmiObject -ComputerName $computer -Class Win32_BootConfiguration | 
	Select -Property Name , ConfigurationPath | ConvertTo-Html -Fragment  
	 
	#BIOS Information 
	Update-Log "-- Getting BIOS Info"
	$BIOS = Get-WmiObject -ComputerName $computer -Class Win32_BIOS | Select -Property PSComputerName , Manufacturer , Version | ConvertTo-Html -Fragment 
	 
	#Operating System Information 
	Update-Log "-- Getting OS Info"
	$OS = Get-WmiObject -ComputerName $computer -Class Win32_OperatingSystem | Select -Property Caption , CSDVersion , OSArchitecture , OSLanguage | ConvertTo-Html -Fragment 
	 
	#Time Zone Information 
	Update-Log "-- Getting Timezone"
	$TimeZone = Get-WmiObject -ComputerName $computer -Class Win32_TimeZone | Select Caption , StandardName | 
	ConvertTo-Html -Fragment 
	 
	#Logical Disk Information 
	Update-Log "-- Getting Disk Info"
	$Disk = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter DriveType=3 |  
	Select SystemName , DeviceID , @{Name=”size(GB)”;Expression={“{0:N1}” -f($_.size/1gb)}}, @{Name=”freespace(GB)”;Expression={“{0:N1}” -f($_.freespace/1gb)}} | 
	ConvertTo-Html -Fragment 
	 
	#CPU Information 
	Update-Log "-- Getting CPU info"
	$SystemProcessor = Get-WmiObject -ComputerName $computer -Class Win32_Processor  |  
	Select SystemName , Name , MaxClockSpeed , Manufacturer , status |ConvertTo-Html -Fragment 
	 
	#Memory Information 
	Update-Log "-- Getting Physical Memory"
	$PhysicalMemory = Get-WmiObject -ComputerName $computer -Class Win32_PhysicalMemory | 
	Select -Property Tag , SerialNumber , PartNumber , Manufacturer , DeviceLocator , @{Name="Capacity(GB)";Expression={"{0:N1}" -f ($_.Capacity/1GB)}} | ConvertTo-Html -Fragment 
	 
	#Software Inventory 
	Update-Log "-- Getting Software Info"
	$Software = Get-WmiObject -ComputerName $computer -Class Win32_Product | 
	Select Name , Vendor , Version , Caption | ConvertTo-Html -Fragment  
	
	Update-Log "-- Generating Audit Report" 
	
	ConvertTo-Html -Body "<font color = blue><H4><B>Report Executed On</B></H4></font>$ReportDate 
	<font color = blue><H4><B>General Information</B></H4></font>$ComputerSystem 
	<font color = blue><H4><B>Boot Configuration</B></H4></font>$BootConfiguration 
	<font color = blue><H4><B>BIOS Information</B></H4></font>$BIOS 
	<font color = blue><H4><B>Operating System Information</B></H4></font>$OS 
	<font color = blue><H4><B>Time Zone Information</B></H4></font>$TimeZone 
	<font color = blue><H4><B>Disk Information</B></H4></font>$Disk 
	<font color = blue><H4><B>Processor Information</B></H4></font>$SystemProcessor 
	<font color = blue><H4><B>Memory Information</B></H4></font>$PhysicalMemory 
	<font color = blue><H4><B>Software Inventory</B></H4></font>$Software" -CssUri  "$filepath\style.CSS" -Title "Server Inventory" | Out-File "$currentdir\audit\$Computer.html" 
	 
	Update-Log "-- Audit Execution Complete"
	Invoke-Item -Path "$currentdir\audit\$Computer.html"
	
	Update-Log "$('-' * 50)"
}

#endregion: Get-Audit