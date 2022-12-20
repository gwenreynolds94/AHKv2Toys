;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\DllCoords.ahk


FileInstall("C:\Users\jonat\Documents\gitrepos\AHKv2Toys\Lib\SciLib\Scintilla.dll", ".\Scintilla.dll")


F8::ExitApp
