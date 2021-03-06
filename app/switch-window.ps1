# Available File Sources form
function GenerateSwitchForm 
{
    # Create Form
    $gui.switchForm = New-Object System.Windows.Forms.Form
    $gui.switchForm.Text = "Edit Install Switches"
    $gui.switchForm.StartPosition = 4
    $gui.switchForm.ClientSize = "370,250"
	$gui.switchForm.FormBorderStyle = 'FixedDialog'
    $gui.switchForm.MaximizeBox = $false
	$gui.switchForm.MinimizeBox = $false
	
	$gui.grpSwitches = New-Object System.Windows.Forms.GroupBox
	$gui.grpSwitches.Size = DrawSize(350)(230)
	$gui.grpSwitches.Location = DrawPoint(10)(10)
	$gui.grpSwitches.Text = 'Install Switches'
	$gui.grpSwitches.Anchor = 'top, left, bottom'
	$gui.switchForm.Controls.Add($gui.grpSwitches)

	$gui.lblFileExe = New-Object System.Windows.Forms.Label
	$gui.lblFileExe.Size = DrawSize(50)(25)
	$gui.lblFileExe.Location = DrawPoint(50)(40)
	$gui.lblFileExe.Text = '.EXE'
	$gui.grpSwitches.Controls.Add($gui.lblFileExe)
	
	$gui.lblFileMsu = New-Object System.Windows.Forms.Label
	$gui.lblFileMsu.Size = DrawSize(50)(25)
	$gui.lblFileMsu.Location = DrawPoint(50)(80)
	$gui.lblFileMsu.Text = '.MSU'
	$gui.grpSwitches.Controls.Add($gui.lblFileMsu)
	
	$gui.lblFileMsi = New-Object System.Windows.Forms.Label
	$gui.lblFileMsi.Size = DrawSize(50)(25)
	$gui.lblFileMsi.Location = DrawPoint(50)(120)
	$gui.lblFileMsi.Text = '.MSI'
	$gui.grpSwitches.Controls.Add($gui.lblFileMsi)
	
	$gui.lblFileMsp = New-Object System.Windows.Forms.Label
	$gui.lblFileMsp.Size = DrawSize(50)(25)
	$gui.lblFileMsp.Location = DrawPoint(50)(160)
	$gui.lblFileMsp.Text = '.MSP'
	$gui.grpSwitches.Controls.Add($gui.lblFileMsp)
	
	$gui.txtSwitchesExe = New-Object System.Windows.Forms.TextBox
	$gui.txtSwitchesExe.Size = DrawSize(200)(20)
	$gui.txtSwitchesExe.Location = DrawPoint(100)(37)
	if ($switchExe -eq $null) {
		$gui.txtSwitchesExe.Text = $defaultSwitchExe
	} else {
		$gui.txtSwitchesExe.Text = $switchExe
	}
	$gui.grpSwitches.Controls.Add($gui.txtSwitchesExe)
	
	$gui.txtSwitchesMsu = New-Object System.Windows.Forms.TextBox
	$gui.txtSwitchesMsu.Size = DrawSize(200)(20)
	$gui.txtSwitchesMsu.Location = DrawPoint(100)(77)
	if ($switchMsu -eq $null) {
		$gui.txtSwitchesMsu.Text = $defaultSwitchMsu
	} else {
		$gui.txtSwitchesMsu.Text = $switchMsu
	}
	$gui.grpSwitches.Controls.Add($gui.txtSwitchesMsu)
	
	$gui.txtSwitchesMsi = New-Object System.Windows.Forms.TextBox
	$gui.txtSwitchesMsi.Size = DrawSize(200)(20)
	$gui.txtSwitchesMsi.Location = DrawPoint(100)(117)
	if ($switchMsi -eq $null) {
		$gui.txtSwitchesMsi.Text = $defaultSwitchMsi
	} else {
		$gui.txtSwitchesMsi.Text = $switchMsi
	}
	$gui.grpSwitches.Controls.Add($gui.txtSwitchesMsi)
	
	$gui.txtSwitchesMsp = New-Object System.Windows.Forms.TextBox
	$gui.txtSwitchesMsp.Size = DrawSize(200)(20)
	$gui.txtSwitchesMsp.Location = DrawPoint(100)(157)
	if ($switchMsp -eq $null) {
		$gui.txtSwitchesMsp.Text = $defaultSwitchMsp
	} else {
		$gui.txtSwitchesMsp.Text = $switchMsp
	}
	$gui.grpSwitches.Controls.Add($gui.txtSwitchesMsp)
	
	$gui.btnSaveSwitches = New-Object System.Windows.Forms.Button
	$gui.btnSaveSwitches.Size = DrawSize(100)(23)
	$gui.btnSaveSwitches.Location = DrawPoint(240)(197)
	$gui.btnSaveSwitches.Text = 'Save'
	$gui.grpSwitches.Controls.Add($gui.btnSaveSwitches)
	
	$gui.btnSaveSwitches.add_Click({
		$exe = $gui.txtSwitchesExe.text
		$msi = $gui.txtSwitchesmsi.text
		$msu = $gui.txtSwitchesmsu.text
		$msp = $gui.txtSwitchesmsp.text
		
		if ($exe -ne $defaultSwitchExe) {
			$script:switchExe = $exe
		}
		if ($msi -ne $defaultSwitchMsi) {
			$script:switchMsi = $msi
		}
		if ($msu -ne $defaultSwitchMsu) {
			$script:switchMsu = $msu
		}
		if ($msp -ne $defaultSwitchMsp) {
			$script:switchMsp = $msp
		}
		
		$gui.switchForm.Close()
	})
	
	$gui.btnDefaultSwitches = New-Object System.Windows.Forms.Button
	$gui.btnDefaultSwitches.Size = DrawSize(125)(23)
	$gui.btnDefaultSwitches.Location = DrawPoint(10)(197)
	$gui.btnDefaultSwitches.Text = 'Restore Defaults'
	$gui.grpSwitches.Controls.Add($gui.btnDefaultSwitches)
	
	$gui.btnDefaultSwitches.add_Click({
		$gui.txtSwitchesExe.text = $defaultSwitchExe
		$gui.txtSwitchesMsi.text = $defaultSwitchMsi
		$gui.txtSwitchesMsu.text = $defaultSwitchMsu
		$gui.txtSwitchesMsp.text = $defaultSwitchMsp
		
		$script:switchExe = $null
		$script:switchMsu = $null
		$script:switchMsi = $null
		$script:switchMsp = $null
	})
	
    # Display Form
    $gui.switchForm.ShowDialog()
}