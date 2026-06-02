# Charger les composants Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#region Fonctions utilitaires
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )
    $LogsDir = Join-Path -Path $PSScriptRoot -ChildPath 'Logs'
    if (-not (Test-Path -Path $LogsDir)) {
        New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
    }
    $LogFilePath = Join-Path -Path $LogsDir -ChildPath "Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
}

function Clean-OldLogs {
    param (
        [int]$DaysToKeep = 7
    )
    $LogsDir = Join-Path -Path $PSScriptRoot -ChildPath 'Logs'
    if (Test-Path -Path $LogsDir) {
        $CutoffDate = (Get-Date).AddDays(-$DaysToKeep)
        Get-ChildItem -Path $LogsDir -Filter 'Backup_*.log' | Where-Object {
            $_.LastWriteTime -lt $CutoffDate
        } | ForEach-Object {
            Remove-Item -Path $_.FullName -Force
        }
    }
}

function Test-DiskSpace {
    param (
        [string]$DriveLetter = 'C',
        [string]$SourceFolder = "C:\Users\$env:USERNAME"
    )

    Write-Log -Message "Vérification de l'espace disque sur $DriveLetter..." -Level 'INFO'
    try {
        $RequiredFolderSize = (Get-ChildItem -Path $SourceFolder -Recurse -Force -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
        $Drive = Get-PSDrive -Name $DriveLetter -ErrorAction Stop
        $FreeSpace = $Drive.Free
        $TotalSpace = $Drive.Used + $Drive.Free
        $TenPercentThreshold = [math]::Ceiling($TotalSpace * 0.1)

        if (($FreeSpace - $RequiredFolderSize) -lt $TenPercentThreshold) {
            $SpaceToFreeGB = [math]::Ceiling(($RequiredFolderSize + $TenPercentThreshold - $FreeSpace) / 1GB)
            $Message = $Language.ProgressMessageDiskSpaceInsufficient -f $SpaceToFreeGB
            Write-Log -Message $Message -Level 'ERROR'
            [System.Windows.Forms.MessageBox]::Show($Message, $Language.TitleDiskSpaceError, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            exit
        }
        Write-Log -Message "Espace disque suffisant sur $DriveLetter." -Level 'INFO'
    } catch {
        $ErrorMsg = $Language.ProgressMessageDiskSpaceCheckError -f $DriveLetter
        Write-Log -Message $ErrorMsg -Level 'ERROR'
        [System.Windows.Forms.MessageBox]::Show($ErrorMsg, $Language.TitleDiskSpaceError, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
        exit
    }
}

function Write-ProgressMessage {
    param (
        [string]$Message
    )
    $ProgressTextBox.AppendText("$Message`n")
    $ProgressTextBox.ScrollToCaret()
    Add-Content -Path $ResumeFilePath -Value $Message
    Write-Log -Message $Message -Level 'INFO'
}

function Copy-WithRobocopy {
    param (
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludeFiles
    )
    Write-Log -Message "Copie de $Source vers $Destination avec Robocopy..." -Level 'INFO'
    $RobocopyLogFile = Join-Path -Path $env:PUBLIC -ChildPath "$((Split-Path -Path $Source -Leaf))_Robocopy.log"
    $RobocopyCommand = "`"$Source`" `"$Destination`" /E /R:3 /W:5 /XJD /XF $($ExcludeFiles -join ',') /LOG:`"$RobocopyLogFile`" /NP /V /TEE"
    try {
        $Process = Start-Process -FilePath 'robocopy.exe' -ArgumentList $RobocopyCommand -PassThru -Wait -NoNewWindow
        if ($Process.ExitCode -ge 8) {
            throw ($Language.ProgressMessageCopyThrow -f $Process.ExitCode)
        }
        Write-ProgressMessage ($Language.ProgressMessageCopySucces -f $Source, $Destination)
    } catch {
        $ErrorMsg = $Language.ProgressMessageCopyError -f $Source, $Destination, $_.Exception.Message
        Write-ProgressMessage $ErrorMsg
        Write-Log -Message $ErrorMsg -Level 'ERROR'
    }
}

function New-Shortcut {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$TargetApplication,
        [string]$OutputDirectory,
        [string]$Name,
        [string]$Description,
        [string]$Arguments,
        [string]$WorkingDirectory,
        [string]$HotKey,
        [ValidateSet('Normal', 'Maximized', 'Minimized')]
        [string]$WindowStyle = 'Normal',
        [string]$IconPath,
        [switch]$Elevated
    )

    $ShortcutName = if ($Name) { "$Name.lnk" } else { "$((Split-Path -Path $TargetApplication -Leaf)).lnk" }
    $ShortcutPath = if ($OutputDirectory) { Join-Path -Path $OutputDirectory -ChildPath $ShortcutName } else { Join-Path -Path (Split-Path -Path $TargetApplication -Parent) -ChildPath $ShortcutName }

    $WindowStyleValue = @{'Normal'=1; 'Maximized'=3; 'Minimized'=7}[$WindowStyle]
    try {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $TargetApplication
        $Shortcut.WorkingDirectory = $WorkingDirectory
        $Shortcut.Description = $Description
        $Shortcut.Arguments = $Arguments
        $Shortcut.WindowStyle = $WindowStyleValue
        $Shortcut.HotKey = $HotKey
        if ($IconPath) { $Shortcut.IconLocation = $IconPath }
        $Shortcut.Save()
        if ($Elevated) {
            $Bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
            $Bytes[0x15] = $Bytes[0x15] -bor 0x20
            [System.IO.File]::WriteAllBytes($ShortcutPath, $Bytes)
        }
        return [PSCustomObject]@{
            Name = $ShortcutName
            Directory = (Split-Path -Path $ShortcutPath -Parent)
            Application = (Split-Path -Path $TargetApplication -Leaf)
            Description = $Description
            Arguments = $Arguments
            HotKey = $HotKey
            Elevated = $Elevated
        }
    } catch {
        throw ($Language.ProgressMessageShortcutError -f $ShortcutName, $_.Exception.Message)
    } finally {
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($Shell)
    }
}
#endregion

#region Initialisation et gestion de la langue
$BasePath = $PSScriptRoot
$LocalizedPath = Join-Path -Path $BasePath -ChildPath 'Localized'

# Déterminer la langue du système
$CurrentCulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
switch -Wildcard ($CurrentCulture) {
    'fr-*' { $OverwriteCulture = 'fr-FR' }
    'de-*' { $OverwriteCulture = 'de-DE' }
    'es-*' { $OverwriteCulture = 'es-ES' }
    default { $OverwriteCulture = $CurrentCulture }
}

# Charger les messages localisés
try {
    $Language = Import-LocalizedData -BaseDirectory $LocalizedPath -UICulture $OverwriteCulture -ErrorAction Stop
    if (-not $Language) {
        throw "Aucun fichier de localisation trouvé pour $OverwriteCulture dans $LocalizedPath"
    }
    Write-Log -Message "Langue chargée : $OverwriteCulture" -Level 'INFO'
} catch {
    Write-Log -Message "Erreur lors du chargement de la localisation : $($_.Exception.Message)" -Level 'ERROR'
    [System.Windows.Forms.MessageBox]::Show("Erreur de localisation : $($_.Exception.Message)", 'Erreur', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Nettoyage des anciens logs
Clean-OldLogs -DaysToKeep 7

# Chemins globaux
$ResumeFilePath = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.resumeFile
New-Item -Path $ResumeFilePath -ItemType File -Force | Out-Null

# Vérification de l'espace disque
Test-DiskSpace -DriveLetter 'C'
#endregion

#region Interface graphique principale
$MainForm = New-Object -TypeName System.Windows.Forms.Form
$MainForm.Text = $Language.Form.Title
$MainForm.Size = New-Object -TypeName System.Drawing.Size -Width 1024 -Height 520
$MainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$MainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$MainForm.BackColor = [System.Drawing.Color]::FromArgb(5, 0, 51)

$TitleLabel = New-Object -TypeName System.Windows.Forms.Label
$TitleLabel.Width = 984
$TitleLabel.Height = 40
$TitleLabel.Left = 20
$TitleLabel.Top = 20
$TitleLabel.Font = New-Object -TypeName System.Drawing.Font -Name 'Arial' -Size 14 -Style [System.Drawing.FontStyle]::Bold
$TitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$TitleLabel.ForeColor = [System.Drawing.Color]::White
$TitleLabel.Text = $Language.Form.labelCenteredText
$MainForm.Controls.Add($TitleLabel)

$MainRichTextBox = New-Object -TypeName System.Windows.Forms.RichTextBox
$MainRichTextBox.Width = 984
$MainRichTextBox.Height = 360
$MainRichTextBox.Left = 20
$MainRichTextBox.Top = 70
$MainRichTextBox.Font = New-Object -TypeName System.Drawing.Font -Name 'Arial' -Size 10
$MainRichTextBox.Multiline = $true
$MainRichTextBox.ReadOnly = $true
$MainRichTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$MainRichTextBox.Rtf = $Language.RTF.text
$MainForm.Controls.Add($MainRichTextBox)

$OkButton = New-Object -TypeName System.Windows.Forms.Button
$OkButton.Width = 100
$OkButton.Height = 30
$OkButton.Left = ($MainForm.Width - $OkButton.Width) / 2
$OkButton.Top = 450
$OkButton.Text = $Language.Form.Button
$OkButton.BackColor = [System.Drawing.Color]::White
$OkButton.ForeColor = [System.Drawing.Color]::FromArgb(5, 0, 51)
$OkButton.Font = New-Object -TypeName System.Drawing.Font -Name 'Arial' -Size 10 -Style [System.Drawing.FontStyle]::Bold
$OkButton.Add_Click({ $MainForm.Close() })
$MainForm.Controls.Add($OkButton)

$MainForm.ShowDialog() | Out-Null
#endregion

#region Fenêtre de progression
$ProgressForm = New-Object -TypeName System.Windows.Forms.Form
$ProgressForm.Text = $Language.Form.progressFormText
$ProgressForm.Width = 600
$ProgressForm.Height = 250
$ProgressForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$ProgressForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$ProgressForm.BackColor = [System.Drawing.Color]::FromArgb(5, 0, 51)

$ProgressBar = New-Object -TypeName System.Windows.Forms.ProgressBar
$ProgressBar.Width = 550
$ProgressBar.Height = 30
$ProgressBar.Left = 25
$ProgressBar.Top = 25
$ProgressBar.Minimum = 0
$ProgressBar.Maximum = 100
$ProgressForm.Controls.Add($ProgressBar)

$ProgressTextBox = New-Object -TypeName System.Windows.Forms.RichTextBox
$ProgressTextBox.Width = 550
$ProgressTextBox.Height = 150
$ProgressTextBox.Left = 25
$ProgressTextBox.Top = 70
$ProgressTextBox.Font = New-Object -TypeName System.Drawing.Font -Name 'Arial' -Size 10
$ProgressTextBox.ReadOnly = $true
$ProgressTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$ProgressForm.Controls.Add($ProgressTextBox)

$ProgressForm.Show()
#endregion

#region Sauvegarde des données
Write-Log -Message '=== Début de la sauvegarde === ' -Level 'INFO'

# Dossiers à sauvegarder
$SourceFolders = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Contacts",
    "$env:USERPROFILE\Favorites",
    "$env:USERPROFILE\Links",
    "$env:USERPROFILE\Aitdesk"
)
$ExcludeFiles = @('desktop.ini', 'thumbs.db', $Language.Path.excludeBackuplnk, $Language.Path.excludeBackupexe)

# Copie des dossiers utilisateur
foreach ($Index in 0..($SourceFolders.Count - 1)) {
    $SourceFolder = $SourceFolders[$Index]
    $PercentComplete = [math]::Round(($Index + 1) / $SourceFolders.Count * 100)
    $ProgressBar.Value = $PercentComplete
    $FolderName = Split-Path -Path $SourceFolder -Leaf

    if (Test-Path -Path $SourceFolder) {
        Write-ProgressMessage ($Language.ProgressMessageCopyFolder -f $FolderName)
        $Destination = Join-Path -Path $env:PUBLIC -ChildPath $FolderName
        Copy-WithRobocopy -Source $SourceFolder -Destination $Destination -ExcludeFiles $ExcludeFiles
    } else {
        Write-ProgressMessage ($Language.ProgressMessageCopyFolderIgnore -f $FolderName)
    }
}

# Favoris navigateurs
@('Chrome', 'Edge') | ForEach-Object {
    $Browser = $_
    $BookmarksPath = "$env:USERPROFILE\AppData\Local\$Browser\User Data\Default\Bookmarks"
    $Destination = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.("Favorites$Browser")
    if (Test-Path -Path $BookmarksPath) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
        Copy-Item -Path $BookmarksPath -Destination $Destination -Force -ErrorAction SilentlyContinue
        Write-ProgressMessage ($Language.("ProgressMessage$Browser"))
    } else {
        Write-ProgressMessage ($Language.ProgressMessageBrowserNotFound -f $Browser)
    }
}

# Signatures Outlook
$SignaturesSource = "$env:APPDATA\Microsoft\Signatures"
$SignaturesDestination = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.SignatureOutlook
if (Test-Path -Path $SignaturesSource) {
    Copy-Item -Path $SignaturesSource -Destination $SignaturesDestination -Recurse -Force -ErrorAction SilentlyContinue
    Write-ProgressMessage $Language.ProgressMessageSignature
}

# Stream_Autocomplete
$StreamAutocompleteSource = "$env:USERPROFILE\AppData\Local\Microsoft\Outlook\RoamCache"
$StreamAutocompleteDestination = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.Stream_Autocomplete
$StreamAutocompleteFile = Get-ChildItem -Path $StreamAutocompleteSource -Filter 'Stream_Autocomplete*.dat' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($StreamAutocompleteFile) {
    New-Item -Path $StreamAutocompleteDestination -ItemType Directory -Force | Out-Null
    Copy-Item -Path $StreamAutocompleteFile.FullName -Destination $StreamAutocompleteDestination -Force -ErrorAction SilentlyContinue
    Write-ProgressMessage ($Language.ProgressMessageStream_Autocomplete -f $StreamAutocompleteFile.Name)
}

# Lecteurs réseau
$NetworkFolder = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.network
New-Item -Path $NetworkFolder -ItemType Directory -Force | Out-Null
$NetworkDrives = Get-WmiObject -Class Win32_MappedLogicalDisk | ForEach-Object { "$($_.DeviceID)`t$($_.ProviderName)" }
$NetworkDrivesFile = Join-Path -Path $NetworkFolder -ChildPath $Language.Path.FileNetWorkDrive
$NetworkDrives | Out-File -FilePath $NetworkDrivesFile
Write-ProgressMessage $Language.ProgressMessageNetworkDrive

# Imprimantes réseau
$PrintersFile = Join-Path -Path $NetworkFolder -ChildPath $Language.Path.FilePrinter
$NetworkPrinters = Get-Printer | Where-Object { $_.Type -ne 'Local' }
$DefaultPrinter = Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Default=$true"
$PrintersContent = @()
foreach ($Printer in $NetworkPrinters) {
    $IsDefault = if ($Printer.Name -eq $DefaultPrinter.Name) { 'yes' } else { 'no' }
    $PrintersContent += "$($Printer.Name);$IsDefault"
}
$PrintersContent | Out-File -FilePath $PrintersFile -Encoding UTF8
Write-ProgressMessage $Language.ProgressMessagePrinters

# Quick Launch
$QuickLaunchSource = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
$QuickLaunchDestination = Join-Path -Path $env:PUBLIC -ChildPath $Language.Path.QuickLaunch
if (Test-Path -Path $QuickLaunchSource) {
    Copy-Item -Path $QuickLaunchSource -Destination $QuickLaunchDestination -Recurse -Force -ErrorAction SilentlyContinue
    Write-ProgressMessage $Language.ProgressMessageQuickLaunch
}

# Raccourcis Outlook
$EdgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$PublicDesktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')

# Raccourci Outlook principal
$OutlookMainShortcut = Join-Path -Path $PublicDesktop -ChildPath $Language.Path.OutlookPrincipal
New-Shortcut -TargetApplication $EdgePath -OutputDirectory $PublicDesktop -Name $Language.Path.OutlookPrincipal -Description $Language.Path.OutlookPrincipal_Description -Arguments 'https://outlook.office365.com/mail/' -IconPath "$EdgePath,0" | Out-Null
Write-ProgressMessage $Language.ProgressMessageMainOutlook

# Raccourcis délégués
$UserFolders = Get-ChildItem -Path 'C:\Users' | Where-Object { $_.PSIsContainer -and $_.Name -match '^H[A-Za-z0-9]{4}(-[A-Za-z]{2})?$' }
foreach ($UserFolder in $UserFolders) {
    $Username = $UserFolder.Name
    $DelegatedUrl = "https://outlook.office365.com/mail/$Username@accor.com"
    $DelegatedShortcutName = $Language.Path.OutlookDelegue -f $Username
    New-Shortcut -TargetApplication $EdgePath -OutputDirectory $PublicDesktop -Name $DelegatedShortcutName -Description ($Language.Path.OutlookDelegue_Description -f $Username) -Arguments $DelegatedUrl -IconPath "$EdgePath,0" | Out-Null
    Write-ProgressMessage ($Language.ProgressMessageUsersOutlook -f $Username)
}

# Raccourci FOLS
$FolsServerVariable = Get-ChildItem -Path Env: | Where-Object { $_.Value -like '*-fls1*' } | Select-Object -First 1
if ($FolsServerVariable) {
    $FolsUrl = "https://$($FolsServerVariable.Value).eu.accor.net"
    $FolsShortcutPath = Join-Path -Path $PublicDesktop -ChildPath 'Fols.url'
    $FolsIconPath = if (Test-Path -Path 'C:\accorprg\Fols\icon\fols.ico') { 'C:\accorprg\Fols\icon\fols.ico' } else { 'C:\Program Files\Internet Explorer\iexplore.exe' }
    @"
[InternetShortcut]
URL=$FolsUrl
IconFile=$FolsIconPath
IconIndex=0
"@ | Set-Content -Path $FolsShortcutPath -Encoding ASCII
    Write-ProgressMessage ($Language.ProgressMessageURLSuccess -f $FolsShortcutPath)
}

# OneDrive
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
while (Get-Process -Name OneDrive -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 1 }

$OneDrivePath = "$env:USERPROFILE\OneDrive - ACCOR"
if (Test-Path -Path $OneDrivePath) {
    Write-Log -Message "Copie du contenu OneDrive..." -Level 'INFO'
    try {
        $OneDriveMappings = @{
            'Bureau' = "$($env:PUBLIC)\Desktop"
            'Documents' = "$($env:PUBLIC)\Documents"
            'Images' = "$($env:PUBLIC)\Images"
            'Téléchargements' = "$($env:PUBLIC)\Downloads"
        }
        foreach ($OneDriveFolder in $OneDriveMappings.GetEnumerator()) {
            $Source = Join-Path -Path $OneDrivePath -ChildPath $OneDriveFolder.Key
            if (Test-Path -Path $Source) {
                Copy-Item -Path "$Source\*" -Destination $OneDriveFolder.Value -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log -Message "Dossier OneDrive/$($OneDriveFolder.Key) copié vers $($OneDriveFolder.Value)." -Level 'INFO'
            }
        }
        Copy-Item -Path "$OneDrivePath\*" -Destination "$($env:PUBLIC)\Documents" -Force -ErrorAction SilentlyContinue
        Write-ProgressMessage $Language.ProgressMessageOneDrive
        Write-Log -Message "Contenu OneDrive copié avec succès." -Level 'INFO'
    } catch {
        Write-Log -Message "Erreur lors de la copie du contenu OneDrive : $($_.Exception.Message)" -Level 'ERROR'
    }
} else {
    Write-Log -Message "Dossier OneDrive non trouvé, ignoré." -Level 'WARNING'
}

# Raccourci de restauration
$RestoreShortcut = Join-Path -Path $PublicDesktop -ChildPath $Language.Path.RestoreShortcut
New-Shortcut -TargetApplication 'powershell.exe' -OutputDirectory $PublicDesktop -Name $Language.Path.RestoreShortcut -Description $Language.Path.RestoreShortcut_Description -Arguments "-WindowStyle hidden -executionpolicy bypass -file `$PSScriptRoot\Restauration.ps1" -IconPath "$PSScriptRoot\Restauration.ico" | Out-Null

# Suppression de l'ancien raccourci
$OldBackupShortcut = Join-Path -Path $PublicDesktop -ChildPath $Language.Path.excludeBackuplnk
if (Test-Path -Path $OldBackupShortcut) {
    Remove-Item -Path $OldBackupShortcut -Force
}
#endregion

# Fin
$ProgressForm.Close()
[System.Windows.Forms.MessageBox]::Show($Language.PopUp.Text, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
& notepad.exe /A $ResumeFilePath
