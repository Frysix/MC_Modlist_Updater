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

                $MatchingFolders.ChosenMatch = $MatchingFolders.name

            }

        }

    }

} else {

    Show-InformationBox -message "Impossible de trouver de profiles ModRinth dans le fichier AppData. Fait sur que Modrinth est installé et que tu a le profile du serveur installé!"

    exit

}
