# Charger les composants Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Déterminer la langue du système d'exploitation
$lang = [System.Globalization.CultureInfo]::CurrentUICulture.Name

# Définir le chemin dynamique du dossier Localized
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$localizedPath = Join-Path -Path $basePath -ChildPath "Localized"

# Définir le chemin du fichier PSD1 en fonction de la langue de l'OS
if ($lang -eq 'fr-FR') {
    $psd1Path = Join-Path -Path $localizedPath -ChildPath "fr-FR\Sauvegarde.psd1"
} else {
    $psd1Path = Join-Path -Path $localizedPath -ChildPath "Sauvegarde.psd1"
}

# Charger les messages localisés
try {
    $ProgressMessage = Import-PowerShellDataFile -Path $psd1Path
    if ($null -eq $ProgressMessage) {
        throw "Le fichier de messages localisés est introuvable ou vide : $psd1Path"
    }
} catch {
    Write-Host "Erreur lors du chargement du fichier PSD1 : $($_.Exception.Message)"
    exit
}

function Test-DiskSpace {
    param (
        [string]$DriveLetter = "C",
        [string]$sourceFolder = "C:\Users\$env:USERNAME"  # Chemin du dossier utilisateur de la session ouverte
    )

    # Vérifier si $ProgressMessage est bien initialisé
    if ($null -eq $ProgressMessage) {
        Write-Host "Les messages de progression ne sont pas disponibles. Impossible de continuer."
        exit
    }

    # Début de la vérification de l'espace disque
    Write-Host ($ProgressMessage['ProgressMessageDiskSpaceCheckStart'] -f $DriveLetter)

    try {
        # Calculer la taille réelle du dossier utilisateur à copier (en octets)
        $requiredFolderSize = (Get-ChildItem -Path $sourceFolder -Recurse -Force | Measure-Object -Property Length -Sum).Sum

        # Vérification réelle de l'espace disque
        $drive = Get-PSDrive -Name $DriveLetter -ErrorAction Stop

        $freeSpace = $drive.Free  # Espace libre sur le lecteur (en octets)
        $totalSpace = $drive.Used + $drive.Free  # Espace total du lecteur (en octets)

        # Calculer l'espace libre nécessaire pour rester au-dessus de 10% de la capacité totale du disque
        $tenPercentThreshold = [math]::Ceiling($totalSpace * 0.1)  # 10% de la capacité totale

        # Calculer l'espace disponible après la copie
        $spaceAfterCopy = $freeSpace - $requiredFolderSize

        if ($spaceAfterCopy -lt $tenPercentThreshold) {
            # Calculer la quantité d'espace à libérer pour permettre la copie tout en respectant les 10% restants
            $spaceToFree = $requiredFolderSize + $tenPercentThreshold - $freeSpace
            $spaceToFreeGB = [math]::Ceiling($spaceToFree / 1GB)  # Convertir en Go et arrondir

            if ($ProgressMessage.ProgressMessage.ContainsKey('ProgressMessageDiskSpaceInsufficient')) {
                $message = $ProgressMessage.ProgressMessage['ProgressMessageDiskSpaceInsufficient'] -f $spaceToFreeGB
                Write-Host "Message d'erreur : $message"
            } else {
                Write-Host "Erreur : La clé 'ProgressMessageDiskSpaceInsufficient' est manquante dans les données localisées."
                $message = "Il manque $spaceToFreeGB Go d'espace disque."
            }

            # Afficher une boîte de message d'erreur indiquant l'espace insuffisant
            [System.Windows.Forms.MessageBox]::Show($message, $ProgressMessage['TitleDiskSpaceError'], [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            exit  # Arrêter l'exécution du script
        }

        # Si l'espace est suffisant, continuer sans message

    } catch {
        # Afficher une boîte de message d'erreur en cas de lecteur non trouvé ou autre erreur
        [System.Windows.Forms.MessageBox]::Show(($ProgressMessage['ProgressMessageDiskSpaceCheckError'] -f $DriveLetter), $ProgressMessage['TitleDiskSpaceError'], [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
        exit  # Arrêter l'exécution du script
    }
}

# Appel de la fonction de vérification d'espace disque pour le dossier utilisateur actuel
Test-DiskSpace -DriveLetter "C"

# Gestion du chemin du script actuel
if ($null -ne$psISE) {
    $CurrentFolder = Split-Path -Path $psISE.CurrentFile.FullPath        
} else {
    $CurrentFolder = $PSScriptRoot
}

function New-Shortcut
{
    <#
    .SYNOPSIS
        Easily create shortcuts from any application.
    
    .DESCRIPTION
        Creates shorcuts that can be elevated or not from any application, outputting a custom PowerShell object detailing the newly created shortcut and any parameters set to it.
    
    .PARAMETER TargetApplication
        The full path to the target application the shortcut will point to.
    
    .PARAMETER OutputDirectory
        The full path to the directory where the shortcut will be created. If no output directory is supplied, the shortcut will be created in the same location as the target application.
    
    .PARAMETER Name
        The name of the shortcut. By default the target application name is used for the shortcut name.
    
    .PARAMETER Description
        A comment describing the details of the shortcut.
    
    .PARAMETER Arguments
        Any special arguments the shortcut will pass to the target application.
    
    .PARAMETER WorkingDirectory
        The full path of the directory the target application uses during execution.
    
    .PARAMETER HotKey
        A hotkey combination that can be used to execute the shortcut.
    
    .PARAMETER WindowStyle
        The windows style of the target application - Normal, Maximized or Minimized.
    
    .PARAMETER IconPath
        The full path and optional integer value of the icon file to use for the shortcut. Example: 'imageres.dll,-1023'
    
    .PARAMETER Elevated
        Sets the shortcut to run with administrative privileges.
    
    .EXAMPLE
        PS C:\> New-Shortcut -TargetApplication "C:\Tools and Utilities\Registry Workshop\RegWorkshop64.exe" -OutputDirectory "$HOME\Desktop" -Name "Registry Workshop" -Description "An advanced registry editor." -Elevated
        PS C:\> New-Shortcut -TargetApplication "C:\Tools and Utilities\Notepad++\notepad++.exe" -HotKey Ctrl+Alt+N
        PS C:\> "D:\Imaging Tools\Deployment\imagex.exe | New-Shortcut
    
    .OUTPUTS
        PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The full path to the target application the shortcut will point to.')]
        [ValidateNotNullOrEmpty()]
        [string]$TargetApplication,
        [Parameter(HelpMessage = 'The full path to the directory where the shortcut will be created.')]
        [string]$OutputDirectory,
        [Parameter(HelpMessage = 'The name of the shortcut. By default the target application name is used for the shortcut name.')]
        [string]$Name,
        [Parameter(HelpMessage = 'A comment describing the details of the shortcut.')]
        [string]$Description,
        [Parameter(HelpMessage = 'Any special arguments the shortcut will pass to the target application.')]
        [string]$Arguments,
        [Parameter(HelpMessage = 'The full path of the directory the target application uses during execution.')]
        [string]$WorkingDirectory,
        [Parameter(HelpMessage = 'A hotkey combination that can be used to execute the shortcut.')]
        [string]$HotKey,
        [Parameter(HelpMessage = 'The windows style of the target application.')]
        [ValidateSet('Normal', 'Maximized', 'Minimized')]
        [string]$WindowStyle = 'Normal',
        [Parameter(HelpMessage = 'The full path and integer value to the icon file to use for the shortcut.')]
        [string]$IconPath,
        [Parameter(HelpMessage = 'Sets the shortcut to run with administrative privileges.')]
        [switch]$Elevated
    )
    
    Begin
    {
        $Offset = 0x15
    }
    Process
    {
        If ($Name)
        {
            $ShortcutName = [System.IO.Path]::ChangeExtension($Name, '.lnk')
        }
        Else
        {
            $ShortcutName = [System.IO.Path]::ChangeExtension($(Split-Path -Path $TargetApplication -Leaf), '.lnk')
        }
        If (!$OutputDirectory)
        {
            $ShortcutPath = Join-Path -Path (Split-Path -Path $TargetApplication -Parent) -ChildPath $ShortcutName
        }
        Else
        {
            $ShortcutPath = Join-Path -Path $OutputDirectory -ChildPath $ShortcutName
        }
        Switch ($WindowStyle)
        {
            'Normal' { [int]$WindowStyle = 1 }
            'Maximized' { [int]$WindowStyle = 3 }
            'Minimized' { [int]$WindowStyle = 7 }
        }
        Try
        {
            $ObjShell = New-Object -ComObject WScript.Shell
            $Shortcut = $ObjShell.CreateShortcut($ShortcutPath)
            $Shortcut.TargetPath = $TargetApplication
            $Shortcut.WorkingDirectory = $WorkingDirectory
            $Shortcut.Description = $Description
            $Shortcut.Arguments = $Arguments
            $Shortcut.WindowStyle = $WindowStyle
            $Shortcut.HotKey = $HotKey
            If ($IconPath)
            {
                $Shortcut.IconLocation = $IconPath
            }
            $Shortcut.Save()
            If ($Elevated)
            {
                $Bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
                $Bytes[$Offset] = $Bytes[$Offset] -bor 0x20
                [System.IO.File]::WriteAllBytes($ShortcutPath, $Bytes)
                [bool]$Elevated = $true
            }
            Else
            {
                [bool]$Elevated = $false
            }
            $Result = [PSCustomObject]@{
                Name        = $ShortcutName
                Directory   = (Split-Path -Path $ShortcutPath -Parent)
                Application = (Split-Path -Path $TargetApplication -Leaf)
                Description = $Description
                Arguments   = $Arguments
                HotKey      = $HotKey
                Elevated    = $Elevated
            } | Format-List
        }
        Catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        Finally
        {
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($ObjShell)
        }
    }
    End
    {
        If ($Result)
        {
            Return $Result
        }
    }
}

$global:ValidateButton = $false

$global:ValidateButton = $false
switch -Wildcard ((Get-Culture).Name) {
    "fr-*" {$OverwriteCulture = "fr-FR" ;  break }
    "de-*" {$OverwriteCulture = "de-DE" ;  break }
    "es-*" {$OverwriteCulture = "es-ES" ;  break }
	Default {$OverwriteCulture = $((Get-Culture).Name) ;  break }
}

#$OverwriteCulture = "fr-FR"

$Language = Import-LocalizedData -BaseDirectory (Join-Path -Path $CurrentFolder -ChildPath Localized) -UICulture $OverWriteCulture

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FenÃªtre d'informations principale
$form = New-Object Windows.Forms.Form
$form.Text = $($Language.Form.Title)
$form.Size = New-Object Drawing.Size(1024, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"  # FenÃªtre non redimensionnable
$form.BackColor = [System.Drawing.Color]::FromArgb(5, 0, 51)

# Label pour le titre
$labelCenteredText = New-Object Windows.Forms.Label
$labelCenteredText.Size = New-Object Drawing.Size(984, 40)
$labelCenteredText.Location = New-Object Drawing.Point(20, 20)
$labelCenteredText.Font = New-Object Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$labelCenteredText.TextAlign = "MiddleCenter"
$labelCenteredText.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelCenteredText.Text = $($Language.Form.labelCenteredText)
$form.Controls.Add($labelCenteredText)

# RichTextBox pour le texte principal
$richTextBox = New-Object Windows.Forms.RichTextBox
$richTextBox.Size = New-Object Drawing.Size(984, 360)
$richTextBox.Location = New-Object Drawing.Point(20, 70)
$richTextBox.Font = New-Object Drawing.Font("Arial", 10)
$richTextBox.Multiline = $true
$richTextBox.ReadOnly = $true
$richTextBox.ScrollBars = "Vertical"
$richTextBox.Rtf = $($Language.RTF.text)
$form.Controls.Add($richTextBox)

# Bouton OK
$okButton = New-Object Windows.Forms.Button
$okButton.Size = New-Object Drawing.Size(100, 30)
$okButton.Left = ($form.Width - $okButton.Width) / 2
$okButton.Top = 450
$okButton.Text = $($Language.Form.Button)
$okButton.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)  # Couleur du texte en RVB
$okButton.ForeColor = [System.Drawing.Color]::FromArgb(5, 0, 51)  # Couleur de fond en RVB
$okButton.Font = New-Object Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$okButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($okButton)

$form.ShowDialog() | Out-Null

If(!$global:ValidateButton){exit}

# Fenêtre de progression
$progressForm = New-Object Windows.Forms.Form
$progressForm.Text = $($Language.Form.progressFormText)
$progressForm.Size = New-Object Drawing.Size(600, 250)
$progressForm.StartPosition = "CenterScreen"
$progressForm.FormBorderStyle = "FixedDialog"
$progressForm.BackColor = [System.Drawing.Color]::FromArgb(5, 0, 51)

# Cadre pour la barre de progression
$progressBarFrame = New-Object Windows.Forms.Panel
$progressBarFrame.Size = New-Object Drawing.Size(554, 34)
$progressBarFrame.Location = New-Object Drawing.Point(18, 18)
$progressBarFrame.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Couleur de bordure

# Barre de progression
$progressBar = New-Object Windows.Forms.ProgressBar
$progressBar.Size = New-Object Drawing.Size(550, 30)
$progressBar.Location = New-Object Drawing.Point(2, 2) # Ajuster pour être à l'intérieur du cadre
$progressBar.Minimum = 0
$progressBar.Maximum = 100

$progressBarFrame.Controls.Add($progressBar)

# Label pour afficher le texte de progression
$progressText = New-Object Windows.Forms.Label
$progressText.Size = New-Object Drawing.Size(550, 30)
$progressText.Location = New-Object Drawing.Point(20, 60)
$progressText.Font = New-Object Drawing.Font("Arial", 10)
$progressText.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$progressText.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 255)  # Couleur de fond en RVB (bleu clair)
$progressText.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)  # Couleur du texte en RVB (blanc)

# Zone de texte pour afficher des messages
$progressTextBox = New-Object Windows.Forms.RichTextBox
$progressTextBox.Size = New-Object Drawing.Size(550, 80)
$progressTextBox.Location = New-Object Drawing.Point(20, 100)
$progressTextBox.Font = New-Object Drawing.Font("Arial", 10)
$progressTextBox.ReadOnly = $true
$progressTextBox.ScrollBars = "Vertical"

$progressForm.Controls.Add($progressBarFrame)
$progressForm.Controls.Add($progressText)
$progressForm.Controls.Add($progressTextBox)

$progressForm.Show()


# Dossier cible
$dossierPublic = "C:\Users\Public"

# Chemin du fichier de résumé
$resumeFilePath = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.resumeFile)
New-Item -Path $resumeFilePath -ItemType File -Force

