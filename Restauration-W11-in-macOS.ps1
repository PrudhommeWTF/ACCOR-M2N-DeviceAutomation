#region Functions
function Write-Log {
	param(
		[Parameter(Mandatory=$true)]
		[string]$Message,
		
		[Parameter(Mandatory=$false)]
		[ValidateSet('INFO', 'WARNING', 'ERROR')]
		[string]$Level = 'INFO'
	)
	
	try {
		# Vérifier si le dossier parent existe pour le fichier log
		$logFolder = Split-Path $logFile
		if (-not (Test-Path $logFolder)) {
			New-Item -ItemType Directory -Path $logFolder | Out-Null
		}

		$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
		$logMessage = "[$timestamp] [$Level] $Message"
		Add-Content -Path $logFile -Value $logMessage -Encoding UTF8

		# Afficher également le message dans la console
		Write-Host $logMessage
	} catch {
		Write-Host $($Language.function.writeLogError -f $_) -ForegroundColor Red
	}
}
#endregion Functions

#region Init
#Force current folder location depending on the PowerShell context
if ($psISE) {
	#Running in PS ISE context
    $CurrentFolder = Split-Path -Path $psISE.CurrentFile.FullPath        
} else {
	#Not running in PS ISE context
    $CurrentFolder = $PSScriptRoot
}

#Application name
$ApplicationName = 'Restore-profiles-to-nominative'

#Application version
[Version]$Version = '1.1.5.0'

#Change overwrite culture depending on computer running the script
switch -Wildcard ((Get-Culture).Name) {
    'fr-*' {$OverwriteCulture = 'fr-FR' ;  break }
    'de-*' {$OverwriteCulture = 'de-DE' ;  break }
    'es-*' {$OverwriteCulture = 'es-ES' ;  break }
	Default {$OverwriteCulture = $((Get-Culture).Name) ;  break }
}

#Import Localized language depending on the overwrite culture
$Language = Import-LocalizedData -BaseDirectory (Join-Path -Path $CurrentFolder -ChildPath Localized) -UICulture $OverWriteCulture

#Others
$global:ValidateButton = $false
#endregion Init

#region Main

$INSTALLED = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$INSTALLED += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$AppList = $INSTALLED | Where-Object { $_.DisplayName -ne $null } | Select-Object -Property displayname -Unique

switch ($env:USERDOMAIN_ROAMINGPROFILE) {
	EUR {
		$AD = 'DC=eu,DC=accor,DC=net'
		$LdapSrv = 'LDAP://eu.accor.net'
		break
	}
	NAM {
		$AD = 'DC=na,DC=accor,DC=net'
		$LdapSrv = 'LDAP://na.accor.net'
		break
	}
	AA {
		$AD = 'DC=aa,DC=accor,DC=net'
		$LdapSrv = 'LDAP://aa.accor.net'
		break
	}
	AU {
		$AD = 'DC=au,DC=accor,DC=net'
		$LdapSrv = 'LDAP://au.accor.net'
		break
	}
	SA {
		$AD = 'DC=sa,DC=accor,DC=net'
		$LdapSrv = 'LDAP://sa.accor.net'
		break
	}
	ACCOR {
		$AD = 'DC=accor,DC=net'
		break
	}
	Default {
		$AD = 'Unknow'
	}
}

$UserName = [Environment]::UserName
$ADUser = New-Object DirectoryServices.DirectorySearcher
$ADUser.Filter = "(&(ObjectClass=User)(samAccountName=$UserName))"
$ADUser.SearchRoot = $ldapSrv
$UserObject = $ADUser.FindOne()
$UserAttrib = $UserObject.Properties.extensionattribute6
$UserAttrib = $UserAttrib -split ","

$global:office = $false
$global:msgLicense = $($Language.Dialog.msgLicenseDefault)

