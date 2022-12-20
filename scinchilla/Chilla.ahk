#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\
#Include SciLib\SciConstants.ahk
#Include SciLib\CustomSciLoad.ahk

#Include DEBUG\DBT.ahk

SCI_DLL_PATH := "..\Lib\SciLib\Scintilla.dll"
SciPtrs := SciLoad(SCI_DLL_PATH)

if (SciPtrs.sci or SciPtrs.lex)
   OnExit (*)=> SciFree(SciPtrs)
if !(SciPtrs.sci and SciPtrs.lex)
    MsgBox("Failed to load the necessary .dll"), ExitApp()

Class ScinChilla {
    Static __New() {
        this.gui := Gui("","", this)
        this.gui.MarginY := this.gui.MarginX := 0
        this.edit := this.gui.SciAdd("x0 y0 w500 h500")

        this.gui.OnEvent("Close", "Gui_Close")

        this.gui.Show("Center")
    }
    Static Gui_Close(*) {
        this.gui.Hide()
        ExitApp()
    }
}


F8::ExitApp