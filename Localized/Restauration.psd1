@{
	Form = @{
		Title = 'Restoration Script Information'
		labelCenteredText = 'TO BE EXECUTED ONLY ONCE PER USER!!!!'
		Button = 'Launch'
		Button2 = 'Close'		
	}

	Dialog = @{
		msgLicenseDefault = 'Unable to verify Office license or Office client.'
		msgLicenseE3 = 'No compatible Outlook client with your license (extensionattribute6: ''E3'')'
		msgLicenseE1 = 'Your license is not compatible with the currently installed Outlook client (extensionattribute6: ''E1'')'
		msgLicenseMF1 = 'Your new account does not have a mailbox; no Outlook client configuration is needed (extensionattribute6: ''MF1'')'
		msgLicenseF3 = 'Your license is only compatible with Outlook Web, not the Outlook client (extensionattribute6: ''F3'')'
		StartProcess = 'Start of the restoration process'
		StartOutlook = 'Click OK to launch Outlook and please complete the setup.'
		StartOutlook_title = 'Information'
		StartOutlook2 = 'Follow Outlook instructions, then click OK.'
		StartOutlook2_title = 'Set Up Outlook'
		StartOutlook3 = 'When the first e-mails arrive, close Outlook and click OK.'
		StartOutlook3_title = 'Close Outlook'
		StopOutlook = 'Outlook has been closed. The script continues.'
		WaitOutlook = 'Waiting for Outlook to close... Time elapsed: {0} seconds'
		ErrorOutlook = 'Outlook did not close within the allotted time. The script continues.'
		AfterOutlook = 'The script continues...'
		StartNavigator = 'After clicking "OK", Chrome and Edge will open.'
		StartNavigator_title = 'Information'
		StopNavigator_title = 'Closing the browsers'
		StopNavigator = 'Make sure Chrome and Edge are open.Click OK to close.'
		CopyAITDESK = 'Copying AITDESK folder'
		CopyAITDESK_Status = 'In progress...'
		CopyAITDESK_Success = 'AITDESK folder successfully copied to {0}.'
		CopyAITDESK_Error = 'The AITDESK folder does not exist at {0}. The script continues without copying it.'
		CopyChrome_Success = 'Chrome Bookmarks file successfully copied.'
		CopyChrome_Error = 'The public Chrome Bookmarks file does not exist.'
		CopyEdge_Success = 'Edge Bookmarks file successfully copied.'
		CopyEdge_Error = 'The public Edge Bookmarks file does not exist.'
		NetworkDrive_Error = 'Error: Incorrect line format in the file {0}.'
		NetworkDrive_NotFound = 'Error: The file {0} cannot be found.'
		TryConnectPrinter = 'Attempting to connect the printer {0}...'
		PrinterConnected = 'The printer {0} has been connected.'
		DefaultPrinterOK = 'The printer {0} has been set as the default printer.'
		DefaultPrinterKO = 'The printer {0} is not found among the connected printers.'
		PrinterConnected_Error = 'Error connecting the printer {0}: {1}'
		PrinterBadRow = 'Malformatted line: {0}'
		RestorePrinterOK = 'Network printers have been successfully restored.'
		RestorePrinterKO = 'No network printers were found in the file.'
		RestorePrinterNotFound = 'The network printers information backup file could not be found.'
		SignaturesOK = 'The folder {0} has been successfully copied to {1}'
		SignaturesKO = 'The source folder {0} does not exist.'
		Stream_Autocomplete_NotFound = 'No Stream_Autocomplete file found in the folder {0}.'
		Stream_Autocomplete_NotFound2 = 'No Stream_Autocomplete file found in the current user''s RoamCache folder.'
		QuickLaunch_success = 'The Quick Launch folder has been successfully copied to {0}'
		QuickLaunch_success_NotFound = 'The source folder {0} does not exist.'
		OneDrive_Success = 'The shortcut to OneDrive - ACCOR has been created on the desktop.'
		OneDrive_AlreadyExist = 'The shortcut to OneDrive - ACCOR already exists on the desktop.'
		OneDrive_NotFound = 'The OneDrive - ACCOR folder does not exist at the specified location.'
		AitDesk = 'The program was successfully launched: {0}'
		Aitdesk_Success = 'The shortcut has been created on the desktop: $shortcutPath'
		Aitdesk_Error = 'Error creating the shortcut: $_'
		Aitdesk_NotFound = 'The program cannot be found at the specified location: {0}. The script continues.'
		End_Message = 'The restoration is complete. A summary file has been created on your desktop.'
		End_Title = 'Restoration Completed'
		End_Log = 'The user clicked OK in the restoration completion window.'
	}
	
	RTF = @{
		Text = @"
{\rtf1\ansi
\qc {\b\fs28 Program for French-speaking countries.}\par \pard\par
This software will perform the following operations:\par
1. It will launch the Outlook setup, please follow the on-screen instructions.\par
2. It will open the Chrome and Edge browsers to create the necessary subfolders to transfer your bookmarks.\par
3. It will display a message to close the browsers. Click OK when both browsers are open.\par
4. It will restore Chrome and Edge bookmarks.\par
5. It will create shortcuts to public folders in your own folders.\par
6. It will reconnect network drives (Forum and others).\par
7. It will reconnect network printers.\par
8. It will restore email signatures.\par
9. It will restore Outlook autocomplete.\par
10. It will restore the Quick Launch bar.\par
11. It will create a shortcut to OneDrive on the desktop.\par
12. It will replace the AitDesk folder in the user profile.\par
13. It will start the AccorDesktop software (if available).\par
14. It will create the AccorDesktop shortcut on the desktop (if existing). \par

\par \par
\qc {\b\fs28 Click 'Launch' to start the restoration.}\par \pard
}
"@
	}

	function = @{
		writeLogError = 'Error writing to the log file: {0}'
	}

	Step = @{
		Outlook = 'Step {0}/{1}: Launching Outlook'
		Browsers = 'Step {0}/{1}: Launching browsers'
		AITDESK = 'Step {0}/{1}: Configuration for AitDesk'
		Favorites = 'Step {0}/{1}: Restoring favorites'
		Shortcut = 'Step {0}/{1}: Setting up shortcuts'
		networkDrive = 'Step {0}/{1}: Restoring network drives'
		networkprinter = 'Step {0}/{1}: Restoring network printers'
		Signatures = 'Step {0}/{1}: Restoring signatures'
		Stream_Autocomplete = 'Step {0}/{1}: Restoring autocomplete entries'
		QuickLaunch = 'Step {0}/{1}: Restoring the quick launch bar'
		ShortcutOD = 'Step {0}/{1}: Setting up OneDrive shortcuts'
		LaunchAITDESK = 'Step {0}/{1}: Launching AitDesk'
		endoverlay = 'End'
	}
	
	Path = @{
		logFile = 'RestaurationLog.txt'
		FavoritesChrome = 'Chrome Favorites'
		FavoritesEdge = 'Edge Favorites'
		network = 'Network'
		FileNetWorkDrive = 'NetworkDriveInformation.txt'
		FilePrinter = 'NetworkPrintersInformation.txt'
		SignatureOutlook = 'Outlook Signatures'
		Stream_Autocomplete = 'Outlook Autocomplete'
		QuickLaunch = 'Quick Launch'
	}
	
}