# Fonction pour ajouter des messages à la zone de texte de progression et au fichier de résumé
function Write-ProgressMessage {
    param (
        [string]$message
    )
    $progressTextBox.AppendText("$message`n")  # Ajoute le message suivi d'un retour à la ligne
    $progressTextBox.SelectionStart = $progressTextBox.Text.Length
    $progressTextBox.ScrollToCaret()
    Add-Content -Path $resumeFilePath -Value $message  # Ajoute le message au fichier de résumé
}

# Dossiers source à copier
$dossiersSource = @(
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

# Types de fichiers systÃ¨me à exclure
$excludeSystemFiles = @("desktop.ini", "thumbs.db",$($Language.Path.excludeBackuplnk),$($Language.Path.excludeBackupexe))

# Copie des dossiers vers le dossier Public
$totalFolders = $dossiersSource.Count
$NumberCurrentFolder = 0

foreach ($dossier in $dossiersSource) {
    $NumberCurrentFolder++
    $percentComplete = [math]::Round(($NumberCurrentFolder / $totalFolders) * 100)
    $progressBar.Value = $percentComplete
    $progressText.Text = $($Language.ProgressMessage.progressText -f $percentComplete)
    
    $dossierNom = Split-Path $dossier -Leaf
    
    if (Test-Path $dossier) {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageCopyFolder -f $dossierNom)
		
        #Copy-Item -Path $dossier -Destination $dossierPublic -Recurse -Force -ErrorAction SilentlyContinue -Exclude $excludeSystemFiles
		
		$source = $dossier
		$destination = Join-Path -Path $dossierPublic -ChildPath $((get-item $Dossier).name)
		$logfilename = $((get-item $Dossier).name) + "_Robocopy.log"
		$logFileRobocopy = Join-Path -Path $dossierPublic -ChildPath $logfilename

		$robocopyCmd = "`"$source`" `"$destination`" /E /R:3 /W:5 /XJD /XF $excludeSystemFiles /LOG:`"$logFileRobocopy`" /NP /V /TEE"
		
		try {
			$process = (Start-Process robocopy.exe -Argumentlist $robocopyCmd -PassThru -Wait)
			
			if ($process.exitcode -ge 8 -or $process.exitcode -lt 0) {
				throw $($Language.ProgressMessage.ProgressMessageCopythrow -f $($process.exitcode))
			}else{
				Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageCopySucces -f $Source,$destination)
			}
		} catch {
			$ErrorMsg = "$_"
			Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageCopyError -f $Source,$destination,$ErrorMsg)
		}		
		
    } else {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageCopyFolderIgnore -f $dossierNom)
    }
    
    Start-Sleep -Milliseconds 500
}

