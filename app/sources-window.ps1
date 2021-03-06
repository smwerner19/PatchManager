# Available File Sources form
function GenerateSourcesForm 
{
    # Create Form
    $gui.sourcesForm = New-Object System.Windows.Forms.Form
    $gui.sourcesForm.Text = "Edit File Sources"
    $gui.sourcesForm.StartPosition = 4
    $gui.sourcesForm.ClientSize = "600,420"
	$gui.sourcesForm.FormBorderStyle = 'FixedDialog'
    $gui.sourcesForm.MaximizeBox = $false
	$gui.sourcesForm.MinimizeBox = $false
	
	$gui.grpSources = New-Object System.Windows.Forms.GroupBox
	$gui.grpSources.Size = DrawSize(580)(400)
	$gui.grpSources.Location = DrawPoint(10)(10)
	$gui.grpSources.Text = 'File Sources'
	$gui.grpSources.Anchor = 'top, left, bottom'
	$gui.sourcesForm.Controls.Add($gui.grpSources)

	# Create listbox for computers
	$gui.listSources = New-Object System.Windows.Forms.ListBox
	$gui.listSources.Size = DrawSize(558)(310)
	$gui.listSources.Location = DrawPoint(10)(49)
	$gui.listSources.Anchor = 'top, bottom'
	$gui.grpSources.Controls.Add($gui.listSources)
	
	# Populate list
	$sources = Get-Content -Path $currentdir\app\data\sources.txt
	foreach ($source in $sources) {
		$gui.listSources.Items.Add("$source")
	}
	
	# Create textbox to add computers
	$gui.txtAddSources = New-Object System.Windows.Forms.TextBox
	$gui.txtAddSources.Size = DrawSize(502)(30)
	$gui.txtAddSources.Location = DrawPoint(10)(20)
	$gui.txtAddSources.Anchor = 'top'
	$gui.grpSources.Controls.Add($gui.txtAddSources)

	# Create add button
	$gui.btnAddSource = New-Object System.Windows.Forms.Button
	$gui.btnAddSource.Size = DrawSize(23)(23)
	$gui.btnAddSource.Location = DrawPoint(518)(19)
	$gui.btnAddSource.Text = '+'
	$gui.btnAddSource.Anchor = 'top'
	$gui.grpSources.Controls.Add($gui.btnAddSource)
	
	$gui.btnAddSource.add_Click({
        $addme = $gui.txtAddSources.Text
        if ($addme -eq '') {
			$wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Can't add a blank line.",0,"Error",0x0)
		} else {
			$listItems = $gui.listSources.Items
	        $duplicate = "false"
	        foreach ($listItem in $listItems) {
	            if ($listItem -eq $addme){
	                $duplicate = "true"
	            }
	        }
	        if ($duplicate -ne "true"){
	            $gui.listSources.Items.Add("$addme")
				$gui.txtAddSources.Clear()
			} else {
	            $wshell = New-Object -ComObject Wscript.Shell
	            $wshell.Popup("$addme can't be added as it is already in the list.",0,"Duplicate Entry",0x0)
	        }
		}
    })
	
	# Create remove button
	$gui.btnRemoveSource = New-Object System.Windows.Forms.Button
	$gui.btnRemoveSource.Size = DrawSize(23)(23)
	$gui.btnRemoveSource.Location = DrawPoint(545)(19)
	$gui.btnRemoveSource.Text = '-'
	$gui.btnRemoveSource.Anchor = 'top'
	$gui.grpSources.Controls.Add($gui.btnRemoveSource)
	

	$gui.btnRemoveSource.add_Click({
        $selectedItem = $gui.listSources.SelectedItem
        $gui.listSources.Items.Remove("$selectedItem")
    })

	# Create save button
	$gui.btnSaveSouces = New-Object System.Windows.Forms.Button
	$gui.btnSaveSouces.Size = DrawSize(130)(25)
	$gui.btnSaveSouces.Location = DrawPoint(439)(366)
	$gui.btnSaveSouces.Text = 'Save Sources'
	$gui.btnSaveSouces.Anchor = 'bottom'
	$gui.grpSources.Controls.Add($gui.btnSaveSouces)
	
	$gui.btnSaveSouces.add_Click({
		Remove-Item -Path $currentdir\app\data\sources.txt
		$sources = $gui.listSources.Items
		Write-Output -InputObject $sources > $currentdir\app\data\sources.txt
		$gui.sourcesForm.Close()
	})
	
	# Create load button
	$gui.btnCancelSources = New-Object System.Windows.Forms.Button
	$gui.btnCancelSources.Size = DrawSize(130)(25)
	$gui.btnCancelSources.Location = DrawPoint(9)(366)
	$gui.btnCancelSources.Text = 'Cancel'
	$gui.btnCancelSources.Anchor = 'bottom'
	$gui.grpSources.Controls.Add($gui.btnCancelSources)
	
	$gui.btnCancelSources.add_Click({
		$gui.sourcesForm.Close()
	})
	
    # Display Form
    $gui.sourcesForm.ShowDialog()
}