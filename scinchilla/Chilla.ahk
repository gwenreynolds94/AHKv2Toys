#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\
#Include SciLib\SciConstants.ahk
#Include SciLib\OGSciLoad.ahk

#Include DEBUG\DBT.ahk

SCI_DLL_PATH := "..\Lib\SciLib\Scintilla.dll"
SciPtr := SciLoad(SCI_DLL_PATH)

if (SciPtr)
   OnExit (*)=> SciFree(SciPtr)
else MsgBox("Failed to load the necessary .dll"), ExitApp()

tgui := Gui("",,Scink())
tgui.OnEvent("Close","Gui_OnClose")
tsci := tgui.SciAdd({Visible:True})
tgui.Show("w" tsci.Options.w " h" tsci.Options.h)


SendMessage(0x1A, 0, StrPtr("Environment"),, "ahk_id " 0xFFFF)

Class Scink {
    Gui_OnClose(guiObj, *)=> (guiObj.Destroy(), ExitApp())
}

F8::ExitApp