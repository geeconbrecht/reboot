if (-Not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell.exe -Verb runAs -ArgumentList $arguments
    exit
}

Add-Type -AssemblyName System.Windows.Forms

# Creëer de hoofd-GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Herstart vereist - Geecon IT Solutions"
$form.Size = New-Object System.Drawing.Size(450, 250)  # Iets grotere breedte
$form.StartPosition = "CenterScreen"

# Stel het opgeslagen icoon in
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Users\Public\pootje.ico")


# Hoofdbericht
$label = New-Object System.Windows.Forms.Label
$label.Text = "Beste, uw computer heeft updates klaarstaan en zou herstart moeten worden om deze te voltooien. Gelieve uw documenten op te slaan en een keuze te maken."
$label.Size = New-Object System.Drawing.Size(380, 60)  # Iets breder voor ruimte
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)

# Knoppen - locatie verschoven voor meer ruimte rechts
$nowButton = New-Object System.Windows.Forms.Button
$nowButton.Text = "Nu herstarten"
$nowButton.Size = New-Object System.Drawing.Size(120, 30)
$nowButton.Location = New-Object System.Drawing.Point(40, 90)

$laterButton = New-Object System.Windows.Forms.Button
$laterButton.Text = "Later herstarten"
$laterButton.Size = New-Object System.Drawing.Size(120, 30)
$laterButton.Location = New-Object System.Drawing.Point(160, 90)

$customTimeButton = New-Object System.Windows.Forms.Button
$customTimeButton.Text = "Specifieke tijd"
$customTimeButton.Size = New-Object System.Drawing.Size(120, 30)
$customTimeButton.Location = New-Object System.Drawing.Point(280, 90)

# Contactlabel onderaan - locatie verschoven voor meer ruimte rechts
$contactLabel = New-Object System.Windows.Forms.Label
$contactLabel.Text = "Indien er vragen zijn, kan u ons bereiken op 011369199."
$contactLabel.AutoSize = $true
$contactLabel.ForeColor = [System.Drawing.Color]::Black
$contactLabel.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)
$contactLabel.Location = New-Object System.Drawing.Point(20, 160)

# Voeg componenten toe aan het formulier
$form.Controls.Add($label)
$form.Controls.Add($nowButton)
$form.Controls.Add($laterButton)
$form.Controls.Add($customTimeButton)
$form.Controls.Add($contactLabel)

# Functie om nu te herstarten
$nowButton.Add_Click({
    Start-Process "shutdown.exe" -ArgumentList "/r /t 0"
    $form.Close()
})

# Functie voor "Later herstarten"
$laterButton.Add_Click({
    $laterForm = New-Object System.Windows.Forms.Form
    $laterForm.Text = "Herstart later instellen"
    $laterForm.Size = New-Object System.Drawing.Size(300, 180)
    $laterForm.StartPosition = "CenterScreen"

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Kies een vertraging voor de herstart:"
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(250, 20)

    $btn30min = New-Object System.Windows.Forms.Button
    $btn30min.Text = "30 minuten"
    $btn30min.Size = New-Object System.Drawing.Size(80, 30)
    $btn30min.Location = New-Object System.Drawing.Point(20, 60)

    $btn60min = New-Object System.Windows.Forms.Button
    $btn60min.Text = "60 minuten"
    $btn60min.Size = New-Object System.Drawing.Size(80, 30)
    $btn60min.Location = New-Object System.Drawing.Point(110, 60)

    $btn120min = New-Object System.Windows.Forms.Button
    $btn120min.Text = "120 minuten"
    $btn120min.Size = New-Object System.Drawing.Size(80, 30)
    $btn120min.Location = New-Object System.Drawing.Point(200, 60)

    $laterForm.Controls.Add($label)
    $laterForm.Controls.Add($btn30min)
    $laterForm.Controls.Add($btn60min)
    $laterForm.Controls.Add($btn120min)

    function Schedule-Restart($minutes) {
        $targetTime = (Get-Date).AddMinutes($minutes)
        $taskName = "LaterHerstart"
        $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0"
        $trigger = New-ScheduledTaskTrigger -Once -At $targetTime
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest -Force

        [System.Windows.Forms.MessageBox]::Show("De herstart is gepland om $($targetTime.ToString('HH:mm')).", "Bevestiging", "OK", "Information")
        $laterForm.Close()
        $form.Close()
    }

    $btn30min.Add_Click({ Schedule-Restart 30 })
    $btn60min.Add_Click({ Schedule-Restart 60 })
    $btn120min.Add_Click({ Schedule-Restart 120 })

    $laterForm.ShowDialog()
})

# Functie voor exacte tijd invoeren
$customTimeButton.Add_Click({
    $customForm = New-Object System.Windows.Forms.Form
    $customForm.Text = "Specifieke tijd instellen"
    $customForm.Size = New-Object System.Drawing.Size(320, 150)
    $customForm.StartPosition = "CenterScreen"

    $inputLabel = New-Object System.Windows.Forms.Label
    $inputLabel.Text = "Voer de tijd in (HH:mm):"
    $inputLabel.Location = New-Object System.Drawing.Point(20, 20)
    $inputLabel.Size = New-Object System.Drawing.Size(160, 20)

    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Location = New-Object System.Drawing.Point(180, 20)
    $inputBox.Size = New-Object System.Drawing.Size(80, 20)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(80, 30)
    $okButton.Location = New-Object System.Drawing.Point(110, 60)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Annuleren"
    $cancelButton.Size = New-Object System.Drawing.Size(80, 30)
    $cancelButton.Location = New-Object System.Drawing.Point(200, 60)

    $customForm.Controls.Add($inputLabel)
    $customForm.Controls.Add($inputBox)
    $customForm.Controls.Add($okButton)
    $customForm.Controls.Add($cancelButton)

    $cancelButton.Add_Click({ $customForm.Close() })

    $okButton.Add_Click({
        $timeInput = $inputBox.Text.Trim()
        $currentDate = Get-Date

        if ($timeInput -match "^(2[0-3]|[01]?[0-9]):([0-5]?[0-9])$") {
            $hours, $minutes = $timeInput -split ":"
            $targetTime = Get-Date -Hour $hours -Minute $minutes -Second 0
            if ($targetTime -lt $currentDate) { $targetTime = $targetTime.AddDays(1) }

            $taskName = "SpecifiekeTijdHerstart"
            $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0"
            $trigger = New-ScheduledTaskTrigger -Once -At $targetTime
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest -Force

            [System.Windows.Forms.MessageBox]::Show("Herstart gepland om $($targetTime.ToString('HH:mm')).", "Bevestiging", "OK", "Information")
            $customForm.Close()
            $form.Close()
        }
    })

    $customForm.ShowDialog()
})

$form.ShowDialog()
