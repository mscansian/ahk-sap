;;;;; example01.ahk
;Get the stock of the specified material

;Include transaction specific functions
#Include inc/MMBE.ahk

;Data to search
Material = 123456789
Plant    = 0000
Place    = 0000 

WinWaitActive, ahk_exe sapgui.exe                        ;Wait until SAP window is active
StockValue := SAP_MMBE_GetStock(Material, Plant, Place)  ;Get stock value
SAP_ReturnToMainScreen()                                 ;Return to the main screen
MsgBox The stock for this material is %StockValue%       ;Output
return                                                   ;Exit script
