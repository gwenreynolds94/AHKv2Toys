#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>

((a)=>MsgBox(a)).Bind("hey").Call()