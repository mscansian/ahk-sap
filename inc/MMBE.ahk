#Include inc/Base.ahk

;;; SCREEN TITLE ;;;
SCR_MMBE_Main  := "Bestandsübersicht: Buchungskreis/Werk/Lager/Charge"
SCR_MMBE_Basic := "Bestandsübersicht: Grundliste"

GetStock(Article, Plant, StorageLoc)
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
