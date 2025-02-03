#Load required assemblies for script
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore")

[System.Windows.Forms.Application]::EnableVisualStyles()

#Declare Vars with embedded information
$Paths = @{

    temp = "$psscriptroot\temp"
    profiles = "$env:APPDATA\Roaming\ModrinthApp\profiles"
    infoini = "$psscriptroot\temp\info.ini"

}
$Links = @{

    infoini = "https://raw.githubusercontent.com/Frysix/MC_Modlist_Updater/refs/heads/main/info.ini"

}

#Define Functions
function Show-InformationBox {

    [cmdletbinding()]

	param (
	
		[parameter(mandatory=$true)]
		[string]$message

	)

    [System.Windows.MessageBox]::Show($message, "Frysix's Modpack Updater", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information, [System.Windows.MessageBoxResult]::None, [System.Windows.MessageBoxOptions]::DefaultDesktopOnly)

}
function Get-UserConfirmation {

    [cmdletbinding()]

	param (
	
		[parameter(mandatory=$false)]
		[string]$text1,

        [parameter(mandatory=$false)]
		[string]$text2,

        [parameter(mandatory=$false)]
		[string]$text3

	)

    $form = new-object System.Windows.Forms.Form
    $form.Text = 'ezCMD'
    $form.Size = new-object System.Drawing.Size(270,180)
    $form.MinimumSize = new-object System.Drawing.Size(270,180)
    $form.MaximumSize = new-object System.Drawing.Size(270,180)
    if (test-path -path $scriptfiles.icon) {

        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($scriptfiles.icon)

    }

    $label1 = new-object System.Windows.Forms.Label
    $label1.Location = new-object System.Drawing.Point(40,15)
    $label1.Size = new-object System.Drawing.Size(280,20)
    $label1.Text = $text1
    $form.Controls.Add($label1)

    $label2 = new-object System.Windows.Forms.Label
    $label2.Location = new-object System.Drawing.Point(40,35)
    $label2.Size = new-object System.Drawing.Size(280,20)
    $label2.Text = $text2
    $form.Controls.Add($label2)

    $label3 = new-object System.Windows.Forms.Label
    $label3.Location = new-object System.Drawing.Point(40,55)
    $label3.Size = new-object System.Drawing.Size(280,20)
    $label3.Text = $text3
    $form.Controls.Add($label3)

    $nobutton = new-object System.Windows.Forms.Button
    $nobutton.Location = new-object System.Drawing.Size(30,100)
    $nobutton.Size = new-object System.Drawing.Size(60,20)
    $nobutton.Text = "No"
    $form.Controls.Add($nobutton)

    $yesbutton = New-Object System.Windows.Forms.Button
    $yesbutton.Location = New-Object System.Drawing.Size(160,100)
    $yesbutton.Size = New-Object System.Drawing.Size(60,20)
    $yesbutton.Text = "Yes"
    $form.Controls.Add($yesbutton)

    $nobutton.Add_Click({

        new-variable -name yesnoanswer -value $($false) -scope Script -force
        $form.Close()

    })

    $yesbutton.Add_Click({

        new-variable -name yesnoanswer -value $($true) -scope Script -force
        $form.Close()

    })

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()

}
function Get-FolderLocation {

    [cmdletbinding()]

	param (
	
		[parameter(mandatory=$true)]
		[string]$description,

        [parameter(Mandatory=$false)]
        [string]$startpath

	)

    Add-Type -AssemblyName System.Windows.Forms

    $folderdialog = new-object System.Windows.Forms.FolderBrowserDialog
    $folderdialog.Description = $description

    if ($startpath -and (Test-Path $startpath -PathType Container)) {

        $folderdialog.SelectedPath = $startpath

    }

    $resultdialog = $folderdialog.Showdialog()

    if ($resultdialog -eq [System.Windows.Forms.Dialogresult]::OK) {

        $selectedpath = $folderdialog.Selectedpath

        return $selectedpath

    } else {

        return $false

    }

}
function Get-IniFile {

    [cmdletbinding()]

    param(

        [parameter(mandatory=$true)]
        [string]$IniPath
        
    )

    if (-not (test-path -path $IniPath)) {

        throw "INI file not found: $IniPath"

    }

    $info = @{}
    $section = ""

    foreach ($line in Get-Content $IniPath) {

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
function Get-UpdateInfo {

    if (test-path -path $Paths.infoini) {

        remove-item -path $Paths.infoini -recurse -force

    }

    Invoke-Webrequest -uri $Links.infoini -outfile $Paths.infoini

    return Get-IniFile -IniPath $Paths.infoini

}

#Beginning of execution
if (-not (test-path -path $Paths.temp)) {

    new-item -path $Paths.temp -itemtype Directory -force

}

$UpdateInfo = Get-UpdateInfo

#Look if there is profiles in appdata
if (test-path -path $Paths.profiles) {

    $ProfileFolders = Get-ChildItem -path $Paths.profiles

    $MatchingFolders = @{}

    foreach ($folder in $ProfileFolders.GetEnumerator()) {

        if ($folder.name -match "Server Dude") {

            $MatchingFolders = $MatchingFolders + @{

                $folder.name = $folder.key

            }

        }

    }

    if ($MatchingFolders.Count -gt 0) {

        $MatchingFolders.ChosenMatch = ""

        foreach ($folder in $MatchingFolders.GetEnumerator()) {

            if ($MatchingFolders.ChosenMatch -eq "") {

                $MatchingFolders.ChosenMatch = $folder.name

            }

        }

        if ($MatchingFolders.ChosenMatch -eq "") {

            Show-InformationBox -message "An error ocurred! Match was counted but does not exist. Exiting..."

            exit

        }

        Get-UserConfirmation -text2 "Folder: "$MatchingFolders.ChosenMatch" was chosen as the default profile." -text3 "Do you want to indicate manually where the folder is?"

        if ($yesnoanswer) {

            $Paths.WorkPath = Get-FolderLocation -description "Indicate the folder of the modlist you want to update." -startpath $Paths.profiles

            if ($Paths.WorkPath -eq $false) {

                Show-InformationBox -message "Canceled by User: User did not input any paths. Exiting..."

                exit

            } else {

                if (test-path -path $Paths.WorkPath) {

                    $ValidPathFound = $true

                } else {

                    Show-InformationBox -message "Canceled by User: User did not indicate any existing paths. Exiting..."

                    exit

                }

            }

        } else {

            $Paths.WorkPath = $MatchingFolders.ChosenMatch

            $ValidPathFound = $true

        }

    } else {

        Get-UserConfirmation -text2 "No folder matches the search parameters." -text3 "Do you want to indicate manually where the folder is?"

        if ($yesnoanswer) {

            $Paths.WorkPath = Get-FolderLocation -description "Indicate the folder of the modlist you want to update." -startpath $Paths.profiles

            if ($Paths.WorkPath -eq $false) {

                Show-InformationBox -message "Canceled by User: User did not input any paths. Exiting..."

                exit

            } else {

                if (test-path -path $Paths.WorkPath) {

                    $ValidPathFound = $true

                } else {

                    Show-InformationBox -message "Canceled by User: User did not indicate any existing paths. Exiting..."

                    exit

                }

            }

        } else {

            Show-InformationBox -message "Canceled by User: Exiting..."

            exit

        }

    }

    #END OF CHECK
    if ($ValidPathFound) {

        Show-InformationBox -message $Paths.WorkPath

        exit

    } else {

        Show-InformationBox -message "No valid paths found."

        exit
    }

} else {

    Show-InformationBox -message "Impossible to find ModRinth's AppData folder, please make sure it is properly installed first and that you downloaded the modlist mrpack file from the discord server. This utility should only be used to update an existing profile. Exiting..."

    exit

}
