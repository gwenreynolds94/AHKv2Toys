#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\
#Include SciLib\SciConstants.ahk
#Include SciLib\OGSciLoad.ahk

#Include DEBUG\DBT.ahk

SCI_DLL_PATH := "C:\Users\jonat\Documents\gitrepos\AHKv2Toys\Lib\SciLib\Scintilla.dll"
SciPtr := SciLoad(SCI_DLL_PATH)

if (SciPtr)
   OnExit (*)=> SciFree(SciPtr)
else MsgBox("Failed to load the necessary .dll"), ExitApp()

tgui := Gui()
tsci := tgui.SciAdd({Visible:True})
tgui.Show("w" tsci.Options.w " h" tsci.Options.h)

F8::ExitApp