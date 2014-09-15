;;;;; MMBE.ahk
;Functions to work with the MMBE transaction

;Include basic SAP functions
#Include inc/Base.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONFIGURATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Screen Title
;Default title are in German. Change this values if you are using SAP in another
;language

SCR_MMBE_Main  := "^Bestandsübersicht: Buchungskreis/Werk/Lager/Charge" ;Main
SCR_MMBE_Basic := "^Bestandsübersicht: Grundliste"                      ;Basic data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SAP_MMBE_GetStock()
;Return a variable with the stock of the specified material
;Article = Material number
;Plant = Plant code
;StorageLoc = Storage Location
;
;NOTE: This function will check if the StorageLoc provided correspond to what 
;SAP shows.
;WARNING: If there is an error while selecting the article, this function will
;not throw an exception. Instead return a stock of zero.
SAP_MMBE_GetStock(Article, Plant, StorageLoc)
{
	global SCR_MMBE_Main, HTK_NEXTFIELD, HTK_EXECUTE, SCR_MMBE_Basic
	
	SAP_OpenTransaction("MMBE", SCR_MMBE_Main)
	SAP_ClearSelectedField() ;Delete any value already in the Material field
	
	;Write data and execute transaction
	SAP_Write(Article)
	Send %HTK_NEXTFIELD%
	SAP_Write(Plant)
	Send %HTK_NEXTFIELD%%HTK_NEXTFIELD%%HTK_NEXTFIELD%
	SAP_Write(StorageLoc)
	Send %HTK_EXECUTE%
	
	;Wait for the next page
	try
	{
		SAP_WaitForWindow(SCR_MMBE_Basic, true, 10000)
	}
	catch
	{
		;Unable to get stock. Probably there is nothing in SAP
		return 0
	}
	
	Send {TAB 8} ;Go to stock table
	Sleep 50 ;Improve reliability
	Send ^{Down} ;Go to last line
	
	;Check StorageLoc
	Entry := SAP_ClipboardCopy()
	StringLeft EntryStorageLoc, Entry, 4
	if (EntryStorageLoc = StorageLoc)
	{
		;Copy stock value
		Send {End}{Home}
		return SAP_ClipboardCopy()
	}
	else
	{
		;No stock
		return 0
	}
}