# ------------------------------------------
# Récupération des Favoris
# ------------------------------------------

# Récupération des favoris de Chrome
$cheminChrome = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
$destinationChrome = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.FavoritesChrome)
New-Item -ItemType Directory -Path $destinationChrome -Force | Out-Null

try {
	Copy-Item -Path $cheminChrome -Destination $destinationChrome -Force -ErrorAction stop
	Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageChrome)
} catch {
	$ErrorMsg = "$_"
	$($Language.ProgressMessage.ProgressMessageCopyFailed -f $ErrorMsg)	
}

# Récupération des favoris d'Edge
$cheminEdge = "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
$destinationEdge = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.FavoritesEdge)
New-Item -ItemType Directory -Path $destinationEdge -Force | Out-Null

try {
	Copy-Item -Path $cheminEdge -Destination $destinationEdge -Force -ErrorAction stop
	Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageEdge)	
} catch {
	$ErrorMsg = "$_"
	$($Language.ProgressMessage.ProgressMessageCopyFailed -f $ErrorMsg)
}



# ------------------------------------------
# copie du dossier Signature
# ------------------------------------------

# chemin du dossier de signature Outlook
$cheminSignatureOutlook = "$env:APPDATA\Microsoft\Signatures"

# Destination
$destinationSignature = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.SignatureOutlook)
New-Item -ItemType Directory -Path $destinationSignature -Force | Out-Null

