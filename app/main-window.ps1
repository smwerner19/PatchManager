# Main form
Function GenerateForm 
{
    # Create Form
    $gui.form1 = New-Object System.Windows.Forms.Form
    $gui.form1.Text = "Patch Manager"
    $gui.form1.StartPosition = 4
    $gui.form1.ClientSize = "1130,815"
	$gui.form1.BackColor = 'White'
	
	#region: Menu
	$gui.menu = New-Object System.Windows.Forms.MenuStrip
	$gui.form1.Controls.Add($gui.menu)
	
	#region Menu Items
	#region Scriptblocks
	$sbExit = {
		$gui.form1.Close()
	}
	
	$sbSources = {
		GenerateSourcesForm
	}
	
	$sbSwitches = {
		GenerateSwitchForm
	}
	#endregion Scriptblocks
	
	#region File 
	(addMenuItem -ParentItem ([ref]$gui.menu) -ItemName 'mnuFile' -ItemText 'File' -ScriptBlock $null) | %{ 
	$null=addMenuItem -ParentItem ([ref]$_) -ItemName 'mnuFileExit' -ItemText 'Exit' -ScriptBlock $sbExit;} | Out-Null; 
	#endregion File
	
	#region Options
	(addMenuItem -ParentItem ([ref]$gui.menu) -ItemName 'mnuOptions' -ItemText 'Options' -ScriptBlock $null) | %{ 
		(addMenuItem -ParentItem ([ref]$_) -ItemName 'mnuOptionsRemoteInstall' -ItemText 'Remote Install' -ScriptBlock $null) | %{ 
			$null=addMenuItem -ParentItem ([ref]$_) -ItemName 'mnuOptionsRemoteInstallSources' -ItemText 'File Sources' -ScriptBlock $sbSources; 
			$null=addMenuItem -ParentItem ([ref]$_) -ItemName 'mnuOptionsRemoteInstallSwitches' -ItemText 'Install Switches' -ScriptBlock $sbSwitches;
		}
	}
	#endregion Options
	
	#endregion Menu Items
	#endregion: menu
	
	#region: Create GroupBox for Computers
	$gui.grpComputers = New-Object System.Windows.Forms.GroupBox
	$gui.grpComputers.Size = DrawSize(280)(530)
	$gui.grpComputers.Location = DrawPoint(10)(35)
	$gui.grpComputers.Text = 'Computers'
	$gui.grpComputers.Anchor = 'top, left, bottom'
	$gui.grpComputers.BackColor = '#D1D'
	$gui.form1.Controls.Add($gui.grpComputers)

	# Create listbox for computers
	$gui.listComputers = New-Object System.Windows.Forms.ListBox
	$gui.listComputers.Size = DrawSize(258)(480)
	$gui.listComputers.Location = DrawPoint(10)(49)
	$gui.listComputers.BackColor = '#E3E3E3'
	$gui.listComputers.Anchor = 'top, bottom'
	$gui.grpComputers.Controls.Add($gui.listComputers)
	
	# Create KeyPress event for textbox
	$gui.listComputers.add_KeyDown({
		if($_.KeyCode -eq 'Delete') {
			$c = $gui.listComputers.SelectedItem
			Remove-ComputerName $c
		}
	})
	
	# Create Context Menu for Computers List
	$gui.computersContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
	
	$gui.contextRemoveComputer = New-Object System.Windows.Forms.ToolStripMenuItem
	$gui.contextRemoveComputer.Text = 'Remove Selected Computer'
	$gui.contextRemoveComputer.add_Click({ $c = $gui.listComputers.SelectedItem; Remove-ComputerName $c })
	$gui.computersContextMenu.Items.Add($gui.contextRemoveComputer)
	
	$gui.listComputers.ContextMenuStrip = $gui.computersContextMenu
	
	# Create textbox to add computers
	$gui.txtAddComputer = New-Object System.Windows.Forms.TextBox
	$gui.txtAddComputer.Size = DrawSize(202)(30)
	$gui.txtAddComputer.Location = DrawPoint(10)(20)
	$gui.txtAddComputer.BorderStyle = 'FixedSingle'
	$gui.txtAddComputer.BackColor = '#E3E3E3'
	$gui.txtAddComputer.Anchor = 'top'
	$gui.grpComputers.Controls.Add($gui.txtAddComputer)
	
	# Create KeyPress event for textbox
	$gui.txtAddComputer.add_KeyDown({
		if($_.KeyCode -eq 'Enter') {
			$c = $gui.txtAddComputer.Text
			Add-ComputerName $c
		}
	})
	
	# Create add button
	$gui.btnAddComputer = New-Object System.Windows.Forms.Button
	$gui.btnAddComputer.Size = DrawSize(23)(24)
	$gui.btnAddComputer.Location = DrawPoint(218)(19)
	$gui.btnAddComputer.Text = '+'
	$gui.btnAddComputer.Anchor = 'top'
	$gui.grpComputers.Controls.Add($gui.btnAddComputer)
	
	# Create remove button
	$gui.btnRemoveComputer = New-Object System.Windows.Forms.Button
	$gui.btnRemoveComputer.Size = DrawSize(23)(24)
	$gui.btnRemoveComputer.Location = DrawPoint(245)(19)
	$gui.btnRemoveComputer.Text = '-'
	$gui.btnRemoveComputer.Anchor = 'top'
	$gui.grpComputers.Controls.Add($gui.btnRemoveComputer)
	
	# onClick Event for btnAddComputer button control
    $gui.btnAddComputer.add_Click({
        $c = $gui.txtAddComputer.Text
		Add-ComputerName $c
    })
	
	# onClick Event for btnRemoveComputer button control
    $gui.btnRemoveComputer.add_Click({
        $c = $gui.listComputers.SelectedItem
		Remove-ComputerName $c
    })
	
	#endregion: Create GroupBox for Computers
	
	#region: Tabs
	# Creating Tab Control
    $gui.tabContainer = New-Object System.Windows.Forms.TabControl
    $gui.tabContainer.Size = DrawSize(820)(770)
    $gui.tabContainer.Location = DrawPoint(300)(35)
    $gui.tabContainer.SelectedIndex = 0
    $gui.tabContainer.Anchor = 'top, left, right, bottom'
    $gui.form1.Controls.Add($gui.tabContainer)

	$gui.tabComputers = New-Object System.Windows.Forms.TabPage
    $gui.tabComputers.Size = DrawSize(820)(770)
    $gui.tabComputers.Text = 'Computers'
    $gui.tabComputers.TabIndex = 0
    $gui.tabComputers.UseVisualStyleBackColor = $true
    $gui.tabContainer.Controls.Add($gui.tabComputers)
	
    $gui.tabRemoteInstall = New-Object System.Windows.Forms.TabPage
    $gui.tabRemoteInstall.Size = DrawSize(820)(770)
    $gui.tabRemoteInstall.Text = 'Remote Install'
    $gui.tabRemoteInstall.TabIndex = 0
    $gui.tabRemoteInstall.UseVisualStyleBackColor = $true
    $gui.tabContainer.Controls.Add($gui.tabRemoteInstall)

    $gui.tabSccmActions = New-Object System.Windows.Forms.TabPage
    $gui.tabSccmActions.Size = DrawSize(820)(770)
    $gui.tabSccmActions.Text = 'SCCM Client Actions'
    $gui.tabSccmActions.TabIndex = 1
    $gui.tabSccmActions.UseVisualStyleBackColor = $true
#    $gui.tabContainer.Controls.Add($gui.tabSccmActions)
	
	$gui.tabWsusActions = New-Object System.Windows.Forms.TabPage
    $gui.tabWsusActions.Size = DrawSize(820)(770)
    $gui.tabWsusActions.Text = 'WSUS Actions'
    $gui.tabWsusActions.TabIndex = 2
    $gui.tabWsusActions.UseVisualStyleBackColor = $true
#    $gui.tabContainer.Controls.Add($gui.tabWsusActions)
	
	#endregion: Tabs
	
	#region: Tab Content: Computers
	
	#region: Create groupbox for computer list
	$gui.grpComputerList = New-Object System.Windows.Forms.GroupBox
	$gui.grpComputerList.Size = DrawSize(800)(620)
	$gui.grpComputerList.Location = DrawPoint(10)(10)
	$gui.grpComputerList.Text = 'Computer List'
	$gui.grpComputerList.Anchor = 'top, left, right, bottom'
	$gui.tabComputers.Controls.Add($gui.grpComputerList)
	
	#Create Label
	$gui.lblComputerList = New-Object System.Windows.Forms.Label
	$gui.lblComputerList.Size = DrawSize(250)(20)
	$gui.lblComputerList.Location = DrawPoint(10)(25)
	$gui.lblComputerList.Text = 'Detailed listing of Computers in list:'
	$gui.grpComputerList.Controls.Add($gui.lblComputerList)
	
	# Create DataGridView for Computers
	$gui.dgvComputers = New-Object System.Windows.Forms.DataGridView
	$gui.dgvComputers.Size = DrawSize(780)(560)
	$gui.dgvComputers.Location = DrawPoint(10)(50)
	$gui.dgvComputers.ColumnCount = 1
    $gui.dgvComputers.Columns[0].Name = "Computer Name"
#    $gui.dgvComputers.Columns[1].Name = "Status"
#    $gui.dgvComputers.Columns[2].Name = "Type"
#    $gui.dgvComputers.Columns[3].Name = "OS Version"
	#$gui.dgvComputers.Columns[3].Name = "IE Version"
	#$gui.dgvComputers.Columns[4].Name = "Office Version"
    $gui.dgvComputers.Columns[0].Width = 200
#    $gui.dgvComputers.Columns[1].Width = 100
#    $gui.dgvComputers.Columns[2].Width = 50
#    $gui.dgvComputers.Columns[3].Width = 300
	#$gui.dgvComputers.Columns[3].Width = 150
	#$gui.dgvComputers.Columns[4].Width = 150
    $gui.dgvComputers.SelectionMode = "fullrowselect"
    $gui.dgvComputers.TabIndex = 0
	$gui.dgvComputers.Anchor = 'top, left, right, bottom'
	$gui.dgvComputers.AllowUserToAddRows = $false
	$gui.dgvComputers.AllowUserToDeleteRows = $false
	$gui.dgvComputers.ReadOnly = $true
	$gui.grpComputerList.Controls.Add($gui.dgvComputers)
	
	# Create KeyPress event for textbox
	$gui.dgvComputers.add_KeyDown({
		if($_.KeyCode -eq 'Delete') {
			$rows = $gui.dgvComputers.SelectedRows
		
			foreach ($row in $rows) {
				$c = $gui.dgvComputers.Rows[$row.Index].Cells['Computer Name'].Value	
				Remove-ComputerName $c
			}
		}
	})
	
	# Create Save Button
	$gui.btnSaveComputers = New-Object System.Windows.Forms.Button
	$gui.btnSaveComputers.Size = DrawSize(100)(23)
	$gui.btnSaveComputers.Location = DrawPoint(690)(20)
	$gui.btnSaveComputers.Text = 'Save List'
	$gui.btnSaveComputers.Anchor = 'top, right'
	$gui.grpComputerList.Controls.Add($gui.btnSaveComputers)
	
	# Create Load Button
	$gui.btnLoadComputers = New-Object System.Windows.Forms.Button
	$gui.btnLoadComputers.Size = DrawSize(100)(23)
	$gui.btnLoadComputers.Location = DrawPoint(588)(20)
	$gui.btnLoadComputers.Text = 'Load List'
	$gui.btnLoadComputers.Anchor = 'top, right'
	$gui.grpComputerList.Controls.Add($gui.btnLoadComputers)
	
	# Create Load Button
	$gui.btnAuditComputers = New-Object System.Windows.Forms.Button
	$gui.btnAuditComputers.Size = DrawSize(100)(23)
	$gui.btnAuditComputers.Location = DrawPoint(486)(20)
	$gui.btnAuditComputers.Text = 'Audit'
	$gui.btnAuditComputers.Anchor = 'top, right'
	$gui.grpComputerList.Controls.Add($gui.btnAuditComputers)
	
	# onClick Event for btnSaveComputer button control
    $gui.btnSaveComputers.add_Click({
		# Open save file dialog window
		$fd = New-Object system.windows.forms.savefiledialog
		$fd.InitialDirectory =  $currentdir + "\groups"
		$fd.Filter = "Comma Separated Values file|*.csv"
		$fd.showdialog()
		
		# Set full filepath and remove the file, if it already exists
		$name = $fd.filename
		Remove-Item -Path $name -ErrorAction Ignore
        
		# Get rows from Computer List
		$rows = $gui.dgvComputers.Rows
		
		# Write headers to file
#		$out = '"ComputerName","Status","Type","OSVersion"' ## ,"IEVersion","OfficeVersion"'
		$out = '"ComputerName"'
		Add-Content $name -Value $out
		
		# Write rows to file
		foreach ($row in $rows) {
			$Computer = @{}
			
			$Computer.Name = $gui.dgvComputers.Rows[$row.Index].Cells['Computer Name'].Value
#            $Computer.Status = $gui.dgvComputers.Rows[$row.Index].Cells['Status'].Value
#			$Computer.Type = $gui.dgvComputers.Rows[$row.Index].Cells['Type'].Value
#			$Computer.Os = $gui.dgvComputers.Rows[$row.Index].Cells['OS Version'].Value
			#$Computer.IE = $gui.dgvComputers.Rows[$row.Index].Cells['IE Version'].Value
			#$Computer.Office = $gui.dgvComputers.Rows[$row.Index].Cells['Office Version'].Value
			
#			$out = '"' + $Computer.Name + '","' + $Computer.Status + '","' + $Computer.Type + '","' + $Computer.Os ## + '","' + $Computer.IE + '","' + $Computer.Office + '"'
			$out = '"' + $Computer.Name + '"'
			Add-Content $name -Value $out
		}
    })
	
	# onClick Event for btnLoadComputer button control
    $gui.btnLoadComputers.add_Click({
        # Open load file dialog window
		$fd = New-Object system.windows.forms.openfiledialog
		$fd.InitialDirectory =  $currentdir + "\groups"
		$fd.Filter = "Comma Separated Values file|*.csv"
		$fd.MultiSelect = $false
		$fd.showdialog()
		
		# Clear Computer Lists
		$gui.listComputers.Items.Clear()
		$gui.dgvComputers.Rows.Clear()
		
		# Import CSV file
		$rows = Import-Csv $fd.filename
		
		# Add Computers to Lists
		foreach ($row in $rows) {
			# Add to listbox
			$gui.listComputers.Items.Add($row.ComputerName) | Out-Null
			
			# Add to DataGridView
#			$gui.dgvComputers.Rows.Add($row.ComputerName, $row.Status, $row.Type, $row.OSVersion) | Out-Null ##, $row.IEVersion, $row.OfficeVersion) | Out-Null
			$gui.dgvComputers.Rows.Add($row.ComputerName) | Out-Null
		}
		
		if (($gui.dgvInstall.RowCount -ne 0) -and ($gui.listComputers.Items -ne $null)) {
			$gui.btnBuildInstall.Enabled = $true
		} else {
			$gui.btnBuildInstall.Enabled = $false
		}
    })
	
	$gui.btnAuditComputers.add_Click({
		$rows = $gui.listComputers.Items
		foreach ($row in $rows) {
			if (Test-Connection $row -Count 1 -ErrorAction Ignore) {
				Get-Audit $row
			} else {
				Write-Host "$row offine"
			}
		}
	})
	
	#endregion: Create groupbox for computer list
	
	#region: Create Groupbox for add computers
	$gui.grpAddComputers = New-Object System.Windows.Forms.GroupBox
	$gui.grpAddComputers.Size = DrawSize(800)(57)
	$gui.grpAddComputers.Location = DrawPoint(10)(636)
	$gui.grpAddComputers.Text = 'Add Computers'
	$gui.grpAddComputers.Anchor = 'left, right, bottom'
	$gui.tabComputers.Controls.Add($gui.grpAddComputers)
	
	# Create textbox to add computers
	$gui.txtAddComputers = New-Object System.Windows.Forms.TextBox
	$gui.txtAddComputers.Size = DrawSize(471)(29)
	$gui.txtAddComputers.Location = DrawPoint(10)(21)
	$gui.txtAddComputers.BorderStyle = 'FixedSingle'
	$gui.txtAddComputers.BackColor = '#E3E3E3'
	$gui.txtAddComputers.Anchor = 'top, left, right'
	$gui.grpAddComputers.Controls.Add($gui.txtAddComputers)
	
	# Create KeyPress event for textbox
	$gui.txtAddComputers.add_KeyDown({
		if($_.KeyCode -eq 'Enter') {
			$c = $gui.txtAddComputers.Text
			Add-ComputerName $c
		}
	})
	
	# Create add button
	$gui.btnAddComputers = New-Object System.Windows.Forms.Button
	$gui.btnAddComputers.Size = DrawSize(100)(24)
	$gui.btnAddComputers.Location = DrawPoint(486)(20)
	$gui.btnAddComputers.Text = 'Add'
	$gui.btnAddComputers.Anchor = 'top, right'
	$gui.grpAddComputers.Controls.Add($gui.btnAddComputers)
	
	# onClick Event for btnAddComputer button control
    $gui.btnAddComputers.add_Click({
        $c = $gui.txtAddComputers.Text
		Add-ComputerName $c	
    })
	
	# Create remove button
	$gui.btnRemoveComputers = New-Object System.Windows.Forms.Button
	$gui.btnRemoveComputers.Size = DrawSize(100)(24)
	$gui.btnRemoveComputers.Location = DrawPoint(588)(20)
	$gui.btnRemoveComputers.Text = 'Remove'
	$gui.btnRemoveComputers.Anchor = 'top, right'
	$gui.grpAddComputers.Controls.Add($gui.btnRemoveComputers)
	
	# onClick Event for btnRemoveComputer button control
    $gui.btnRemoveComputers.add_Click({
        $rows = $gui.dgvComputers.SelectedRows
		
		foreach ($row in $rows) {
			$c = $gui.dgvComputers.Rows[$row.Index].Cells['Computer Name'].Value	
			Remove-ComputerName $c
		}
    })
	
	# Create load txt button
	$gui.btnLoadTxt = New-Object System.Windows.Forms.Button
	$gui.btnLoadTxt.Size = DrawSize(100)(24)
	$gui.btnLoadTxt.Location = DrawPoint(690)(20)
	$gui.btnLoadTxt.Text = 'Load .txt'
	$gui.btnLoadTxt.Anchor = 'top, right'
	$gui.grpAddComputers.Controls.Add($gui.btnLoadTxt)
	
	$gui.btnLoadTxt.add_Click({
		# Open load file dialog window
		$fd = New-Object system.windows.forms.openfiledialog
		$fd.InitialDirectory =  $currentdir + "\groups"
		$fd.Filter = "Text Document|*.txt"
		$fd.MultiSelect = $false
		$fd.showdialog()
		
		$computers = Get-Content $fd.filename
		
		foreach ($computer in $computers) {
			Add-ComputerName $computer
		}
	})
	
	#endregion: Create Groupbox for add computers
	
	#region: Create Groupbox for scan IP range
	$gui.grpScanIpRange = New-Object System.Windows.Forms.GroupBox
	$gui.grpScanIpRange.Size = DrawSize(800)(57)
	$gui.grpScanIpRange.Location = DrawPoint(10)(700)
	$gui.grpScanIpRange.Text = 'Scan IP Range'
	$gui.grpScanIpRange.Anchor = 'left, right, bottom'
	$gui.tabComputers.Controls.Add($gui.grpScanIpRange)
	
	# Create Scan IP Range button
	$gui.btnScanRange = New-Object System.Windows.Forms.Button
	$gui.btnScanRange.Size = DrawSize(100)(23)
	$gui.btnScanRange.Location = DrawPoint(690)(20)
	$gui.btnScanRange.Text = 'Scan Range'
	$gui.btnScanRange.Anchor = 'top, right'
	$gui.grpScanIpRange.Controls.Add($gui.btnScanRange)
	
	$gui.btnScanRange.add_Click({		
		Scan-Range
	})
	
	# Create label
	$gui.lblstart = New-Object System.Windows.Forms.Label
	$gui.lblstart.Size = DrawSize(80)(20)
	$gui.lblstart.Location = DrawPoint(10)(25)
	$gui.lblstart.Text = 'Starting IP:'
	$gui.grpScanIpRange.Controls.Add($gui.lblstart)
	
	# Create label
	$gui.lblend = New-Object System.Windows.Forms.Label
	$gui.lblend.Size = DrawSize(80)(20)
	$gui.lblend.Location = DrawPoint(340)(25)
	$gui.lblend.Text = 'Ending IP:'
	$gui.grpScanIpRange.Controls.Add($gui.lblend)
	
	# Create label
	$gui.lbldot1 = New-Object System.Windows.Forms.Label
	$gui.lbldot1.Size = DrawSize(8)(20)
	$gui.lbldot1.Location = DrawPoint(132)(25)
	$gui.lbldot1.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot1)
	# Create label
	$gui.lbldot2 = New-Object System.Windows.Forms.Label
	$gui.lbldot2.Size = DrawSize(8)(20)
	$gui.lbldot2.Location = DrawPoint(185)(25)
	$gui.lbldot2.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot2)
	# Create label
	$gui.lbldot3 = New-Object System.Windows.Forms.Label
	$gui.lbldot3.Size = DrawSize(8)(20)
	$gui.lbldot3.Location = DrawPoint(236)(25)
	$gui.lbldot3.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot3)
	
	# Create label
	$gui.lbldot4 = New-Object System.Windows.Forms.Label
	$gui.lbldot4.Size = DrawSize(8)(20)
	$gui.lbldot4.Location = DrawPoint(462)(25)
	$gui.lbldot4.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot4)
	# Create label
	$gui.lbldot5 = New-Object System.Windows.Forms.Label
	$gui.lbldot5.Size = DrawSize(8)(20)
	$gui.lbldot5.Location = DrawPoint(515)(25)
	$gui.lbldot5.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot5)
	# Create label
	$gui.lbldot6 = New-Object System.Windows.Forms.Label
	$gui.lbldot6.Size = DrawSize(8)(20)
	$gui.lbldot6.Location = DrawPoint(566)(25)
	$gui.lbldot6.Text = '.'
	$gui.grpScanIpRange.Controls.Add($gui.lbldot6)
	
	# Create textboxes for starting IP
	$gui.start1 = New-Object System.Windows.Forms.TextBox
	$gui.start1.Size = DrawSize(40)(30)
	$gui.start1.Location = DrawPoint(94)(21)
	$gui.start1.BorderStyle = 'FixedSingle'
	$gui.start1.BackColor = '#E3E3E3'
	$gui.start1.Anchor = 'top'
	$gui.start1.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.start1)
	$gui.start1.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})

	$gui.start2 = New-Object System.Windows.Forms.TextBox
	$gui.start2.Size = DrawSize(40)(30)
	$gui.start2.Location = DrawPoint(146)(21)
	$gui.start2.BorderStyle = 'FixedSingle'
	$gui.start2.BackColor = '#E3E3E3'
	$gui.start2.Anchor = 'top'
	$gui.start2.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.start2)
	$gui.start2.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	$gui.start3 = New-Object System.Windows.Forms.TextBox
	$gui.start3.Size = DrawSize(40)(30)
	$gui.start3.Location = DrawPoint(198)(21)
	$gui.start3.BorderStyle = 'FixedSingle'
	$gui.start3.BackColor = '#E3E3E3'
	$gui.start3.Anchor = 'top'
	$gui.start3.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.start3)
	$gui.start3.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	$gui.start4 = New-Object System.Windows.Forms.TextBox
	$gui.start4.Size = DrawSize(40)(30)
	$gui.start4.Location = DrawPoint(250)(21)
	$gui.start4.BorderStyle = 'FixedSingle'
	$gui.start4.BackColor = '#E3E3E3'
	$gui.start4.Anchor = 'top'
	$gui.start4.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.start4)
	$gui.start3.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	# Create textboxes for ending IP
	$gui.end1 = New-Object System.Windows.Forms.TextBox
	$gui.end1.Size = DrawSize(40)(30)
	$gui.end1.Location = DrawPoint(424)(21)
	$gui.end1.BorderStyle = 'FixedSingle'
	$gui.end1.BackColor = '#E3E3E3'
	$gui.end1.Anchor = 'top'
	$gui.end1.Anchor = 'top'
	$gui.end1.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.end1)
	$gui.end1.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})

	$gui.end2 = New-Object System.Windows.Forms.TextBox
	$gui.end2.Size = DrawSize(40)(30)
	$gui.end2.Location = DrawPoint(476)(21)
	$gui.end2.BorderStyle = 'FixedSingle'
	$gui.end2.BackColor = '#E3E3E3'
	$gui.end2.Anchor = 'top'
	$gui.end2.Anchor = 'top'
	$gui.end2.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.end2)
	$gui.end2.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	$gui.end3 = New-Object System.Windows.Forms.TextBox
	$gui.end3.Size = DrawSize(40)(30)
	$gui.end3.Location = DrawPoint(528)(21)
	$gui.end3.BorderStyle = 'FixedSingle'
	$gui.end3.BackColor = '#E3E3E3'
	$gui.end3.Anchor = 'top'
	$gui.end3.Anchor = 'top'
	$gui.end3.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.end3)
	$gui.end3.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	$gui.end4 = New-Object System.Windows.Forms.TextBox
	$gui.end4.Size = DrawSize(40)(30)
	$gui.end4.Location = DrawPoint(580)(21)
	$gui.end4.BorderStyle = 'FixedSingle'
	$gui.end4.BackColor = '#E3E3E3'
	$gui.end4.Anchor = 'top'
	$gui.end4.Anchor = 'top'
	$gui.end4.MaxLength = 3
	$gui.grpScanIpRange.Controls.Add($gui.end4)
	$gui.end4.Add_TextChanged({
		$this.Text = $this.Text -replace '\D'
	})
	
	#endregion: Create Groupbox for scan IP range
	
	#endregion: Tab Content: Computers
	
	#region: Tab Content: Remote Install
	
	#region: Create groupbox for available patches
	$gui.grpPatches = New-Object System.Windows.Forms.GroupBox
	$gui.grpPatches.Size = DrawSize(800)(360)
	$gui.grpPatches.Location = DrawPoint(10)(10)
	$gui.grpPatches.Text = 'Available Patches'
	$gui.grpPatches.Anchor = 'top, left, right, bottom'
	$gui.tabRemoteInstall.Controls.Add($gui.grpPatches)
	
	#Create Label
	$gui.lblPatches = New-Object System.Windows.Forms.Label
	$gui.lblPatches.Size = DrawSize(200)(20)
	$gui.lblPatches.Location = DrawPoint(10)(25)
	$gui.lblPatches.Text = 'Files found in directory:'
	$gui.grpPatches.Controls.Add($gui.lblPatches)
	
	# Create DataGridView
	$gui.dgvFiles = New-Object System.Windows.Forms.DataGridView
	$gui.dgvFiles.Size = DrawSize(780)(300)
	$gui.dgvFiles.Location = DrawPoint(10)(50)
	$gui.dgvFiles.ColumnCount = 4
    $gui.dgvFiles.Columns[0].Name = "Folder"
    $gui.dgvFiles.Columns[1].Name = "Name"
    $gui.dgvFiles.Columns[2].Name = "Type"
	$gui.dgvFiles.Columns[3].Name = "Path"
    $gui.dgvFiles.Columns[0].Width = 200
    $gui.dgvFiles.Columns[1].Width = 470
    $gui.dgvFiles.Columns[2].Width = 60
	$gui.dgvFiles.Columns[3].Width = 765
    $gui.dgvFiles.SelectionMode = "fullrowselect"
    $gui.dgvFiles.TabIndex = 0
	$gui.dgvFiles.Anchor = 'top, left, right, bottom'
	$gui.dgvFiles.AllowUserToAddRows = $false
	$gui.dgvFiles.AllowUserToDeleteRows = $false
	$gui.dgvFiles.ReadOnly = $true
	$gui.grpPatches.Controls.Add($gui.dgvFiles)
	
	# Create KeyPress event for dgvFiles
	$gui.dgvFiles.add_KeyDown({
		if($_.KeyCode -eq 'Enter') {
			Add-PatchFile
		}
	})
	
	# Create Context Menu for available patches
	$gui.dgvFilesContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
	
	$gui.contextAddFiles = New-Object System.Windows.Forms.ToolStripMenuItem
	$gui.contextAddFiles.Text = 'Add Selected'
	$gui.contextAddFiles.add_Click({ Add-PatchFile })
	$gui.dgvFilesContextMenu.Items.Add($gui.contextAddFiles)
	
	$gui.dgvFiles.ContextMenuStrip = $gui.dgvFilesContextMenu
	
	# Populate DataGridView
	Get-AvailableFiles
	
	# Create Refresh Button
	$gui.btnRefreshFiles = New-Object System.Windows.Forms.Button
	$gui.btnRefreshFiles.Size = DrawSize(100)(23)
	$gui.btnRefreshFiles.Location = DrawPoint(690)(20)
	$gui.btnRefreshFiles.Text = 'Refresh'
	$gui.btnRefreshFiles.Anchor = 'top, right'
	$gui.grpPatches.Controls.Add($gui.btnRefreshFiles)
	
	$gui.btnRefreshFiles.add_Click({
		$gui.dgvFiles.Rows.Clear()
		Get-AvailableFiles
	})
	
	# Create Sources Button
	$gui.btnFileSources = New-Object System.Windows.Forms.Button
	$gui.btnFileSources.Size = DrawSize(100)(23)
	$gui.btnFileSources.Location = DrawPoint(588)(20)
	$gui.btnFileSources.Text = 'Sources'
	$gui.btnFileSources.Anchor = 'top, right'
	$gui.grpPatches.Controls.Add($gui.btnFileSources)
	
	$gui.btnFileSources.add_Click({
		GenerateSourcesForm
	})
	#endregion: Create groupbox for available patches
	
	#region: Create GroupBox for Install List
	$gui.grpInstall = New-Object System.Windows.Forms.GroupBox
	$gui.grpInstall.Size = DrawSize(800)(360)
	$gui.grpInstall.Location = DrawPoint(10)(400)
	$gui.grpInstall.Text = 'Install List'
	$gui.grpInstall.Anchor = 'left, right, bottom'
	$gui.tabRemoteInstall.Controls.Add($gui.grpInstall)
	
	#Create Label
	$gui.lblPatches = New-Object System.Windows.Forms.Label
	$gui.lblPatches.Size = DrawSize(200)(20)
	$gui.lblPatches.Location = DrawPoint(10)(25)
	$gui.lblPatches.Text = 'Files to be installed:'
	$gui.grpInstall.Controls.Add($gui.lblPatches)
	
	# Create DataGridView
	$gui.dgvInstall = New-Object System.Windows.Forms.DataGridView
	$gui.dgvInstall.Size = DrawSize(780)(300)
	$gui.dgvInstall.Location = DrawPoint(10)(50)
	$gui.dgvInstall.ColumnCount = 4
    $gui.dgvInstall.Columns[0].Name = "Folder"
    $gui.dgvInstall.Columns[1].Name = "Name"
    $gui.dgvInstall.Columns[2].Name = "Type"
	$gui.dgvInstall.Columns[3].Name = "Path"
    $gui.dgvInstall.Columns[0].Width = 200
    $gui.dgvInstall.Columns[1].Width = 470
    $gui.dgvInstall.Columns[2].Width = 60
	$gui.dgvInstall.Columns[3].Width = 765
    $gui.dgvInstall.SelectionMode = "fullrowselect"
    $gui.dgvInstall.TabIndex = 0
	$gui.dgvInstall.Anchor = 'top, left, right, bottom'
	$gui.dgvInstall.AllowUserToAddRows = $false
	$gui.dgvInstall.AllowUserToDeleteRows = $false
	$gui.dgvInstall.ReadOnly = $true
	$gui.grpInstall.Controls.Add($gui.dgvInstall)
	
	$gui.dgvFiles.add_KeyDown({
		if($_.KeyCode -eq 'Delete') {
			Remove-PatchFile
		}
	})
	
	# Create Context Menu for available patches
	$gui.dgvInstallContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
	
	$gui.contextRemoveFiles = New-Object System.Windows.Forms.ToolStripMenuItem
	$gui.contextRemoveFiles.Text = 'Remove Selected'
	$gui.contextRemoveFiles.add_Click({ Remove-PatchFile })
	$gui.dgvInstallContextMenu.Items.Add($gui.contextRemoveFiles)
	
	$gui.dgvInstall.ContextMenuStrip = $gui.dgvInstallContextMenu
	
	# Create Switches Button
	$gui.btnInstallSwitches = New-Object System.Windows.Forms.Button
	$gui.btnInstallSwitches.Size = DrawSize(100)(23)
	$gui.btnInstallSwitches.Location = DrawPoint(690)(20)
	$gui.btnInstallSwitches.Text = 'Switches'
	$gui.btnInstallSwitches.Anchor = 'top, right'
	$gui.grpInstall.Controls.Add($gui.btnInstallSwitches)
	
	$gui.btnInstallSwitches.add_Click({
		GenerateSwitchForm
	})
	#endregion: Create GroupBox for Install List
	
	#region: Create App Button Controls 
	# Create Button to Add Patches to dgvInstall
	$gui.btnAddPatch = New-Object System.Windows.Forms.Button
	$gui.btnAddPatch.Size = DrawSize(100)(23)
	$gui.btnAddPatch.Location = DrawPoint(606)(375)
	$gui.btnAddPatch.Text = 'Add'
	$gui.btnAddPatch.Anchor = 'bottom,right'
	$gui.tabRemoteInstall.Controls.Add($gui.btnAddPatch)
	
	# Create Button to Remove Patches to dgvInstall
	$gui.btnRemovePatch = New-Object System.Windows.Forms.Button
	$gui.btnRemovePatch.Size = DrawSize(100)(23)
	$gui.btnRemovePatch.Location = DrawPoint(708)(375)
	$gui.btnRemovePatch.Text = 'Remove'
	$gui.btnRemovePatch.Anchor = 'bottom,right'
	$gui.tabRemoteInstall.Controls.Add($gui.btnRemovePatch)
	
	# Create Button to Remove Patches to dgvInstall
	$gui.btnBuildInstall = New-Object System.Windows.Forms.Button
	$gui.btnBuildInstall.Size = DrawSize(150)(23)
	$gui.btnBuildInstall.Location = DrawPoint(15)(375)
	$gui.btnBuildInstall.Text = 'Install Wizard'
	$gui.btnBuildInstall.Anchor = 'bottom,left'
	$gui.btnBuildInstall.Enabled = $false
	$gui.tabRemoteInstall.Controls.Add($gui.btnBuildInstall)
	
	# Create onClick Event for gui.btnAddPatch
	$gui.btnAddPatch.add_Click({
        Add-PatchFile
    })
	
	# Create onClick Event for gui.btnRemovePatch
	$gui.btnRemovePatch.add_Click({
		Remove-PatchFile
	})
	
	# Create onClick Event for btnBuildInstall
	$gui.btnBuildInstall.add_Click({
		# Call Install Wizard 
		GenerateWizForm
	})
	
	# Checkbox to allow cross architecture installs (x86 on x64)
	$gui.chkXArch = New-Object System.Windows.Forms.CheckBox
	$gui.chkXArch.Size = DrawSize(16)(16)
	$gui.chkXArch.Location = DrawPoint(175)(379)
	$gui.chkXArch.Anchor = 'bottom,left'
	$gui.tabRemoteInstall.Controls.Add($gui.chkXArch)
	
	$gui.lblXArch = New-Object System.Windows.Forms.Label
	$gui.lblXArch.Size = DrawSize(75)(20)
	$gui.lblXArch.Location = DrawPoint(198)(380)
	$gui.lblXArch.Text = 'x86 on x64'
	$gui.lblXArch.Anchor = 'bottom,left'
	$gui.tabRemoteInstall.Controls.Add($gui.lblXArch)
	
	$script:xArch = $false
	
	$gui.chkXArch.add_Click({
		if ($script:xArch -eq $false) {
			$script:xArch = $true
		} else {
			$script:xArch = $false
		}
	})
	#endregion: Create App Button Controls
	
	#endregion: Tab Content: Remote Install
	
	#region: Create PictureBox
    $gui.patchimg = New-Object System.Windows.Forms.PictureBox
    $gui.patchimg.ImageLocation = "$currentdir\app\img\patching.jpg"
    $gui.patchimg.Size = DrawSize(286)(229)
    $gui.patchimg.Location = DrawPoint(0)(580)
	$gui.patchimg.Anchor = 'bottom,left'
    $gui.form1.Controls.Add($gui.patchimg)
	#endregion
	
    # Display Form
    $gui.form1.ShowDialog()
}