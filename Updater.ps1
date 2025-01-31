#Load required assemblies for script
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
[void] [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore")

[System.Windows.Forms.Application]::EnableVisualStyles()

#Declare Vars


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
if (-not (test-path -path "$env:SYSTEMDRIVE\Frysix_MC_updater")) {

    new-item -path "$env:SYSTEMDRIVE\Frysix_MC_updater" -type Directory -force

}

set-location -path "$env:SYSTEMDRIVE\Frysix_MC_updater"

$UpdateInfo = Get-UpdateInfo

$Links = $UpdateInfo["Links"]

foreach ($link in $Links.GetEnumerator()) {

    write-host $link.name

}

pause