try {
	Copy-Item -Path $cheminSignatureOutlook -Destination $destinationSignature -Recurse -Force -ErrorAction stop
	Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageSignature)
} catch {
	$ErrorMsg = "$_"
	$($Language.ProgressMessage.ProgressMessageCopyFailed -f $ErrorMsg)
}

# ------------------------------------------
# Récupération des entrées de saisie semi-automatique Outlook
# ------------------------------------------

$sourcePath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Outlook\RoamCache"
$destinationPath = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.Stream_Autocomplete)

# Recherche du fichier Stream_Autocomplete dans le dossier source
$sourceFile = Get-ChildItem -Path $sourcePath -Filter "Stream_Autocomplete*.dat" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($sourceFile) {
		# Création du dossier de destination s'il n'existe pas
		if (-not (Test-Path $destinationPath)) {
			New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
		}
	
	try {
		# Copie du fichier vers le dossier de destination
		Copy-Item -Path $sourceFile.FullName -Destination $destinationPath -Force -ErrorAction stop
		Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageStream_Autocomplete -f $($sourceFile.Name), $destinationPath)
	} catch {
		$ErrorMsg = "$_"
		$($Language.ProgressMessage.ProgressMessageCopyFailed -f $ErrorMsg)
	}
	
} else {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageStream_AutocompleteIgnore -f $sourcePath)
}
# ------------------------------------------
# Lecteur Réseau
# ------------------------------------------

