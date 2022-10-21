#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

tgui := Gui(,"Nothing")
tpb := tgui.Add("Picture")
tpb._size := {x:7, y:666}

stdo tpb._size.x, tpb._size.y

tgui.Destroy()

#Include <DBT>