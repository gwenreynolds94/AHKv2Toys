#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include %A_ScriptDir%\Scripts
#Include Lib\DBT.ahk
#Include Scritch\Scritch.ahk
#Include AutoFormatComments\FormatSingleLineComment.ahk

NotesApplication := ScritchGui(A_ScriptDir "\Resources\ScritchNotes", startHidden:=True)
Hotkey "<#v", (*)=> NotesApplication.ToggleGui()

HotIf (*)=> (
    WinActive("ahk_exe code.exe")
    or WinActive("ahk_exe VSCodium.exe")
    or WinActive("ahk_exe sublime_text.exe"))
Hotkey "<^+p", (*)=> FormatSingleLineComment()
Hotif

Hotkey "F7", (*)=> Reload()