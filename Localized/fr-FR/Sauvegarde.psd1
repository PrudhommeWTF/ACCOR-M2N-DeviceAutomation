@{
	Form = @{
		Title = 'Informations du Script de Sauvegarde'
		labelCenteredText = 'À N''EXÉCUTER QU''UNE SEULE FOIS PAR ORDINATEUR!!!!'
		Button = 'Lancer'
		progressFormText = 'Progression de la Sauvegarde'
		
	}
	
	RTF = @{
		Text = @"
{\rtf1\ansi

Ce logiciel effectuera les opérations suivantes:\par
\par
1. Copie de vos dossiers Bureau, Documents, Images, Vidéos, Téléchargements, Favoris, Contacts et Aitdesk (si présent) depuis votre profil utilisateur vers le dossier Public.\par
2. Récupération des favoris de Google Chrome et Microsoft Edge {\b\fs28 mais pas les mots de passe.}\par
3. Récupération de vos signatures d'email.\par
4. Récupération des entrées de saisie semi-automatique d'Outlook.\par
5. Récupération des informations des lecteurs réseau et des imprimantes réseau.\par
6. Récupération du dossier de la barre de lancement rapide.\par
7. Création d'un raccourci pour FOLS (si disponible).\par
8. Création d'un raccourci pour Outlook Web pour la boîte mail personnelle et les boîtes mails en délégation.\par
9. Copie de l'intégralité du dossier OneDrive dans le dossier Public.\par
\par
Les documents sauvegardés seront disponibles pour chaque nouvel utilisateur.\par
\par
 Cliquez sur 'lancer' pour démarrer la sauvegarde.\par
\par
{\b\fs18 PS: Pendant la sauvegarde, des doublons vont apparaître sur le bureau, ce qui est normal. Après connexion à votre nouveau compte, il ne restera qu'une seule copie de chaque fichier.}\par
\par
}
"@	
	}
	
	ProgressMessage = @{
		progressText = 'Progression: {0}%'
		ProgressMessageCopyFolder = 'Copie du dossier : {0}'
		ProgressMessageCopythrow = 'Robocopy a échoué avec le code de sortie {0}'
		ProgressMessageCopyError = 'Erreur durant la copie de {0} vers {1} : {2}'
		ProgressMessageCopySucces = 'Réussite de copie de {0} vers {1}'		
		ProgressMessageCopyFolderIgnore = 'Le dossier {0} n''existe pas et sera ignoré.'
		ProgressMessageChrome = 'Récupération des favoris de Chrome terminée.'
		ProgressMessageEdge = 'Récupération des favoris d''Edge terminée.'
		ProgressMessageSignature = 'Copie du dossier de signatures Outlook terminée.'
		ProgressMessageStream_Autocomplete = 'Le fichier {0} a été copié dans {1}'
		ProgressMessageStream_AutocompleteIgnore = 'Aucun fichier Stream_Autocomplete trouvé dans {0}'		
		ProgressMessageNetworkDrive = 'Récupération des informations des lecteurs réseau terminée.'
		ProgressMessageSavePrinters = 'L''imprimante {0} a été sauvée'
		ProgressMessagePrinters = 'Les informations des imprimantes réseau ont été sauvegardées avec succès dans le fichier: {0}'
		ProgressMessagePrintersError = 'Erreur lors de la sauvegarde des informations des imprimantes réseau : {0}'
		ProgressMessagePrintersEnd = 'Récupération des informations des imprimantes réseau terminée.'		
        ProgressMessageQuickLaunch = 'Le dossier de lancement rapide a été copié avec succès.'
        ProgressMessageQuickLaunchIgnore = 'Le dossier de lancement rapide n''a pas été trouvé dans {0}.'
		ProgressMessageMainOutlook = 'Le raccourci Outlook Principal a été créé avec succès sur le Bureau'
		ProgressMessageMainOutlookError = 'Erreur lors de la création du raccourci Outlook Principal : {0}'
		ProgressMessageUsersOutlook = 'Le raccourci Outlook pour {0} a été créé avec succès sur le Bureau'
		ProgressMessageUsersOutlookError = 'Erreur lors de la création du raccourci Outlook pour $username : {0}'
		ProgressMessageVariableFLS1Found = 'Variable trouvée : {0}'
		ProgressMessageVariableFLS1Value = 'Valeur de la variable : {0}'
		ProgressMessageURLBuilded = 'URL construite : {0}'
		ProgressMessageURLPath = 'Chemin du raccourci : {0}'
		ProgressMessageURLSuccess = 'Le raccourci internet a été créé avec succès à l''emplacement : {0}'
		ProgressMessageURLInfo = 'URL du raccourci : {0}'
		ProgressMessageURLError = 'Erreur lors de la création du raccourci : {0}'
		ProgressMessageURLOK = 'Le fichier raccourci existe.'
		ProgressMessageURLKO = 'Le fichier raccourci n''a pas été créé.'		
		ProgressMessageShortCutFols = 'Le raccourci Internet vers Fols a été créé avec succès à l''emplacement : {0}'
		ProgressMessageNOVAR = 'Aucune variable d''environnement contenant ''-fls1'' dans sa valeur n''a été trouvée.'
		ProgressMessageLISTVAR = 'Variables d''environnement pertinentes :'
		ProgressMessageVARNameValue = '{0} = {1}'
		ProgressMessageFolsNotFound = 'Impossible de trouver le nom du serveur FOLS.'
		ProgressMessageOneDrive = 'Copie du dossier OneDrive dans le dossier Public terminée.'
		ProgressMessageOneDriveKO = 'Le dossier OneDrive n''a pas été trouvé.'
		ProgressMessageDiskSpaceCheckStart = 'Vérification de l''espace disque sur le lecteur {0}...'
		ProgressMessageDiskSpaceInsufficient = 'Il manque {0} Go d''espace disque pour effectuer la sauvegarde.                    Veuillez prendre contact avec votre SPOC.'
		ProgressMessageDiskSpaceCheckError = 'Erreur lors de la vérification de l''espace disque sur le lecteur {0}. Vérifiez que le lecteur est disponible.'

    # Titres des fenêtres
    TitleDiskSpaceError = "Erreur de vérification d'espace disque"
	}

	Path = @{
		resumeFile = 'rapport_sauvegarde.txt'
		excludeBackuplnk = 'Sauvegarde_profil.lnk'
		excludeBackupexe = 'Backup_profile.exe'
		FavoritesChrome = 'Favoris Chrome'
		FavoritesEdge = 'Favoris Edge'
		SignatureOutlook = 'Signatures Outlook'
		Stream_Autocomplete = 'Saisie semi-auto Outlook'
		network = 'Réseau'
		FileNetWorkDrive = 'InformationsLecteursReseau.txt'
		FilePrinter = 'InformationsImprimantesReseau.txt'
		QuickLaunch = 'Quick Launch'
		OutlookPrincipal = 'Mail Personnel.lnk'
		OutlookPrincipal_Description = 'Raccourci vers Outlook Principal'
		OutlookDelegue = 'Mail_{0}.lnk'
		OutlookDelegue_Description = 'Raccourci vers Outlook pour {0}'
		RestoreShortcut = 'Restauration_profile.lnk'
		RestoreShortcut_Description = 'Lancement du script de restauration du profil'
	}
	
	PopUp = @{
		Text = 'Sauvegarde terminée.'	
	}	
}