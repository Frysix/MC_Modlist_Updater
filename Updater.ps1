#Load required assemblies for script
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore")

[System.Windows.Forms.Application]::EnableVisualStyles()

#Declare Vars
$Paths = @{

    profiles = "$env:APPDATA\Roaming\ModrinthApp\profiles"

}

#Define Functions
function Get-UpdateInfo {

    if (test-path -path "$psscriptroot\info.ini") {

        remove-item -path "$psscriptroot\info.ini" -recurse -force

    }

    Invoke-Webrequest -uri "https://raw.githubusercontent.com/Frysix/MC_Modlist_Updater/refs/heads/main/info.ini" -outfile "$psscriptroot\info.ini"

    if (-not (test-path -path "$psscriptroot\info.ini")) {

        throw "INI file not found: info.ini"

    }

    $info = @{}
    $section = ""

    foreach ($line in Get-Content "$psscriptroot\info.ini") {

        $line = $line.Trim()

        if ($line -match "^\s*#|^\s*;|^\s*$") {

            continue

        }

        if ($line -match "^\[(.+)\]$") {

            $section = $matches[1]

            $info[$section] = @{}

        } elseif ($line -match "^(.*?)=(.*)$") {

            $key = $matches[1].Trim()

            $value = $matches[2].Trim()

            if ($section -ne "") {

                $info[$section][$key] = $value

            }

        }

    }

    return $info

}

#Beginning of execution
$UpdateInfo = Get-UpdateInfo

#Creating main UI
$MainGUI = New-Object system.Windows.Forms.Form
$MainGUI.ClientSize = New-Object System.Drawing.Point(848,425)
$MainGUI.text = "Frysix's Modlist Updater"
$MainGUI.TopMost = $true
$MainGUI.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#424141")
$MainGUI.FormBorderStyle = 'FixedSingle'
$MainGUI.MaximizeBox = $false

#Look if there is profiles in appdata
if (test-path -path $Paths.profiles) {

    $ProfileFolders = Get-ChildItem -path $Paths.profiles

    $LocA = 115
    $LocB = 10

    foreach ($file in $ProfileFolders.GetEnumerator()) {

        $TempButton = New-Object system.Windows.Forms.Button
        $TempButton.text = $file.name
        $TempButton.width = 30
        $TempButton.height = 30
        $TempButton.location = New-Object System.Drawing.Point($LocA,$LocB)
        $TempButton.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
        $TempButton.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

        $MainGUI.controls.AddRange(@($TempButton))

    }

}

$MainGUI.controls.AddRange(@())

[void]$MainGUI.ShowDialog()