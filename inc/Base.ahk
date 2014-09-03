;;;;;;;;;;;;;;;; SAP AUTOMATION LIB ;;;;;;;;;;;;;;;;;;;

;;; HOTKEYS DEFINITION ;;;
HTK_ENTER          = {Enter}
HTK_EXECUTE        = {F8}
HTK_BACK           = {F3}
HTK_END            = +{F3}
HTK_CANCEL         = {F12}
HTK_SELECT         = {F9}
HTK_NEWTRANSACTION = ^{NumpadDiv}
HTK_NEXTFIELD      = {Tab}
HTK_PREVFIELD      = +{Tab}

;;; SCREEN TITLE ;;;
SCR_Main := "SAP Easy Access -"
SCR_ERROR := "Fehler -"
SCR_WARNING := "Warnung "

;;; SCREEN COORDS ;;;
CRD_StatusBar_X = 906
CRD_StatusBar_Y = 971

;;; SCREEN COLOR ;;;
CLR_StatusBar_Normal  = 0xE7E7EF ;Gray
CLR_StatusBar_Error   = 0xFF0000 ;Red
CLR_StatusBar_Warning = 0        ;Yellow
CLR_StatusBar_Ok      = 0x4AA518 ;Green

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
		throw Exception("Error", -1)
	}
	else if (Color = CLR_StatusBar_Ok)
	{
		throw Exception("Ok", -1)
	}
	else
	{
		throw Exception("Unrecognized color: " Color, -1)
	}
}

;;;;; LOW LEVEL FUNCTIONS ;;;;;;;;

SAP_ClearSelectedField()
{
	Send {Home}+{End}{Del}
}

SAP_Write(String)
{
	Send {shift up}%String%{shift up}
}

SAP_GetWindowTitle(Size)
{
	WinGetTitle, WinTitle, A
	StringLeft, WinTitle, WinTitle, Size
	return WinTitle
}

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
