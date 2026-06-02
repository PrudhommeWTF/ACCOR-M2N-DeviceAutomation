@{
    Form = @{
        Title = 'Backup Script Information'
        labelCenteredText = 'TO BE EXECUTED ONLY ONCE PER COMPUTER!!!!'
        Button = 'Start'
        progressFormText = 'Backup Progress'
    }
    
    RTF = @{
        Text = @"
{\rtf1\ansi

This software will perform the following operations:\par
\par
1. Copy your Desktop, Documents, Pictures, Videos, Downloads, Favorites, Contacts, and Aitdesk (if present) folders from your user profile to the Public folder.\par
2. Retrieve bookmarks from Google Chrome and Microsoft Edge {\b\fs28 but not passwords.}\par
3. Retrieve your email signatures.\par
4. Retrieve Outlook autocomplete entries.\par
5. Retrieve network drive and printer information.\par
6. Retrieve the Quick Launch folder.\par
7. Create a shortcut for FOLS (if available).\par
8. Create a shortcut for Outlook web for personal mailbox and delegated mailboxes.\par
9. Copy the entire OneDrive folder to the Public folder.\par
\par
The saved documents will be available for each new user.\par
\par
 Click 'Start' to begin the backup.\par
\par
{\b\fs18 PS: During the backup, duplicates will appear on the desktop, which is normal. After logging into your new account, only one copy of each file will remain.}\par
\par
}
"@
    }
    
    ProgressMessage = @{
        progressText = 'Progress: {0}%'
        ProgressMessageCopyFolder = 'Copying folder: {0}'
		ProgressMessageCopythrow = 'Robocopy failed with exit code {0}'
		ProgressMessageCopyError = 'Error copying {0} to {1} : {2}'
		ProgressMessageCopySucces = 'Successfully copied {0} to {1}'
        ProgressMessageCopyFolderIgnore = 'The folder {0} does not exist and will be ignored.'
        ProgressMessageChrome = 'Chrome bookmarks retrieval completed.'
        ProgressMessageEdge = 'Edge bookmarks retrieval completed.'
		ProgressMessageCopyFailed = 'An error occurred while copying the file : {0}.'
        ProgressMessageSignature = 'Outlook signature folder copy completed.'
        ProgressMessageStream_Autocomplete = 'The file {0} was copied to {1}'
        ProgressMessageStream_AutocompleteIgnore = 'No Stream_Autocomplete file found in {0}'		
        ProgressMessageNetworkDrive = 'Network drive information retrieval completed.'
		ProgressMessageSavePrinters = 'Printer {0} has been saved'
        ProgressMessagePrinters = 'Network printer information was successfully saved in the file: {0}'
        ProgressMessagePrintersError = 'Error saving network printer information: {0}'
        ProgressMessagePrintersEnd = 'Network printer information retrieval completed.'		
        ProgressMessageQuickLaunch = 'The Quick Launch folder was successfully copied.'
        ProgressMessageQuickLaunchIgnore = 'The Quick Launch folder was not found in {0}.'
        ProgressMessageMainOutlook = 'The Main Outlook shortcut was successfully created on the Desktop'
        ProgressMessageMainOutlookError = 'Error creating Main Outlook shortcut: {0}'
        ProgressMessageUsersOutlook = 'The Outlook shortcut for {0} was successfully created on the Desktop'
        ProgressMessageUsersOutlookError = 'Error creating Outlook shortcut for $username: {0}'
        ProgressMessageVariableFLS1Found = 'Variable found: {0}'
        ProgressMessageVariableFLS1Value = 'Variable value: {0}'
        ProgressMessageURLBuilded = 'URL built: {0}'
        ProgressMessageURLPath = 'Shortcut path: {0}'
        ProgressMessageURLSuccess = 'The internet shortcut was successfully created at: {0}'
        ProgressMessageURLInfo = 'Shortcut URL: {0}'
        ProgressMessageURLError = 'Error creating the shortcut: {0}'
        ProgressMessageURLOK = 'The shortcut file exists.'
        ProgressMessageURLKO = 'The shortcut file was not created.'
        ProgressMessageShortCutFols = 'The internet shortcut to Fols was successfully created at: {0}'
        ProgressMessageNOVAR = 'No environment variable containing ''-fls1'' in its value was found.'
        ProgressMessageLISTVAR = 'Relevant environment variables:'
		ProgressMessageVARNameValue = '{0} = {1}'		
        ProgressMessageFolsNotFound = 'Unable to find the FOLS server name.'
        ProgressMessageOneDrive = 'OneDrive folder copy to the Public folder completed.'
        ProgressMessageOneDriveKO = 'The OneDrive folder was not found.'
		ProgressMessageDiskSpaceCheckStart = 'Checking disk space on drive {0}...'
		ProgressMessageDiskSpaceInsufficient = 'There is {0} GB of disk space missing to perform the backup.                             Please contact your SPOC'
		ProgressMessageDiskSpaceCheckError = 'Error checking disk space on drive {0}. Please ensure the drive is available.'

    # Window titles
    TitleDiskSpaceError = 'Disk Space Check Error'
    }
 
	Path = @{
		resumeFile = 'backup_report.txt'
		excludeBackuplnk = 'Backup_profile.lnk'
		excludeBackupexe = 'Backup_profile.exe'
		FavoritesChrome = 'Chrome Favorites'
		FavoritesEdge = 'Edge Favorites'
		SignatureOutlook = 'Outlook Signatures'
		Stream_Autocomplete = 'Outlook Autocomplete'
		network = 'Network'
		FileNetWorkDrive = 'NetworkDriveInformation.txt'
		FilePrinter = 'NetworkPrintersInformation.txt'
		QuickLaunch = 'Quick Launch'
		OutlookPrincipal = 'Personal Mail.lnk'
		OutlookPrincipal_Description = 'Shortcut to Main Outlook'
		OutlookDelegue = 'Mail_{0}.lnk'
		OutlookDelegue_Description = 'Shortcut to Outlook for {0}'
		RestoreShortcut = 'Restore_profile.lnk'
		RestoreShortcut_Description = 'Launch profile restoration script'
	}

	
    PopUp = @{
        Text = 'Backup completed.'
    }
}