switch ($UserAttrib) {
    {$_.contains('E3HTL')}{
		$license = 'E3'
		$officeVer = 'Microsoft Office Standard|Microsoft Office LTSC Standard|Microsoft 365 apps'
			If($applist -match $officeVer){
				$global:office = $true
			}Else{
				$global:office = $false
				$global:msgLicense = $($Language.Dialog.msgLicenseE3)
			}
		break	
	}
		
    {$_.contains('E1HTL')}{
		$license = 'E1'
		$officeVer = 'Microsoft Office Standard|Microsoft Office LTSC Standard'
			If($applist -match $officeVer){
				$global:office = $true
			}Else{
				$global:office = $False
				$global:msgLicense = $($Language.Dialog.msgLicenseE1)
			}
		break	
	}
		
	{$_.contains('MF1')}{
		$global:license = 'MF1'
		$global:office = $False
		$global:msgLicense = $($Language.Dialog.msgLicenseMF1)
		break
	}
		
	{$_.contains('F3')}{
		$global:license = 'F3'
		$global:office = $False
		$global:msgLicense = $($Language.Dialog.msgLicenseF3)
		break
	}
}
	
$NumberStep = 13
$Step = 0
$dossierDesktop = "$env:USERPROFILE\Desktop"
$dossier_Public = 'C:\Users\Public'

# --------------------------------------------------------------------------------------------
# Affichage d'une boîte de dialogue personnalisée au début du script pour expliquer les étapes
# --------------------------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

try{
	[ProgressBarOverlay] | Out-Null
}
catch
{
	Add-Type -ReferencedAssemblies ('System.Windows.Forms', 'System.Drawing') -TypeDefinition  @' 
using System;
using System.Windows.Forms;
using System.Drawing;
namespace SAPIENTypes
{
	public class ProgressBarOverlay : System.Windows.Forms.ProgressBar
	{
		public ProgressBarOverlay() : base() { SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint, true); }
		protected override void WndProc(ref Message m)
		{ 
			base.WndProc(ref m);
			if (m.Msg == 0x000F)// WM_PAINT
			{
				if (Style != System.Windows.Forms.ProgressBarStyle.Marquee || !string.IsNullOrEmpty(this.Text))
				{
					using (Graphics g = this.CreateGraphics())
					{
						using (StringFormat stringFormat = new StringFormat(StringFormatFlags.NoWrap))
						{
							stringFormat.Alignment = StringAlignment.Center;
							stringFormat.LineAlignment = StringAlignment.Center;
							if (!string.IsNullOrEmpty(this.Text))
								g.DrawString(this.Text, this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
							else
							{
								int percent = (int)(((double)Value / (double)Maximum) * 100);
								g.DrawString(percent.ToString() + "%", this.Font, Brushes.Black, this.ClientRectangle, stringFormat);
							}
						}
					}
				}
			}
		}
		
		public string TextOverlay
		{
			get
			{
				return base.Text;
			}
			set
			{
				base.Text = value;
				Invalidate();
			}
		}
	}
}
'@ -IgnoreWarnings | Out-Null
}

$progressbaroverlay1 = New-Object 'SAPIENTypes.ProgressBarOverlay'

# Fenêtre d'informations principale
$form = New-Object Windows.Forms.Form
$form.Text = $($Language.Form.Title)
$form.Size = New-Object Drawing.Size(1024, 580)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'  # Fenêtre non redimensionnable
$form.BackColor = [System.Drawing.Color]::FromArgb(5, 0, 51)

# Label pour le titre
$labelCenteredText = New-Object Windows.Forms.Label
$labelCenteredText.Size = New-Object Drawing.Size(984, 40)
$labelCenteredText.Location = New-Object Drawing.Point(20, 20)
$labelCenteredText.Font = New-Object Drawing.Font('Arial', 14, [System.Drawing.FontStyle]::Bold)
$labelCenteredText.TextAlign = 'MiddleCenter'
$labelCenteredText.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$labelCenteredText.Text = $($Language.Form.labelCenteredText)
$form.Controls.Add($labelCenteredText)

