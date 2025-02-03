Add-Type -AssemblyName System.Windows.Forms

# Creëer de hoofd-GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Herstart vereist"
$form.Size = New-Object System.Drawing.Size(420, 220)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Uw computer moet opnieuw opstarten. Wilt u dit nu doen of later?"
$label.Size = New-Object System.Drawing.Size(380,40)
$label.Location = New-Object System.Drawing.Point(20,20)

$nowButton = New-Object System.Windows.Forms.Button
$nowButton.Text = "Nu herstarten"
$nowButton.Size = New-Object System.Drawing.Size(120,30)
$nowButton.Location = New-Object System.Drawing.Point(40,80)

$laterButton = New-Object System.Windows.Forms.Button
$laterButton.Text = "Later herstarten"
$laterButton.Size = New-Object System.Drawing.Size(120,30)
$laterButton.Location = New-Object System.Drawing.Point(160,80)

$customTimeButton = New-Object System.Windows.Forms.Button
$customTimeButton.Text = "Specifieke tijd"
$customTimeButton.Size = New-Object System.Drawing.Size(120,30)
$customTimeButton.Location = New-Object System.Drawing.Point(280,80)

$form.Controls.Add($label)
$form.Controls.Add($nowButton)
$form.Controls.Add($laterButton)
$form.Controls.Add($customTimeButton)

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
    $label.Location = New-Object System.Drawing.Point(20,20)
    $label.Size = New-Object System.Drawing.Size(250,20)

    $btn10min = New-Object System.Windows.Forms.Button
    $btn10min.Text = "10 minuten"
    $btn10min.Size = New-Object System.Drawing.Size(80,30)
    $btn10min.Location = New-Object System.Drawing.Point(20,60)

    $btn30min = New-Object System.Windows.Forms.Button
    $btn30min.Text = "30 minuten"
    $btn30min.Size = New-Object System.Drawing.Size(80,30)
    $btn30min.Location = New-Object System.Drawing.Point(110,60)

    $btn60min = New-Object System.Windows.Forms.Button
    $btn60min.Text = "60 minuten"
    $btn60min.Size = New-Object System.Drawing.Size(80,30)
    $btn60min.Location = New-Object System.Drawing.Point(200,60)

    $laterForm.Controls.Add($label)
    $laterForm.Controls.Add($btn10min)
    $laterForm.Controls.Add($btn30min)
    $laterForm.Controls.Add($btn60min)

    # Functie voor uitgestelde herstart
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

    $btn10min.Add_Click({ Schedule-Restart 10 })
    $btn30min.Add_Click({ Schedule-Restart 30 })
    $btn60min.Add_Click({ Schedule-Restart 60 })

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
    $inputLabel.Location = New-Object System.Drawing.Point(20,20)
    $inputLabel.Size = New-Object System.Drawing.Size(160,20)

    $inputBox = New-Object System.Windows.Forms.TextBox
    $inputBox.Location = New-Object System.Drawing.Point(180,20)
    $inputBox.Size = New-Object System.Drawing.Size(80,20)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(80,30)
    $okButton.Location = New-Object System.Drawing.Point(110,60)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Annuleren"
    $cancelButton.Size = New-Object System.Drawing.Size(80,30)
    $cancelButton.Location = New-Object System.Drawing.Point(200,60)

    $customForm.Controls.Add($inputLabel)
    $customForm.Controls.Add($inputBox)
    $customForm.Controls.Add($okButton)
    $customForm.Controls.Add($cancelButton)

    # Annuleerknop sluit het venster zonder iets te doen
    $cancelButton.Add_Click({
        $customForm.Close()
    })

    # OK-knop logica
    $okButton.Add_Click({
        $timeInput = $inputBox.Text.Trim()
        $currentDate = Get-Date

        # Controleer of de invoer geldig is
        if ($timeInput -match "^(2[0-3]|[01]?[0-9]):([0-5]?[0-9])$") {
            $hours, $minutes = $timeInput -split ":"
            $targetTime = Get-Date -Hour $hours -Minute $minutes -Second 0

            # Als de tijd al voorbij is, plan het voor de volgende dag
            if ($targetTime -lt $currentDate) {
                $targetTime = $targetTime.AddDays(1)
            }

            # Geplande taak aanmaken
            $taskName = "SpecifiekeTijdHerstart"
            $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0"
            $trigger = New-ScheduledTaskTrigger -Once -At $targetTime
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest -Force

            [System.Windows.Forms.MessageBox]::Show("Herstart gepland om $($targetTime.ToString('HH:mm')).", "Bevestiging", "OK", "Information")
            $customForm.Close()
            $form.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Ongeldige invoer! Voer een tijd in als HH:MM.", "Fout", "OK", "Error")
        }
    })

    $customForm.ShowDialog()
})

$form.ShowDialog()