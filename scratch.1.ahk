;@Ahk2Exe-Base C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk
#Include Utils\DllCoords.ahk

Persistent()

dbgo !




False

; dbgo Map
; dbgo RegExReplace(mapres, "m)(^(.\|(.{3})))")


F8::ExitApp