# RichTextBox pour le texte principal
$richTextBox = New-Object Windows.Forms.RichTextBox
$richTextBox.Size = New-Object Drawing.Size(984, 360)
$richTextBox.Location = New-Object Drawing.Point(20, 70)
$richTextBox.Font = New-Object Drawing.Font('Arial', 10)
$richTextBox.Multiline = $true
$richTextBox.ReadOnly = $true
$richTextBox.ScrollBars = 'Vertical'
$richTextBox.Rtf = $($Language.RTF.text)
$form.Controls.Add($richTextBox)

# Créer un bouton OK centré horizontalement
$okButton = New-Object Windows.Forms.Button
$okButton.Size = New-Object Drawing.Size(100, 30)
$okButton.Left = ($form.Width - $okButton.Width) / 2
$okButton.Top = 500
$okButton.Text = $($Language.Form.Button)
$okButton.Visible = $true
$okButton.Enabled = $true

# Définir la couleur RGB pour le fond du bouton (par exemple, vert foncé)
$red = 255
$green = 255
$blue = 255
$buttonColor = [System.Drawing.Color]::FromArgb($red, $green, $blue)
$okButton.BackColor = $buttonColor

# Définir la police en gras pour le texte du bouton
$okButton.Font = New-Object Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Bold)

$okButton.Add_Click({
	$okButton.Enabled = $false
	# Définir le chemin du fichier de sortie
	$logFile = Join-Path -Path $dossierDesktop -ChildPath $($Language.Path.logFile)

	# Initialiser le fichier log
	if (Test-Path $logFile) {
		Remove-Item $logFile -Force
	}

	Write-Log $($Language.Dialog.StartProcess)

	#------------------------------------------------------------------------
	# Lancement du parametrage Outlook
	#------------------------------------------------------------------------
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	function Show-InformationDialog {
		param (
			[string]$message,
			[string]$title
		)

		$form = New-Object System.Windows.Forms.Form
		$form.Text = $title
		$form.Size = New-Object System.Drawing.Size(400, 150)
		$form.StartPosition = 'CenterScreen'

		$label = New-Object System.Windows.Forms.Label
		$label.Location = New-Object System.Drawing.Point(50, 20)
		$label.Size = New-Object System.Drawing.Size(300, 50)
		$label.Text = $message
		$form.Controls.Add($label)

		$button = New-Object System.Windows.Forms.Button
		$button.Location = New-Object System.Drawing.Point(150, 70)
		$button.Size = New-Object System.Drawing.Size(100, 30)
		$button.Text = 'OK'
		$button.Add_Click({
			$form.Close()
		})
		$form.Controls.Add($button)

		$form.Topmost = $True
		$form.ShowDialog() | Out-Null
	}

	# Première fenêtre d'information
	$progressbaroverlay1.Visible = $true
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.Outlook -f $Step,$NumberStep)

	if($office){
		Show-InformationDialog -message $($Language.Dialog.StartOutlook) -title $($Language.Dialog.StartOutlook_title)
		
		# Lancement d'Outlook
		Start-Process -FilePath 'outlook.exe'

		# Deuxième fenêtre d'information
		Show-InformationDialog -message $($Language.Dialog.StartOutlook2) -title $($Language.Dialog.StartOutlook2_title)

		# Troisième fenêtre d'information
		Show-InformationDialog -message $($Language.Dialog.StartOutlook3) -title $($Language.Dialog.StartOutlook3_title)

		# Délai d'attente maximum (en secondes)
		$maxWaitTime = 30  # 30 secondes
		$waitTimeElapsed = 0
		$waitInterval = 5  # Intervalle d'attente entre les vérifications (en secondes)

		$OutlookRunning = $false

		while ($waitTimeElapsed -lt $maxWaitTime) {
			# Vérifier si outlook.exe est en cours d'exécution
			$outlookProcess = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq 'outlook' }

			if (-not $outlookProcess) {
				Write-Log $($Language.Dialog.StopOutlook)
				$OutlookRunning = $true
				break
			} else {
				Write-Log $($Language.Dialog.WaitOutlook -f $waitTimeElapsed)
				Start-Sleep -Seconds $waitInterval  # Attendre avant de vérifier à nouveau
				$waitTimeElapsed += $waitInterval
			}
		}

		if (-not $OutlookRunning) {
			Write-Log $($Language.Dialog.ErrorOutlook)
		}else{
			# Exemple : Afficher un message indiquant la continuation du script
			Write-Log $($Language.Dialog.AfterOutlook)
		}
	}else{
		Show-InformationDialog -message $msgLicense -title $($Language.Dialog.StartOutlook_title)
	}
	
	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1;

	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.Browsers -f $Step,$NumberStep)
	Show-InformationDialog -message $($Language.Dialog.StartNavigator) -title $($Language.Dialog.StartNavigator_title)

	#---------------------------------------------------------
	# Lancement des navigateurs
	#---------------------------------------------------------
	Start-Process chrome
	Start-Process msedge

	#---------------------------------------------------------
	# Affichage de la fenêtre de fermeture des navigateurs
	#---------------------------------------------------------
	Start-Sleep -Seconds 3;
	Show-InformationDialog -message $($Language.Dialog.StopNavigator) -title $($Language.Dialog.StopNavigator_title)

	Stop-Process -Name 'chrome' -Force
	Stop-Process -Name 'msedge' -Force

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1;

	#---------------------------------------------------------
	# AITDESK
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.AITDESK -f $Step,$NumberStep)

	# Chemin de la source AITDESK dans le dossier Public
	$sourceAitDesk = Join-Path -Path $dossier_Public -ChildPath 'AITDESK'

	# Chemin de destination dans le profil de l'utilisateur actuellement connecté
	$destinationAitDesk = "$env:USERPROFILE\AITDESK"

	# Vérifier si le dossier AITDESK existe dans le dossier Public
	if (Test-Path -Path $sourceAitDesk -PathType Container) {
		# Copier le dossier AITDESK vers le profil de l'utilisateur actuel
		Write-Progress -Activity $($Language.Dialog.CopyAITDESK) -Status $($Language.Dialog.CopyAITDESK_Status)
		Copy-Item -Path $sourceAitDesk -Destination $destinationAitDesk -Recurse -Force -ErrorAction SilentlyContinue
		Write-Log $($Language.Dialog.CopyAITDESK_Success -f $destinationAitDesk)
	} else {
		Write-Log $($Language.Dialog.CopyAITDESK_Error -f $sourceAitDesk)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1;

	#---------------------------------------------------------
	# Copies des favoris Chrome et Edge
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.favorites -f $Step,$NumberStep)

	$cheminBookmarksChromePublic = Join-Path -Path $dossier_Public -ChildPath "$($Language.Path.FavoritesChrome)\Bookmarks"
	$cheminBookmarksEdgePublic = Join-Path -Path $dossier_Public -ChildPath "$($Language.Path.FavoritesEdge)\Bookmarks"

	if (Test-Path $cheminBookmarksChromePublic -PathType Leaf) {
		$cheminBookmarksChromeDestination = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
		Copy-Item -Path $cheminBookmarksChromePublic -Destination $cheminBookmarksChromeDestination -Force
		Write-Log $($Language.Dialog.CopyChrome_Success)
	} else {
		Write-Log $($Language.Dialog.CopyChrome_Error)
	}

	if (Test-Path $cheminBookmarksEdgePublic -PathType Leaf) {
		$cheminBookmarksEdgeDestination = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"
		Copy-Item -Path $cheminBookmarksEdgePublic -Destination $cheminBookmarksEdgeDestination -Force
		Write-Log $($Language.Dialog.CopyEdge_Success)
	} else {
		Write-Log $($Language.Dialog.CopyEdge_Error)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1;

	#---------------------------------------------------------
	# Création des raccourcis
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.shortcut -f $Step,$NumberStep)

	$dossiers = @{
		'Documents' = 'Documents'
		'Contacts' = 'Contacts'
		'Links' = 'Links'
		'Videos' = 'Videos'
		'Music' = 'Music'
		'Favorites' = 'Favorites'
		'Pictures' = 'Pictures'
		'Downloads' = 'Downloads'
	}

	foreach ($dossier in $dossiers.Keys) {
		$dossierUtilisateur = "$env:USERPROFILE\$dossier"
		
		if (-not (Test-Path $dossierUtilisateur)) {
			New-Item -ItemType Directory -Path $dossierUtilisateur | Out-Null
		}

		$dossierPublic = "$env:PUBLIC\$($dossiers[$dossier])"

		$raccourci = "$dossierUtilisateur\$($dossiers[$dossier]).lnk"
		if (-not (Test-Path $raccourci)) {
			$WshShell = New-Object -ComObject WScript.Shell
			$raccourciObjet = $WshShell.CreateShortcut($raccourci)
			$raccourciObjet.TargetPath = $dossierPublic
			$raccourciObjet.Save()
		}
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Connexion des lecteurs réseau
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.networkDrive -f $Step,$NumberStep)

	# Chemin du fichier contenant les informations des lecteurs réseau
	$NetworkFolder = Join-Path -Path $dossier_Public -ChildPath $($Language.Path.network)
	$fichierInfoLecteursReseau = Join-Path -Path $NetworkFolder -ChildPath $($Language.Path.FileNetWorkDrive)

	# Vérifie si le fichier des informations des lecteurs réseau existe
	if (Test-Path $fichierInfoLecteursReseau) {
		# Obtient le contenu du fichier
		$contenuFichier = Get-Content $fichierInfoLecteursReseau

		# Parcourt chaque ligne du fichier
		foreach ($ligne in $contenuFichier) {
			# Vérifie si la ligne n'est pas vide
			if (-not [string]::IsNullOrWhiteSpace($ligne)) {
				# Divise la ligne en éléments séparés par une tabulation (\t)
				$infosLecteur = $ligne -split '\t'

				# Vérifie si la ligne divisée contient au moins 2 éléments (lettre du lecteur et chemin réseau)
				if ($infosLecteur.Count -eq 2) {
					$lettreLecteur = $infosLecteur[0].Trim().Replace(':','')
					$cheminReseau = $infosLecteur[1].Trim()

					# Connexion du lecteur réseau avec net use
					try {
						New-PSDrive -Name $lettreLecteur -PSProvider FileSystem -Root $cheminReseau -Persist
					}
					catch {
						Write-Log $_
					}
				} else {
					Write-Log $($Language.Dialog.NetworkDrive_Error -f $($Language.Path.FileNetWorkDrive))
				}
			}
		}
	} else {
		Write-Log $($Language.Dialog.NetworkDrive_NotFound -f $($Language.Path.FileNetWorkDrive))
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Connexion des imprimantes
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.networkprinter -f $Step,$NumberStep)

	$fichierImprimantes = Join-Path -Path $NetworkFolder -ChildPath $($Language.Path.FilePrinter)

	if (Test-Path $fichierImprimantes -PathType Leaf) {
		$infosImprimantes = Get-Content $fichierImprimantes
		$imprimantesConnectees = 0

		foreach ($ligne in $infosImprimantes) {
			# Filtrer les lignes qui correspondent au format imprimante réseau
			if ($ligne -match '^\\\\[^\\]+\\[^\\]+;yes|no$') {
				# Splitting the line using ';' as a delimiter
				$imprimanteInfos = $ligne -split ';'
				if ($imprimanteInfos.Count -eq 2 -and $imprimanteInfos[0].StartsWith("\\")) {
					$nomImprimante = $imprimanteInfos[0].Trim()
					$estParDefaut = $imprimanteInfos[1].Trim() -eq "yes"

					Write-Host $($Language.Dialog.TryConnectPrinter -f $nomImprimante)
					# Connexion de l'imprimante réseau
					try {
						Add-Printer -ConnectionName $nomImprimante -ErrorAction SilentlyContinue
						$imprimantesConnectees++
						Write-Host $($Language.Dialog.PrinterConnected -f $nomImprimante)

						# Si c'est l'imprimante par défaut, la définir comme telle sans utiliser le registre
						if ($estParDefaut) {
							# Récupérer la liste des imprimantes installées
							$printers = Get-Printer

							# Trouver l'objet d'imprimante correspondant
							$printer = $printers | Where-Object { $_.Name -eq $nomImprimante }

							if ($printer) {
								# Définir l'imprimante par défaut en utilisant le cmdlet Set-Printer

								(Get-CimInstance -ClassName CIM_Printer | Where-Object {$_.Name -eq $nomImprimante}[0])| Invoke-CimMethod -MethodName SetDefaultPrinter | Out-Null
								Write-Host $($Language.Dialog.DefaultPrinterOK -f $nomImprimante)
							} else {
								Write-Warning $($Language.Dialog.DefaultPrinterKO -f $nomImprimante)
							}
						}
					} catch {
						Write-Warning $($Language.Dialog.PrinterConnected_Error -f $nomImprimante,$_)
					}
				}
			} else {
				Write-Warning $($Language.Dialog.PrinterBadRow -f $ligne)
			}
		}

		if ($imprimantesConnectees -gt 0) {
			Write-Host $($Language.Dialog.RestorePrinterOK)
		} else {
			Write-Warning $($Language.Dialog.RestorePrinterKO)
		}
	} else {
		Write-Warning $($Language.Dialog.RestorePrinterNotFound)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Copie des signatures d'e-mails
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.Signatures -f $Step,$NumberStep)

	$username = $env:USERNAME
	$sourcePath = "C:\Users\Public\Signatures Outlook\Signatures"
	$destinationPath = "C:\Users\$username\AppData\Roaming\Microsoft\Signatures"

	if (Test-Path $sourcePath -PathType Container) {
    	if (-not (Test-Path $destinationPath -PathType Container)) {
    	    New-Item -ItemType Directory -Path $destinationPath | Out-Null
    	}

    	# Copier uniquement le contenu du dossier source sans recréer le sous-dossier 'Signatures'
    	Copy-Item "$sourcePath\*" $destinationPath -Recurse -Force
    	Write-Log $($Language.Dialog.SignaturesOK -f $sourcePath, $destinationPath)
	} else {
    	Write-Log $($Language.Dialog.SignaturesKO -f $sourcePath)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1


	#---------------------------------------------------------
	# Restauration de la saisie semi-automatique Outlook
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.Stream_Autocomplete -f $Step,$NumberStep)

	$sourcePath = Join-Path -Path $dossier_Public -ChildPath $($Language.Path.Stream_Autocomplete)
	$destinationPath = "C:\Users\$username\AppData\Local\Microsoft\Outlook\RoamCache"

	$existingFile = Get-ChildItem -Path $destinationPath -Filter "Stream_Autocomplete*.dat" -ErrorAction SilentlyContinue | Select-Object -First 1

	if ($existingFile) {
		$renamedFileName = "$($existingFile.Name)-"
		Rename-Item -Path $existingFile.FullName -NewName $renamedFileName -Force

		$copiedFile = Get-ChildItem -Path $sourcePath -Filter "Stream_Autocomplete*.dat" | Select-Object -First 1
		
		if ($copiedFile) {
			Copy-Item -Path $copiedFile.FullName -Destination $destinationPath -Force
			Rename-Item -Path (Join-Path -Path $destinationPath -ChildPath $copiedFile.Name) -NewName $existingFile.Name -Force
		} else {
			Write-Log $($Language.Dialog.Stream_Autocomplete_NotFound -f $($Language.Path.Stream_Autocomplete))
		}
	} else {
		Write-Log $($Language.Dialog.Stream_Autocomplete_NotFound2)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Restauration du fichier TermReg.ini
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = "Restauration TermReg.ini ($Step/$NumberStep)"

	$sourceTermReg = Join-Path -Path $dossier_Public -ChildPath "TermReg.ini"
	$destinationTermReg = "C:\Users\$username\AppData\Local\TermReg.ini"

	if (Test-Path $sourceTermReg -PathType Leaf) {
		try {
			# Copie du fichier TermReg.ini vers le dossier AppData\Local de l'utilisateur
			Copy-Item -Path $sourceTermReg -Destination $destinationTermReg -Force -ErrorAction Stop
			Write-Log "Fichier TermReg.ini restauré avec succès vers $destinationTermReg"
		} catch {
			$ErrorMsg = "$_"
			Write-Log "Erreur lors de la restauration du fichier TermReg.ini : $ErrorMsg"
		}
	} else {
		Write-Log "Fichier TermReg.ini non trouvé dans $sourceTermReg"
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Copie de Quick Launch
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.QuickLaunch -f $Step,$NumberStep)

	$sourcePath = Join-Path -Path $dossier_Public -ChildPath $($Language.Path.QuickLaunch)
	$destinationPath = "C:\Users\$username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"

	if (Test-Path $sourcePath -PathType Container) {
		if (-not (Test-Path $destinationPath -PathType Container)) {
			New-Item -ItemType Directory -Path $destinationPath | Out-Null
		}

		Copy-Item $sourcePath\* $destinationPath -Recurse -Force
		Write-Log $($Language.Dialog.QuickLaunch_success -f $destinationPath)
	} else {
		Write-Log $($Language.Dialog.QuickLaunch_success_NotFound -f $sourcePath)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#---------------------------------------------------------
	# Ajout du raccourci vers OneDrive - ACCOR sur le bureau
	#---------------------------------------------------------
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.ShortcutOD -f $Step,$NumberStep)

	$dossierOneDrivePublic = "C:\Users\Public\OneDrive - ACCOR"
	$raccourciOneDrive = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop\OneDrive - ACCOR.lnk")

	if (Test-Path $dossierOneDrivePublic -PathType Container) {
		if (-not (Test-Path $raccourciOneDrive)) {
			$WshShell = New-Object -ComObject WScript.Shell
			$raccourciObjet = $WshShell.CreateShortcut($raccourciOneDrive)
			$raccourciObjet.TargetPath = $dossierOneDrivePublic
			$raccourciObjet.Save()

			Write-Log $($Language.Dialog.OneDrive_Success)
		} else {
			Write-Log $($Language.Dialog.OneDrive_AlreadyExist)
		}
	} else {
		Write-Log $($Language.Dialog.OneDrive_NotFound)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	# Section: Lancement Accor DESKTOP
	$Step++
	$progressbaroverlay1.TextOverlay = $($Language.Step.LaunchAITDESK -f $Step,$NumberStep)

	# Chemin vers le programme à lancer
	$programPath = "C:\Program Files\AitDesk\Aitdesk.exe"

	# Lancer le programme s'il est présent et créer le raccourci
	if (Test-Path $programPath -PathType Leaf) {
		Start-Process -FilePath $programPath -ErrorAction Stop
		Write-Log $($Language.Dialog.AitDesk -f $programPath)

		# Chemin du raccourci sur le bureau
		$desktop = [System.Environment]::GetFolderPath('Desktop')
		$shortcutPath = Join-Path -Path $desktop -ChildPath "Aitdesk.lnk"

		try {
			# Création de l'objet COM pour le raccourci
			$wshShell = New-Object -ComObject WScript.Shell
			$shortcut = $wshShell.CreateShortcut($shortcutPath)

			# Définir les propriétés du raccourci
			$shortcut.TargetPath = $programPath
			$shortcut.WorkingDirectory = "C:\Program Files\AitDesk"
			$shortcut.WindowStyle = 1
			$shortcut.IconLocation = "$programPath, 0"
			$shortcut.Save()

			Write-Log $($Language.Dialog.Aitdesk_Success -f $shortcutPath)
		} catch {
			Write-Log $($Language.Dialog.Aitdesk_Error -f $_)
		}
	} else {
		Write-Log $($Language.Dialog.Aitdesk_NotFound -f $programPath)
	}

	$progressbaroverlay1.PerformStep()
	Start-Sleep -Seconds 1

	#------------------------------------------------
	# Affichage de la fenêtre de fin de restauration
	#------------------------------------------------
	
	$progressbaroverlay1.PerformStep()
	$progressbaroverlay1.TextOverlay = $($Language.Step.endoverlay)
	Start-Sleep -Seconds 1

	Show-InformationDialog -message $($Language.Dialog.End_Message) -title $($Language.Dialog.End_Title)
	Write-Log $($Language.Dialog.End_Log)

	# Section de nettoyage et de réencodage de la transcription
	<# try {
		# Arrêter l'enregistrement de la transcription
		Stop-Transcript
		Write-Log "Transcription arrêtée avec succès."

		# Réencodage en UTF-8 sans BOM si le fichier existe
		if (Test-Path -Path $logFile) {
			Write-Log "Réencodage en UTF-8 sans BOM du fichier de log en cours..."

			# Lire le contenu actuel du fichier
			$content = Get-Content -Path $logFile -Raw

			# Réécrire le fichier en UTF-8 sans BOM
			[System.IO.File]::WriteAllText($logFile, $content, [System.Text.Encoding]::UTF8)

			Write-Log "Réencodage du fichier de log terminé."
		} else {
			Write-Log "Le fichier de log n'existe pas pour le réencodage."
		}
	} catch {
		Write-Log "Erreur lors de l'arrêt de la transcription ou du réencodage du fichier: $_" -Level "ERROR"
	}
	 #>
	 
	 $okButton.Visible = $False
	 $CloseButton.Visible = $true
	 $CloseButton.Enabled = $true
})

