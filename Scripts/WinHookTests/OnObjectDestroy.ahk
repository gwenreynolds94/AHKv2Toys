#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DEBUG\DBT.ahk

WatchObjectDestroy(force_unhook:=False) {
    static winhook := 0
    if winhook
        DllCall "UnhookWinEvent", "Ptr", winhook
    else if !force_unhook
        winhook := DllCall( "SetWinEventHook"
                          , "Int", 0x8001
                          , "Int", 0x8001
                          , "Ptr", 0
                          , "Ptr", CallbackCreate(OnObjectDestroy, "F")
                          , "Int", 0
                          , "Int", 0
                          , "Int", 0 )
}

OnObjectDestroy(hWinEventHook, event, hwnd, *) {
    if WinExist("ahk_id " hwnd)
        stdo "Window Destroyed: " WinGetTitle("ahk_id " hwnd)
}
OnExit (*)=> WatchObjectDestroy(True)

F9::WatchObjectDestroy
F10::ExitApp