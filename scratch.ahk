#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\DllCoords.ahk

tgui := Gui("+Resize")
tgui.Show("w400 h500 Center")
tgui.OnEvent("Close", (*)=>(ExitApp()))

OnMessage(0x1666, Catch666)

Catch666(wparam, lparam, msg, hwnd) {
    tooltip "0x1666: " wparam
    SetTimer (*)=>Tooltip(), -1000
}

; InitSizingHook(forceUnhook:=False) {
;     static hook := 0, this_pid := WinGetPID("ahk_id " tgui.Hwnd)
;     if (!!hook)
;         hook := DllCall("User32\UnhookWinEvent", "Ptr", hook)
;     else if (!forceUnhook) {
;         hook := DllCall("User32\SetWinEventHook"
;                       , "Int", EVENT_SYSTEM_MOVESIZESTART:=0x0000000A   ; Event ID --- range floor
;                       , "Int", EVENT_SYSTEM_MOVESIZEEND:=0x0000000B     ; Event ID --- range ceiling
;                       , "Ptr", 0
;                       , "Ptr", CallbackCreate(SizingHookWatcher, "F")
;                       , "Int", this_pid
;                       , "Int", 0
;                       , "Int", 0 )
;     }
; }
; SizingHookWatcher(hWinEventHook, Event, hWnd, ExtraParams*) {
;     Tooltip Event "`n" hWnd
;     SetTimer (*)=>Tooltip(), -1000
;     Return hWinEventHook
; }
;
; InitSizingHook()

F8::ExitApp
