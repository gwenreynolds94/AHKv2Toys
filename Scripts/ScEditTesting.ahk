#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include Lib\DBT.ahk
#Include Lib\SciConstants.ahk

sci_path := A_ScriptDir "\Lib\Scintilla.dll"
sci_ptr := DllCall("LoadLibrary", "Str", sci_path, "Ptr")
OnExit FreeScintilla
FreeScintilla(*) {
   DllCall("FreeLibrary", "Ptr", sci_ptr)
}





F8::ExitApp