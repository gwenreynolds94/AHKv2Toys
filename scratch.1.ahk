;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk

asd := {a:1,b:2,c:3,d:4}
qwe := &asd

stdo qwe, '--- --- --- ---', &qwe


F8::ExitApp