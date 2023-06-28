#Include .\Gdip_Custom.ahk
#Include ..\Utils\QuikToast.ahk

; class GdipUnified {
;     static token := 0
;          , _started := false
;          , error_msg_timeout := 3000
;     
;     static Started {
;         get => this._started
;         set {
;         }
;     }
; 
;     static Startup() {
;         if not this.token
;             this.token := Gdip_Startup()
;         if not this.token
;             QuikToast "Gdip failed to start", "{GdipUnified.Startup}::Error", this.error_msg_timeout
;     }
; 
;     static Shutdown() {
;     }
; }

_ptoken := Gdip_Startup()

MsgBox _pToken "... " GdipCache.pToken

_ptoken := Gdip_Startup()

MsgBox _pToken "... " GdipCache.pToken

Gdip_Shutdown(_ptoken)

MsgBox _pToken "... " GdipCache.pToken
