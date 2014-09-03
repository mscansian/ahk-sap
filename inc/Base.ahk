;;;;; Base.ahk
;This file contains all basic functions to access the SAP GUI.You should include
;it whenever you are writing a new script.
;
;NOTE: All transaction-specific files (eg. MMBE.ahk) already include this file

;Include all the global configurations of SAP
;If this is your first time using this lib, REMEMBER TO EDIT GlobalConfig.ahk TO
;SUIT YOUR NEEDS
#Include inc/GlobalConfig.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SAP FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The functions below are used to access some basic functionalities of SAP GUI

;; SAP_ReturnToMainScreen()
;Cancel all transactions and return to SAP main screen
SAP_ReturnToMainScreen()
{
	global HTK_BACK, SCR_Main
	
	Loop
	{
		SAP_StatusBarMessage() ;Check for statusbar errors
		
		WinTitle := SAP_GetWindowTitle(StrLen(SCR_Main))
		if (WinTitle = SCR_Main)
		{
			break
		}
		Send %HTK_BACK%
		Sleep 300
	}
}

;; SAP_OpenTransaction()
;Returns to main screen and then start the specified transaction
;TransactionName = Name of the transaction (eg. MM03)
;WindowTitle = Window title of the transaction (if empty, the function will not
;check for a matching window title
SAP_OpenTransaction(TransactionName, WindowTitle:="")
{
	global HTK_NEWTRANSACTION, HTK_ENTER, SCR_Main
	
	SAP_ReturnToMainScreen()
	
	Send %HTK_NEWTRANSACTION%
	SAP_Write(TransactionName)
	Send %HTK_ENTER%
	
	if (WindowTitle = "")
	{
		;Wait until we are out of main screen
		Loop
		{
			SAP_StatusBarMessage() ;Check for statusbar errors
			
			WinTitle := SAP_GetWindowTitle(StrLen(SCR_Main))
			if (WinTitle <> SCR_Main)
			{
				break
			}
		}
	}
	else
	{
		SAP_WaitForWindow(WindowTitle, false, 10000)
	}
}

;; SAP_WaitForWindow()
;Wait until the specified window is open
;WindowTitle = Title of the window to wait
;IgnoreWarning = If true, this function will just ignore any warning and 
;proceed. If false, it will throw an exception when a warning occours
;Timeout = Timeout in milliseconds. When timeout is reached, the function will
;throw an exception. A value of zero means no timeout.
;NOTE: If an SAP error is found, this function will throw an exception.
SAP_WaitForWindow(WindowTitle, IgnoreWarning:= false, Timeout:=0)
{
	global SCR_ERROR, SCR_WARNING, HTK_ENTER

	StartTime := A_TickCount
	Loop
	{
		SAP_StatusBarMessage() ;Check for statusbar errors
		
		if (SAP_GetWindowTitle(StrLen(WindowTitle)) = WindowTitle)
		{
			break
		}
		else if (SAP_GetWindowTitle(StrLen(SCR_ERROR)) = SCR_ERROR)
		{
			throw Exception("Error", -1)
		}
		else if (SAP_GetWindowTitle(StrLen(SCR_WARNING)) = SCR_WARNING)
		{
			if IgnoreWarning
			{
				Send %HTK_ENTER%
				Sleep 1000
			}
			else
			{
				throw Exception("Warning", -1)
			}
		}
		else if ((A_TickCount - StartTime) > Timeout) AND (Timeout > 0)
		{
			throw Exception("Timeout", -1)
		}
	}
}

;; SAP_SelectionSelect()
;Select an option from the Options Selection screen.
;OptionNumber = Number of the option to be selected (starts on zero)
;OptionName = Name of the option to be select. If provided, this function will
;check if OptionNumber corresponds to OptionName. If not it will search for the
;correct OptionNumber. If OptionName is blank, this function will select 
;OptionNumber without any name verification.
SAP_SelectionSelect(OptionNumber, OptionName:="")
{
	global HTK_SELECT, HTK_ENTER

	Send {Down %OptionNumber%}
	
	;Check if name is right
	if (OptionName <> "")
	{
		Send {Home}+{End}
		SelectedOption := SAP_ClipboardCopy()
		
		if (SelectedOption <> OptionName)
		{
			;Search for the correct option
			Send ^{Home}
			Sleep 10
			
			Loop
			{
				Send {Home}
				Sleep 10
				Send +{End}
				SelectedOption := SAP_ClipboardCopy()
				
				if (SelectedOption = OptionName)
				{
					break
				}
				else if (SelectedOption = LastSelectedOption)
				{
					throw Exception("Unable to find option", -1)
				}
				
				LastSelectedOption := SelectedOption
				Send {Down}
			}
		}
	}
	
	Send %HTK_SELECT%
	Sleep 10
	Send %HTK_ENTER%
}

;; SAP_StatusBarMessage()
;Check for error/warning messages in the status bar
;This function will throw an exception everytime an error or warning if found in
;the status bar.
;For this function to work, the variables CRD_StatusBar_X and CRD_StatusBar_Y 
;must be correctly set in inc/GlobalConfig.ahk
SAP_StatusBarMessage()
{
	global CRD_StatusBar_X, CRD_StatusBar_Y, CLR_StatusBar_Normal, CLR_StatusBar_Error, CLR_StatusBar_Ok
	
	PixelGetColor, Color, %CRD_StatusBar_X%, %CRD_StatusBar_Y%, RGB
	if (Color = CLR_StatusBar_Normal)
	{
		return
	}
	else if (Color = CLR_StatusBar_Error)
	{
		Error := "Red"
	}
	else if (Color = CLR_StatusBar_Ok)
	{
		Error := "Green"
	}
	else
	{
		Error := "Unrecognized color: " Color
	}
	
	;Wait until status bar is clear
	Loop
	{
		try
		{
			SAP_StatusBarMessage()
			break
		}
	}
	
	throw Exception(%Error%, -1)
}

;; SAP_ClearSelectedField()
;Delete all text of the current selected field
SAP_ClearSelectedField()
{
	Send {Home}+{End}{Del}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MISC FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The functions below are not related to SAP, but are used extensively in the 
;functions above


;; SAP_Write()
;Write the string provided into the selected field
;String = String to write
SAP_Write(String)
{
	Send {shift up}%String%{shift up}
}

;; SAP_GetWindowTitle()
;Get the name of the current window
;Size = Number of characters (from left) to return
SAP_GetWindowTitle(Size)
{
	WinGetTitle, WinTitle, A
	StringLeft, WinTitle, WinTitle, Size
	return WinTitle
}

;; SAP_ClipboardCopy()
;Return the contects of the selection as if it was copied to the clipboard
;Timeout = Timeout to try to copy the information to the clipboard in seconds
;NOTE: The idea of this function is to copy the contents fo the selection 
;without changing the current value of the clipboard
SAP_ClipboardCopy(Timeout:=1)
{
	Send {shift up}
	OldClipboard := clipboard
	clipboard =
	Send ^c
	
	if Timeout > 0
	{
		ClipWait, %Timeout%
	}
	
	NewClipboard := clipboard
	clipboard := OldClipboard
	return NewClipboard
}
