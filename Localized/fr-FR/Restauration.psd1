@{
	Form = @{
		Title = 'Informations du Script de Restauration'
		labelCenteredText = 'À N''EXÉCUTER QU''UNE SEULE FOIS PAR UTILISATEUR!!!!'
		Button = 'Lancer'
		Button2 = 'Fermer'
	}

	Dialog = @{
		msgLicenseDefault = 'Vérification de la licence Office ou du client Office impossible.'
		msgLicenseE3 = 'Aucun client outlook compatible avec votre licence (extensionattribute6 : ''E3'')'
		msgLicenseE1 = 'Votre licence n''est pas compatible avec le client outlook actuellement installé (extensionattribute6 : ''E1'')'
		msgLicenseMF1 = 'Votre nouveau compte n''a pas de boite mail pas de configuration du client Outlook nécessaire (extensionattribute6 : ''MF1'')'
		msgLicenseF3 = 'Votre licence n''est pas compatible avec le client Outlook mais uniquement Outlook Web (extensionattribute6 : ''F3'')'
		StartProcess = 'Début du processus de restauration'
		StartOutlook = 'Cliquez sur OK pour lancer Outlook et veuillez terminer la configuration.'
		StartOutlook_title = 'Information'
		StartOutlook2 = 'Suivez les instructions d''outlook, puis cliquez sur OK.'
		StartOutlook2_title = 'Configurer Outlook'
		StartOutlook3 = 'Une fois que les premiers courriels arrivent, fermez Outlook et cliquez sur OK.'
		StartOutlook3_title = 'Fermeture Outlook'
		StopOutlook = 'Outlook a été fermé. Le script continue.'
		WaitOutlook = 'En attente que Outlook se ferme... Temps écoulé : {0} secondes'
		ErrorOutlook = 'Outlook n''a pas été fermé dans le délai imparti. Le script continue.'
		AfterOutlook = 'Le script continue...'
		StartNavigator = 'Après avoir cliqué sur "OK", Chrome et Edge vont s''ouvrir.'
		StartNavigator_title = 'Information'
		StopNavigator_title = 'Fermeture des navigateurs'
		StopNavigator = 'Assurez-vous que Chrome et Edge sont ouverts.
Cliquez sur OK pour fermer.'
		CopyAITDESK = 'Copie du dossier AITDESK'
		CopyAITDESK_Status = 'En cours...'
		CopyAITDESK_Success = 'Dossier AITDESK copié avec succès vers {0}.'
		CopyAITDESK_Error = 'Le dossier AITDESK n''existe pas à {0}. Le script continue sans le copier.'
		CopyChrome_Success = 'Fichier Bookmarks de Chrome copié avec succès.'
		CopyChrome_Error = 'Le fichier Bookmarks de Chrome public n''existe pas.'
		CopyEdge_Success = 'Fichier Bookmarks d''Edge copié avec succès.'
		CopyEdge_Error = 'Le fichier Bookmarks d''Edge public n''existe pas.'
		NetworkDrive_Error = 'Erreur: Format de ligne incorrect dans le fichier {0}.'
		NetworkDrive_NotFound = 'Erreur: Le fichier {0} est introuvable.'
		TryConnectPrinter = 'Tentative de connexion de l''imprimante {0}...'
		PrinterConnected = 'L''imprimante {0} a été connectée.'
		DefaultPrinterOK = 'L''imprimante {0} a été définie comme imprimante par défaut.'
		DefaultPrinterKO = 'L''imprimante {0} n''est pas trouvée parmi les imprimantes connectées.'
		PrinterConnected_Error = 'Erreur lors de la connexion de l''imprimante {0} : {1}'
		PrinterBadRow = 'Ligne mal formatée : {0}'
		RestorePrinterOK = 'Les imprimantes réseau ont été restaurées avec succès.'
		RestorePrinterKO = 'Aucune imprimante réseau n''a été trouvée dans le fichier.'
		RestorePrinterNotFound = 'Le fichier de sauvegarde des informations des imprimantes réseau n''a pas été trouvé.'
		SignaturesOK = 'Le dossier {0} a été copié avec succès dans {1}'
		SignaturesKO = 'Le dossier source {0} n''existe pas.'
		Stream_Autocomplete_NotFound = 'Aucun fichier Stream_Autocomplete trouvé dans le dossier {0}.'
		Stream_Autocomplete_NotFound2 = 'Aucun fichier Stream_Autocomplete trouvé dans le dossier RoamCache de l''utilisateur actuel.'
		QuickLaunch_success = 'Le dossier Quick Launch a été copié avec succès dans {0}'
		QuickLaunch_success_NotFound = 'Le dossier source {0} n''existe pas.'
		OneDrive_Success = 'Le raccourci vers OneDrive - ACCOR a été créé sur le bureau.'
		OneDrive_AlreadyExist = 'Le raccourci vers OneDrive - ACCOR existe déjà sur le bureau.'
		OneDrive_NotFound = 'Le dossier OneDrive - ACCOR n''existe pas à l''emplacement spécifié.'
		AitDesk = 'Le programme a été lancé avec succès : {0}'
		Aitdesk_Success = 'Le raccourci a été créé sur le bureau : $shortcutPath'
		Aitdesk_Error = 'Erreur lors de la création du raccourci : $_'
		Aitdesk_NotFound = 'Le programme est introuvable à l''endroit indiqué : {0}. Le script continue.'
		End_Message = 'La restauration est terminée. Un fichier récapitulatif a été créé sur votre bureau'
		End_Title = 'Restauration terminée'
		End_Log = 'L''utilisateur a cliqué sur OK dans la fenêtre de fin de restauration.'
	}
	
	RTF = @{
		Text = @"
{\rtf1\ansi
\qc {\b\fs28 Programme destiné aux pays francophones.}\par \pard\par
Ce logiciel effectuera les opérations suivantes :\par
1. Lancera la configuration d’Outlook, veuillez suivre les instructions à l’écran.\par
2. Ouvrira les navigateurs Chrome et Edge pour créer les sous-dossiers nécessaires pour transférer vos favoris.\par
3. Affichera un message pour fermer les navigateurs. Cliquez sur OK quand les deux navigateurs seront ouverts.\par
4. Restaurera les favoris de Chrome et Edge.\par
5. Créera des raccourcis vers les dossiers publics dans vos propres dossiers.\par
6. Reconnectera les lecteurs réseau (Forum et autres).\par
7. Reconnectera les imprimantes réseau.\par
8. Restaurer les signatures d’e-mails.\par
9. Restaurer la saisie semi-automatique Outlook.\par
10. Restaurera la barre de lancement rapide (Quick Launch).\par
11. Créera un raccourci vers OneDrive sur le bureau.\par
12. Replacera le dossier AitDesk dans le profil utilisateur.\par
13. Démarrage du logiciel AccorDesktop (si disponible).\par
14. Création du raccourci AccorDesktop sur le bureau (si existant). \par

\par \par
\qc {\b\fs28 Cliquez sur 'Lancer' pour démarrer la restauration.}\par \pard
}
"@
	}

	function = @{
		writeLogError = 'Erreur lors de l''écriture dans le fichier log : {0}'
	}

	Step = @{
		Outlook = 'Step {0}/{1}: Lancement d''outlook'
		Browsers = 'Step {0}/{1}: Lancement des navigateurs'
		AITDESK = 'Step {0}/{1}: Configuration pour AitDesk'
		Favorites = 'Step {0}/{1}: Restauration des favoris'
		Shortcut = 'Step {0}/{1}: Mise en place des raccourcis'
		networkDrive = 'Step {0}/{1}: Restauration des lecteurs reseaux'
		networkprinter = 'Step {0}/{1}: Restauration des imprimantes reseaux'
		Signatures = 'Step {0}/{1}: Restauration des signatures'
		Stream_Autocomplete = 'Step {0}/{1}: Restauration des saisie semi-automatique'
		QuickLaunch = 'Step {0}/{1}: Restauration de la barre de lancement rapide'
		ShortcutOD = 'Step {0}/{1}: Mise en place des raccourcis OneDrive'
		LaunchAITDESK = 'Step {0}/{1}: Lancement d''AitDesk'
		endoverlay = 'Fin'
	}
	
	Path = @{
		logFile = 'RestaurationLog.txt'
		FavoritesChrome = 'Favoris Chrome'
		FavoritesEdge = 'Favoris Edge'
		network = 'Réseau'
		FileNetWorkDrive = 'InformationsLecteursReseau.txt'
		FilePrinter = 'InformationsImprimantesReseau.txt'
		SignatureOutlook = 'Signatures Outlook'
		Stream_Autocomplete = 'Saisie semi-auto Outlook'
		QuickLaunch = 'Quick Launch'
	}
	
}