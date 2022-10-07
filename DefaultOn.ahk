#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include %A_ScriptDir%\Scripts
#Include Lib\DBT.ahk
#Include Scritch\Scritch.ahk

NotesApplication := ScritchGui(A_ScriptDir "\Resources\ScritchNotes", startHidden:=True)
Hotkey "<#v", (*)=> NotesApplication.ToggleGui()