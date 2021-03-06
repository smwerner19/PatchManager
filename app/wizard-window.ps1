# Install Wizard form
function GenerateWizForm 
{
    # Set Variables
	$script:page = $null
	
	# Create Form
    $gui.wizForm = New-Object System.Windows.Forms.Form
    $gui.wizForm.Text = "Install Wizard"
    $gui.wizForm.StartPosition = 4
    $gui.wizForm.ClientSize = "600,400"
	$gui.wizForm.FormBorderStyle = 'FixedDialog'
    $gui.wizForm.MaximizeBox = $false
	$gui.wizForm.MinimizeBox = $false
	
	#region: Page 1: Intro Page
	# Create Image Box for Wizard image
	$gui.wizard = New-Object System.Windows.Forms.PictureBox
    $gui.wizard.ImageLocation = "$currentdir\app\img\wizard.jpg"
    $gui.wizard.Size = DrawSize(270)(254)
    $gui.wizard.Location = DrawPoint(250)(50)
    $gui.wizForm.Controls.Add($gui.wizard)
	
	# Create title lable
	$gui.lblIntro = New-Object System.Windows.Forms.Label
	$gui.lblIntro.Size = DrawSize(180)(30)
	$gui.lblIntro.Location = DrawPoint(10)(10)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",12,[System.Drawing.FontStyle]::Bold)
	$gui.lblIntro.Font = $labelFont
	$gui.lblIntro.Text = 'Install Wizard'
	$gui.wizForm.Controls.Add($gui.lblIntro)
	
	# Create title lable
	$gui.lblIntro2 = New-Object System.Windows.Forms.Label
	$gui.lblIntro2.Size = DrawSize(180)(200)
	$gui.lblIntro2.Location = DrawPoint(10)(50)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",8,[System.Drawing.FontStyle]::Regular)
	$gui.lblIntro2.Font = $labelFont
	$gui.lblIntro2.Text = "Welcome to the install wizard. This little guy will get you squared away in three simple steps:`n`nBuild, Install, and Cleanup"
	$gui.wizForm.Controls.Add($gui.lblIntro2)
	#endregion
	
	#region: Page 2: Build Install
	# Create title lable
	$gui.lblBuild = New-Object System.Windows.Forms.Label
	$gui.lblBuild.Size = DrawSize(160)(30)
	$gui.lblBuild.Location = DrawPoint(10)(10)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",12,[System.Drawing.FontStyle]::Bold)
	$gui.lblBuild.Font = $labelFont
	$gui.lblBuild.Text = 'Build Install'
	$gui.wizForm.Controls.Add($gui.lblBuild)
	
	# Create title lable
	$gui.lblBuild2 = New-Object System.Windows.Forms.Label
	$gui.lblBuild2.Size = DrawSize(170)(200)
	$gui.lblBuild2.Location = DrawPoint(10)(50)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",8,[System.Drawing.FontStyle]::Regular)
	$gui.lblBuild2.Font = $labelFont
	$gui.lblBuild2.Text = 'Your install package is being built. This includes all of the files and scripts needed to complete the install.'
	$gui.wizForm.Controls.Add($gui.lblBuild2)
	
	# Create build status box
	$gui.buildStatus = New-Object System.Windows.Forms.ListBox
	$gui.buildStatus.Size = DrawSize(400)(315)
	$gui.buildStatus.Location = DrawPoint(188)(10)
	$gui.buildStatus.TopIndex = 0
	$gui.wizForm.Controls.Add($gui.buildStatus)
	
	# Create buttons to view batch files
	$gui.btnBatch32 = New-Object System.Windows.Forms.Button
	$gui.btnBatch32.Size = DrawSize(200)(23)
	$gui.btnBatch32.Location = DrawPoint(188)(325)
	$gui.btnBatch32.Text = '32-bit'
	$gui.btnBatch32.Enabled = $false
	$gui.wizForm.Controls.Add($gui.btnBatch32)
	
	$gui.btnBatch32.add_Click({
		Start-Process notepad -ArgumentList "$32dir\install.bat"
	})
	
	$gui.btnBatch64 = New-Object System.Windows.Forms.Button
	$gui.btnBatch64.Size = DrawSize(200)(23)
	$gui.btnBatch64.Location = DrawPoint(388)(325)
	$gui.btnBatch64.Text = '64-bit'
	$gui.btnBatch64.Enabled = $false
	$gui.wizForm.Controls.Add($gui.btnBatch64)
	
	$gui.btnBatch64.add_Click({
		Start-Process notepad -ArgumentList "$64dir\install.bat"
	})
	
	# Hide Controls
	$gui.lblBuild.Hide()
	$gui.lblBuild2.Hide()
	$gui.buildStatus.Hide()
	$gui.btnBatch32.Hide()
	$gui.btnBatch64.Hide()
	#endregion
	
	#region: Page 3: Install
	# Create title lable
	$gui.lblInstall = New-Object System.Windows.Forms.Label
	$gui.lblInstall.Size = DrawSize(160)(30)
	$gui.lblInstall.Location = DrawPoint(10)(10)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",12,[System.Drawing.FontStyle]::Bold)
	$gui.lblInstall.Font = $labelFont
	$gui.lblInstall.Text = 'Install'
	$gui.wizForm.Controls.Add($gui.lblInstall)
	
	# Create title lable
	$gui.lblInstall2 = New-Object System.Windows.Forms.Label
	$gui.lblInstall2.Size = DrawSize(170)(200)
	$gui.lblInstall2.Location = DrawPoint(10)(50)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",8,[System.Drawing.FontStyle]::Regular)
	$gui.lblInstall2.Font = $labelFont
	$gui.lblInstall2.Text = 'Your install package is now being executed.'
	$gui.wizForm.Controls.Add($gui.lblInstall2)
	
	# Create build status box
	$gui.InstallStatus = New-Object System.Windows.Forms.ListBox
	$gui.InstallStatus.Size = DrawSize(400)(340)
	$gui.InstallStatus.Location = DrawPoint(188)(10)
	$gui.InstallStatus.TopIndex = 0
	$gui.wizForm.Controls.Add($gui.InstallStatus)
	
	# Hide Contorls
	$gui.lblInstall.Hide()
	$gui.lblInstall2.Hide()
	$gui.installStatus.Hide()
	#endregion
	
	#region: Page 4: Finished
	# Create title lable
	$gui.lblFin = New-Object System.Windows.Forms.Label
	$gui.lblFin.Size = DrawSize(180)(30)
	$gui.lblFin.Location = DrawPoint(10)(10)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",12,[System.Drawing.FontStyle]::Bold)
	$gui.lblFin.Font = $labelFont
	$gui.lblFin.Text = 'Install Completed'
	$gui.wizForm.Controls.Add($gui.lblFin)
	
	# Create title lable
	$gui.lblFin2 = New-Object System.Windows.Forms.Label
	$gui.lblFin2.Size = DrawSize(180)(200)
	$gui.lblFin2.Location = DrawPoint(10)(50)
	$labelFont = New-Object System.Drawing.Font("Calibri (Body)",8,[System.Drawing.FontStyle]::Regular)
	$gui.lblFin2.Font = $labelFont
	$gui.lblFin2.Text = 'The install wizard has completed. Click finish to exit the wizard.'
	$gui.wizForm.Controls.Add($gui.lblFin2)
	
	# Create button to view log
	$gui.btnViewLog = New-Object System.Windows.Forms.Button
	$gui.btnViewLog.Size = DrawSize(180)(23)
	$gui.btnViewLog.Location = DrawPoint(10)(290)
	$gui.btnViewLog.Text = 'View Log'
	$gui.wizForm.Controls.Add($gui.btnViewLog)
	
	$gui.btnViewLog.add_Click({
		Start-Process notepad -ArgumentList "$Logfile"
	})
	
	# Create button to view report
	$gui.btnViewReport = New-Object System.Windows.Forms.Button
	$gui.btnViewReport.Size = DrawSize(180)(23)
	$gui.btnViewReport.Location = DrawPoint(10)(315)
	$gui.btnViewReport.Text = 'View Report'
	$gui.wizForm.Controls.Add($gui.btnViewReport)
	
	$gui.btnViewReport.add_Click({
		Start-Process Excel -ArgumentList "$ReportFile"
	})
	
	# Create Image Box for Done image
	$gui.done = New-Object System.Windows.Forms.PictureBox
    $gui.done.ImageLocation = "$currentdir\app\img\done.png"
    $gui.done.Size = DrawSize(300)(300)
    $gui.done.Location = DrawPoint(225)(25)
    $gui.wizForm.Controls.Add($gui.done)
	
	# Hide Controls
	$gui.lblFin.Hide()
	$gui.lblFin2.Hide()
	$gui.btnViewLog.Hide()
	$gui.btnViewReport.Hide()
	$gui.done.Hide()
	#endregion
	
	#region: Next/previous controls
	# separator bevel line
    $gui.hr = New-Object System.Windows.Forms.Label
    $gui.hr.Size = DrawSize(580)(2)
    $gui.hr.Location = DrawPoint(10)(360)
    $gui.hr.BorderStyle = 'Fixed3D'
    $gui.hr.Anchor = 'left, right, bottom'
    $gui.wizForm.Controls.Add($gui.hr)

    # Create Button Control for Next
    $gui.nextButton = New-Object System.Windows.Forms.Button
    $gui.nextButton.Text = "Build"
    $gui.nextButton.Size = DrawSize(100)(23)
    $gui.nextButton.Location = DrawPoint(490)(370)
    $gui.nextButton.Anchor = 'bottom, right'
	$gui.nextButton.Enabled = $true
    $gui.wizForm.Controls.Add($gui.nextButton)

    # onClick Event for nextButton button control
    $gui.nextButton.add_Click({
        if ($script:page -eq $null) {
			$gui.wizard.Hide()
			$gui.lblIntro.Hide()
			$gui.lblIntro2.Hide()
            $gui.lblBuild.Show()
			$gui.lblBuild2.Show()
			$gui.buildStatus.Show()
			$gui.btnBatch32.Show()
			$gui.btnBatch64.Show()
			$gui.cancelButton.Hide()
			$script:page = '2'
			$gui.nextButton.Text = "Install"
			$gui.nextButton.Enabled = $false
			buildit
            Write-Debug "page: $script:page"
        } elseif ($script:page -eq 2) {
            $gui.lblBuild.Hide()
			$gui.lblBuild2.Hide()
			$gui.buildStatus.Hide()
			$gui.btnBatch32.Hide()
			$gui.btnBatch64.Hide()
			$gui.lblInstall.Show()
			$gui.lblInstall2.Show()
			$gui.InstallStatus.Show()
            $script:page = '3'
			$gui.nextButton.Text = "Clean"
			$gui.nextButton.Enabled = $false
			LaunchInstall($threads)
            Write-Debug "page: $script:page"
        } elseif ($script:page -eq 3) {
            $gui.lblInstall.Hide()
			$gui.lblInstall2.Hide()
			$gui.InstallStatus.Hide()
			$gui.lblFin.Show()
			$gui.lblFin2.Show()
			$gui.btnViewLog.Show()
			$gui.btnViewReport.Show()
			$gui.done.Show()
            $script:page = '4'
			$gui.nextButton.Text = "Finish"
			removeTmpDir
            Write-Debug "page: $script:page"
        } elseif ($script:page -eq 4) {
			$gui.wizForm.Close()
		}
    })
	
	# Create Button Control for Next
    $gui.cancelButton = New-Object System.Windows.Forms.Button
    $gui.cancelButton.Text = "Cancel"
    $gui.cancelButton.Size = DrawSize(100)(23)
    $gui.cancelButton.Location = DrawPoint(385)(370)
    $gui.cancelButton.Anchor = 'bottom, right'
    $gui.wizForm.Controls.Add($gui.cancelButton)
	
	# Create onClick Event for cancel button
	$gui.cancelButton.add_Click({
		$gui.wizForm.Close()
	})

	#endregion

    # Display Form
    $gui.wizForm.ShowDialog()
}