$form.Controls.Add($okButton)

# Créer un bouton OK centré horizontalement
$CloseButton = New-Object Windows.Forms.Button
$CloseButton.Size = New-Object Drawing.Size(100, 30)
$CloseButton.Left = ($form.Width - $CloseButton.Width) / 2
$CloseButton.Top = 500
$CloseButton.Text = $($Language.Form.Button2)
$CloseButton.Visible = $False
$CloseButton.Enabled = $false

# Définir la couleur RGB pour le fond du bouton (par exemple, vert foncé)
$red = 255
$green = 255
$blue = 255
$buttonColor = [System.Drawing.Color]::FromArgb($red, $green, $blue)
$CloseButton.BackColor = $buttonColor

# Définir la police en gras pour le texte du bouton
$CloseButton.Font = New-Object Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

$CloseButton.Add_Click({
	$form.Close()
})

$form.Controls.Add($CloseButton)

# Progressbar
$progressbaroverlay1.Size = '400, 30'
$progressbaroverlay1.Left = ($form.Width - $progressbaroverlay1.Width) / 2
$progressbaroverlay1.Top = 450
$progressbaroverlay1.Name = 'progressbaroverlay1'
$progressbaroverlay1.Maximum = $NumberStep
$progressbaroverlay1.Step = 1
$progressbaroverlay1.Value = 0
$progressbaroverlay1.Visible = $False

$form.Controls.Add($progressbaroverlay1)

$form.Topmost = $false
$form.ShowDialog() | Out-Null