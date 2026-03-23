Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Find Latest Modified Files"
$form.Size = New-Object System.Drawing.Size(600, 450)
$form.StartPosition = "CenterScreen"

# Folder path label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Select a folder:"
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.AutoSize = $true
$form.Controls.Add($label)

# Folder path textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(400, 20)
$textBox.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($textBox)

# Browse button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse..."
$browseButton.Location = New-Object System.Drawing.Point(440, 48)
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Results label
$resultLabel = New-Object System.Windows.Forms.Label
$resultLabel.Text = "Top 10 latest modified files:"
$resultLabel.Location = New-Object System.Drawing.Point(20, 90)
$resultLabel.AutoSize = $true
$form.Controls.Add($resultLabel)

# Results listbox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20, 120)
$listBox.Anchor = 'Top, Left, Right, Bottom'
$listBox.ScrollAlwaysVisible = $true
$listBox.HorizontalScrollbar = $true
$listBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$listBox.Size = New-Object System.Drawing.Size(540, 250)
$form.Controls.Add($listBox)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Find Files"
$runButton.Location = New-Object System.Drawing.Point(240, 380)
$runButton.Add_Click({
    $folderPath = $textBox.Text

    if (-not (Test-Path $folderPath)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path!", "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $listBox.Items.Clear()
    $files = Get-ChildItem -Path $folderPath -Recurse -File | 
             Sort-Object LastWriteTime -Descending | 
             Select-Object -First 333 FullName, LastWriteTime

    foreach ($file in $files) {
        $listBox.Items.Add("$($file.LastWriteTime)  —  $($file.FullName)")
    }

    if ($files.Count -eq 0) {
        $listBox.Items.Add("No files found.")
    }
})
$form.Controls.Add($runButton)

# Show the form
[void]$form.ShowDialog()
