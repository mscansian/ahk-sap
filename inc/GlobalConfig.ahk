;;;;; GlobalConfig.ahk
;This fle include the global configurations needed for the macro to work. Please
;note that if you are using any transaction-specific file you also probably need
;to edit the configuration there
;
;NOTE: You definetely should edit the STATUS BAR coordinates and if you are 
;using SAP in any language other than German, you should edit the SCREEN TITLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STATUS BAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coordinates
;Please refer to the documentation to understand how to set these coordinates
CRD_StatusBar_X = 906
CRD_StatusBar_Y = 971

;; Colors
CLR_StatusBar_Normal  = 0xE7E7EF  ;Grey
CLR_StatusBar_Error   = 0xFF0000  ;Red
CLR_StatusBar_Warning = 0         ;Yellow
CLR_StatusBar_Ok      = 0x4AA518  ;Green

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SCREEN TITLE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default title are in German. Change this values if you are using SAP in another
;language

SCR_Main    := "SAP Easy Access"  ;Main screen
SCR_ERROR   := "Fehler"           ;Error screen
SCR_WARNING := "Warnung"          ;Warning screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SHORTCUTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default shortcuts of SAP. Change it if you are using custom shortcuts

HTK_ENTER          = {Enter}
HTK_EXECUTE        = {F8}
HTK_BACK           = {F3}
HTK_END            = +{F3}
HTK_CANCEL         = {F12}
HTK_SELECT         = {F9}
HTK_NEWTRANSACTION = ^{NumpadDiv}
HTK_NEXTFIELD      = {Tab}
HTK_PREVFIELD      = +{Tab}