# Création du dossier "Réseau" dans le dossier public
$dossierReseau = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.network)

# Vérifie et crée le dossier s'il n'existe pas
if (-not (Test-Path -Path $dossierReseau)) {
    New-Item -Path $dossierReseau -ItemType Directory | Out-Null
}

# Chemin pour sauvegarder les informations de lecteurs réseau
$cheminFichierLecteursReseau = Join-Path -Path $dossierReseau -ChildPath $($Language.Path.FileNetWorkDrive)

# Récupération des informations de lecteurs réseau
$infosLecteursReseau = Get-WmiObject Win32_MappedLogicalDisk | ForEach-Object { "$($_.DeviceID)`t$($_.ProviderName)" }

# Ã‰criture des informations de lecteurs réseau dans un fichier texte (une seule ligne)
$infosLecteursReseau -join "`r`n" | Out-File -FilePath $cheminFichierLecteursReseau

Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageNetworkDrive)

# ------------------------------------------
# Imprimante Réseau
# ------------------------------------------

# Chemin pour sauvegarder les informations des imprimantes réseau
$cheminFichierImprimantesReseau = Join-Path -Path $dossierReseau -ChildPath $($Language.Path.FilePrinter)

# Récupération des informations des imprimantes réseau
$infosImprimantesReseau = Get-Printer | Where-Object { $_.type -ne "Local"} | Select-Object Name, Default

