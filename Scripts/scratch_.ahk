#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

SpV := ComObject("SAPI.SpVoice")
SVSFlagsAsync := 1
; SpV.Speak "Hello", 0
FileAppend SpV.IsUISupported("SPDUI_Tutorial"), "*"