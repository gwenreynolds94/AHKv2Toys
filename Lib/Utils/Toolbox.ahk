;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, MsgBox
#SingleInstance Force

#Include ..\DEBUG\DBT.ahk

;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Try Primitives ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
TryString(_AsString, _returnLiteral := True) {
    Try {
        if _returnLiteral
            Return { Valid: True, Value: String(_AsString) }
        else Return String(_AsString)
    } Catch {
        if _returnLiteral
            Return { Valid: False, Value: False }
        else Return False
    }
}
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
TryInt(_AsInt, _returnLiteral := True) {
    Try {
        if _returnLiteral
            Return { Valid: True, Value: Integer(_AsInt) }
        else Return Integer(_AsInt)
    } Catch {
        if _returnLiteral
            Return { Valid: False, Value: False }
        else Return False
    }
}
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: Simplify Tooltip ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
; Tooltip.On := {
;     Call: (_this, _daddy, _msg:="", _dur:=False) => (
;         Tooltip(_msg),
;         (!!_dur and IsInteger(_dur)) ? (SetTimer((*)=>Tooltip(), _dur), True) : False
;     )
; }
; **
; * @param {Object} _this
; * @param {String} _msg
; * @param {Integer} _dur
; */
; ToolTip_On(_this, _msg := "", _dur := False) {
;    Tooltip(_msg)
;    if (!!_dur and IsInteger(_dur))
;        Return (SetTimer((*) => Tooltip(), _dur), True)
;    Return False
; 
; **
; * @param {Object} _this
; * @param {String} _msg
; * @param {Integer} _dur
; */
; oolTip.On := _ToolTip_On
;  ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ooltip.Off := (_this, _delay := 1000) => (SetTimer((*) => Tooltip(), _delay))
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;


Tooltip.On := (  (_this, _msg := "", _dur := False) => 
                                (   Tooltip(_msg),
                                    (!!_dur and IsInteger(_dur)) ? 
                                    (SetTimer((*) => Tooltip(), _dur), True) : False   )  )
Tooltip.Off := (  (_this, _delay:=1000) => (SetTimer((*) => Tooltip(), _delay))  )
; Tooltip.OwnProps := _Tooltip.OwnProps

; dbgo Tooltip, _Tooltip

; Tooltip.On("Hello", 1000)
; Sleep 1500
; Tooltip.On("HeyAgain")
; ToolTip.Off(1000)
; Sleep 1500
; ExitApp()

; Run "C:\Windows\System32\SystemPropertiesAdvanced.exe"
; WinWaitActive("System Properties",, 5)
; ControlClick("Button7", "System Properties")