# Récupération de l'imprimante par défaut
$defaultPrinter = Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Default=$true"

# Création du contenu à écrire dans le fichier
$content = @()

# Ajout des informations de chaque imprimante
foreach ($imprimante in $infosImprimantesReseau) {
    $estParDefaut = if ($imprimante.Name -eq $defaultPrinter.Name) { "yes" } else { "no" }
    $content += "$($imprimante.Name);$estParDefaut"
	Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageSavePrinters -f $($imprimante.Name))
}

# Ã‰criture du contenu dans le fichier
try {
    $content | Out-File -FilePath $cheminFichierImprimantesReseau -Encoding UTF8
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessagePrinters -f $cheminFichierImprimantesReseau)
} catch {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessagePrintersError -f $_)
}

Write-ProgressMessage $($Language.ProgressMessage.ProgressMessagePrintersEnd)

# ------------------------------------------
# Récupération du dossier de la barre de lancement rapide
# ------------------------------------------

# Chemin du dossier "Quick Launch" dans le profil utilisateur actuel
$cheminQuickLaunch = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"

# Chemin de destination du dossier "Quick Launch" dans le dossier Public
$destinationQuickLaunch = Join-Path -Path $dossierPublic -ChildPath $($Language.Path.QuickLaunch)

# Copie du dossier "Quick Launch" vers le dossier Public
if (Test-Path $cheminQuickLaunch -PathType Container) {
	try {
		Copy-Item -Path $cheminQuickLaunch -Destination $destinationQuickLaunch -Recurse -Force -ErrorAction stop
		Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageQuickLaunch)
	} catch {
		$ErrorMsg = "$_"
		$($Language.ProgressMessage.ProgressMessageCopyFailed -f $ErrorMsg)
	}	
} else {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageQuickLaunchIgnore -f $cheminQuickLaunch)
}

# ------------------------------------------
# Création des raccourcis Outlook
# ------------------------------------------

# Chemin vers le programme Microsoft Edge
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Chemin où les raccourcis Outlook seront créés sur le Bureau public
$bureauPublic = [System.Environment]::GetFolderPath("CommonDesktopDirectory")

# URL de la boîte mail principale
$urlPrincipalOutlook = "https://outlook.office365.com/mail/"

# Créer le raccourci pour la boîte mail principale
$shortcutPathOutlookPrincipal = Join-Path -Path $bureauPublic -ChildPath $($Language.Path.OutlookPrincipal)

# Créer l'objet raccourci pour la boîte mail principale
$shell = New-Object -ComObject WScript.Shell
$shortcutPrincipal = $shell.CreateShortcut($shortcutPathOutlookPrincipal)

