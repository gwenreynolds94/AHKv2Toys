#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DEBUG\DBT.ahk

WatchForegroundWindowChange(force_unhook:=False) {
    static winhook := 0
    if winhook
        DllCall "UnhookWinEvent", "Ptr", winhook
    else if !force_unhook
        winhook := DllCall( "SetWinEventHook"
                          , "Int", 0x0003
                          , "Int", 0x0003
                          , "Ptr", 0
                          , "Ptr", CallbackCreate(OnForegroundWindowChange, "F")
                          , "Int", 0
                          , "Int", 0
                          , "Int", 0 )
}

OnForegroundWindowChange(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
    ; stdo "hWinEventHook:`n"
    ;      . "`t" hWinEventHook "`n"
    ;    . "event:`n"
    ;      . "`t" event "`n"
    ;    . "hwnd:`n"
    ;      . "`t" hwnd "`n"
    ;    . "idObject:`n"
    ;      . "`t" idObject "`n"
    ;    . "idChild:`n"
    ;      . "`t" idChild "`n"
    ;    . "idEventThread:`n"
    ;      . "`t" idEventThread "`n"
    ;    . "dwmsEventTime:`n"
    ;      . "`t" dwmsEventTime "`n`n"
    stdo "Foreground Window Changed: " hwnd
}

OnExit (*)=> WatchForegroundWindowChange(True)

F9::WatchForegroundWindowChange
F10::ExitApp