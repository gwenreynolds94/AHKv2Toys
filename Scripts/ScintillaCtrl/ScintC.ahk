#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib
#Include DBT.ahk
#Include ..\ScintillaConstantsScraper\ScintillaConstants.ahk


scint := DllCall("LoadLibrary", "Str", "SciLexer.dll", "Cdecl Int")


mainGui := Gui("+Resize", "Main Window")
scintctrl := mainGui.Add("Custom", "ClassScintilla w400 h500")
mainGui.Show()


SendMessage SCI_SETMULTIPLESELECTION, 1,, scintctrl, "ahk_id " mainGui.HWND
SendMessage SCI_SETADDITIONALSELECTIONTYPING, 1, 1, scintctrl, "ahk_id " mainGui.HWND
SendMessage SCI_SETMULTIPASTE, 1, 1, scintctrl, "ahk_id " mainGui.HWND

Sleep 2000
; 
; SendMessage 2573, 1, 5, scintctrl, "ahk_id " mainGui.HWND
; SendMessage 2573, 10, 15, scintctrl, "ahk_id " mainGui.HWND
; linelength := SendMessage(SCI_LINELENGTH,,, scintctrl, "ahk_id " mainGui.HWND)
; lineEnd := SendMessage(SCI_LINEEND,,, scintctrl, "ahk_id " mainGui.Hwnd)
; if MsgBox(linelength "`n" lineEnd
    ; ,, "t1")
    ; ExitApp