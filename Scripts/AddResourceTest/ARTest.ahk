;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2.0-beta.10\AutoHotkey64.exe
;@Ahk2Exe-AddResource *14 BCB.ico, BCB
#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetWorkingDir A_ScriptDir

;@Ahk2Exe-IgnoreBegin
TraySetIcon "BCB.ico"
;@Ahk2Exe-IgnoreEnd

/*@Ahk2Exe-Keep
; hMod := DllCall("GetModuleHandle", "UPtr", 0, "Ptr")
; hRes := DllCall("FindResource", "UPtr", hMod, "Str", "BCB.ICO", "Ptr", 3, "Ptr")
; MsgBox hRes
; lRes := DllCall("LoadResource", "Ptr", hMod, "Ptr", hRes, "Ptr")
; MsgBox lRes
; rSize := DllCall("SizeofResource", "Ptr", hMod, "Ptr", lRes, "UInt")
; MsgBox rSize
; hIcon := DllCall("LoadImage", "Ptr", hMod, "Str", "BCB.ico", "UInt", 1, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
; MsgBox hIcon

hIcon := "HICON:" LoadPicture(A_ScriptDir "\ARTest.exe", "Icon6", &asd:=1)

msgbox hicon
Try {
    TraySetIcon hIcon
    MsgBox "Success"
} Catch Error as err {
    MsgBox "Failed: " err.Message
    ExitApp
}
*/


F8::ExitApp