# Définir les propriétés du raccourci Outlook principal
$shortcutPrincipal.TargetPath = $edgePath
$shortcutPrincipal.Arguments = $urlPrincipalOutlook
$shortcutPrincipal.IconLocation = "$edgePath,0"  # Utiliser l'icône de Microsoft Edge
$shortcutPrincipal.Description = $($Language.Path.OutlookPrincipal_Description)

# Sauvegarder le raccourci principal
try {
    $shortcutPrincipal.Save()
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageMainOutlook)
} catch {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageMainOutlookError -f $_)
}

$shell = New-Object -ComObject WScript.Shell
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Parcourir le répertoire C:\Users pour obtenir la liste des utilisateurs
$usersPath = "C:\Users"
$users = Get-ChildItem -Path $usersPath | Where-Object { $_.PSIsContainer -and ($_.Name -match '^H[A-Za-z0-9]{4}(-[A-Za-z]{2})?$') }

foreach ($user in $users) {
    # Nom d'utilisateur
    $username = $user.Name
    
    # URL cible du raccourci Outlook pour l'utilisateur délégué
    $urlOutlookDelegue = "https://outlook.office365.com/mail/$username@accor.com"
    
    # Chemin où le raccourci Outlook sera créé pour l'utilisateur délégué
    $shortcutPathOutlookDelegue = Join-Path -Path $bureauPublic -ChildPath $($Language.Path.OutlookDelegue -f $username)
    
    # Créer l'objet raccourci pour l'utilisateur délégué
    $shortcutDelegue = $shell.CreateShortcut($shortcutPathOutlookDelegue)
    
    # Définir les propriétés du raccourci Outlook pour l'utilisateur délégué
    $shortcutDelegue.TargetPath = $edgePath
    $shortcutDelegue.Arguments = $urlOutlookDelegue
    $shortcutDelegue.IconLocation = "$edgePath,0"  # Utiliser l'icône de Microsoft Edge
    $shortcutDelegue.Description = $($Language.Path.OutlookDelegue_Description -f $username)
    
    # Sauvegarder le raccourci pour l'utilisateur délégué
    try {
        $shortcutDelegue.Save()
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageUsersOutlook -f $username)
    } catch {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageUsersOutlookError -f $_)
    }
}

# ------------------------------------------
# Création du raccourci FOLS
# ------------------------------------------
$serverVariable = Get-ChildItem Env:* | Where-Object { $_.Value -like '*-fls1*' } | Select-Object -First 1

if ($serverVariable) {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageVariableFLS1Found -f $($serverVariable.Name))
    
    # Récupération de la valeur de la variable trouvée
    $serverName = $serverVariable.Value
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageVariableFLS1Value -f $serverName)

    # Construction de l'URL
    $url = "https://$serverName.eu.accor.net"
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLBuilded -f $url)

    # Chemin où le raccourci sera créé
    $shortcutPath = "C:\Users\Public\Desktop\Fols.url"
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLPath -f $shortcutPath)

    # Chemin vers l'icône d'Internet Explorer
    $iconPath = "C:\accorprg\Fols\icon\fols.ico"
    if (-Not (Test-Path $iconPath)) {
        $iconPath = "C:\Program Files\Internet Explorer\iexplore.exe"
    }

    # Contenu du fichier raccourci internet
    $shortcutContent = @"
[InternetShortcut]
URL=$url
IconFile=$iconPath
IconIndex=0
"@

    # Créer le fichier raccourci internet avec le contenu approprié
    try {
        Set-Content -Path $shortcutPath -Value $shortcutContent -Encoding ASCII -ErrorAction Stop
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLSuccess -f $shortcutPath)
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLInfo -f $url)
    } catch {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLError -f $_)
    }

    # Vérifier si le fichier a été créé
    if (Test-Path $shortcutPath) {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLOK)
    } else {
        Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageURLKO)
    }

    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageShortCutFols -f $shortcutPath)
} else {
    Write-ProgressMessage  $($Language.ProgressMessage.ProgressMessageNOVAR)
    Write-ProgressMessage  $($Language.ProgressMessage.ProgressMessageLISTVAR)
    Get-ChildItem Env:* | Where-Object { $_.Name -like '*ACCOR*' -or $_.Name -like '*SERVER*' } | ForEach-Object { Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageVARNameValue -f $($_.Name), $($_.Value)) }
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageFolsNotFound)
}
#-----------------------------------------------
# Arrêter OneDrive avant de commencer la copie
#-----------------------------------------------
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue

# Vérifier si OneDrive est bien arrêté
while (Get-Process -Name OneDrive -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

# Maintenant que OneDrive est arrêté, poursuivre avec la copie


# ------------------------------------------
# Copie du dossier OneDrive dans le dossier Public
# ------------------------------------------

# Chemin du dossier OneDrive pour l'utilisateur actuel
$cheminOneDrive = "C:\Users\$env:USERNAME\OneDrive - ACCOR"
$destinationPublic = "C:\Users\Public"

# Liste des dossiers spécifiques et leur destination dans Public
$dossiersSpecifiques = @{
    "Bureau"          = "$destinationPublic\Desktop"
    "Documents"       = "$destinationPublic\Documents"
    "Images"          = "$destinationPublic\Pictures"
    "Téléchargements" = "$destinationPublic\Downloads"
}

# Vérifier si le chemin OneDrive existe
if (Test-Path $cheminOneDrive -PathType Container) {
    
    # Lister tous les sous-dossiers de OneDrive
    $dossiersOneDrive = Get-ChildItem -Path $cheminOneDrive -Directory

    foreach ($dossier in $dossiersOneDrive) {
        # Déterminer la destination appropriée
        if ($dossiersSpecifiques.ContainsKey($dossier.Name)) {
            # Si le dossier a une destination spécifique
            $destination = $dossiersSpecifiques[$dossier.Name]
        } else {
            # Sinon, copier dans le dossier Public directement
            $destination = Join-Path -Path $destinationPublic -ChildPath $dossier.Name
        }

        # Créer la destination si elle n'existe pas
        if (-not (Test-Path $destination)) {
            New-Item -Path $destination -ItemType Directory -Force
        }

        # Copier le contenu du dossier vers la destination appropriée
        Copy-Item -Path $dossier.FullName\* -Destination $destination -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Le dossier '$($dossier.Name)' a été copié dans '$destination'"
    }

    # Copier les fichiers situés à la racine de OneDrive vers le dossier Public\Documents
    $fichiersOneDrive = Get-ChildItem -Path $cheminOneDrive -File
    $destinationDocuments = "$destinationPublic\Documents"

    foreach ($fichier in $fichiersOneDrive) {
        # Créer la destination Documents si elle n'existe pas
        if (-not (Test-Path $destinationDocuments)) {
            New-Item -Path $destinationDocuments -ItemType Directory -Force
        }

        # Copier le fichier dans Documents
        $destination = Join-Path -Path $destinationDocuments -ChildPath $fichier.Name
        Copy-Item -Path $fichier.FullName -Destination $destination -Force -ErrorAction SilentlyContinue
        Write-Host "Le fichier '$($fichier.Name)' a été copié dans '$destination'"
    }

    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageOneDrive)

} else {
    Write-ProgressMessage $($Language.ProgressMessage.ProgressMessageOneDriveKO)
}

# ------------------------------------------
# Fin du script de sauvegarde
# ------------------------------------------

# Fermeture de la fenêtre de progression
$progressForm.Close()

$AllUserDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
$ico = "Restauration.ico"

New-Shortcut -TargetApplication "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -OutputDirectory $AllUserDesktop -Name $($Language.Path.RestoreShortcut) -Description $($Language.Path.RestoreShortcut_Description) -Arguments "-WindowStyle hidden -executionpolicy bypass -file $CurrentFolder\Restauration.ps1" -IconPath "$CurrentFolder\$Ico"
$excludeBackuplnk = Join-Path -Path $AllUserDesktop -ChildPath $($Language.Path.excludeBackuplnk)
if (Test-Path $excludeBackuplnk) {
    Remove-Item $excludeBackuplnk -Force
}
# Affichage de la boîte de dialogue de confirmation à la fin des opérations
[System.Windows.Forms.MessageBox]::Show($($Language.PopUp.Text), "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

# Afficher le fichier de résumé
& notepad.exe /A $resumeFilePath
