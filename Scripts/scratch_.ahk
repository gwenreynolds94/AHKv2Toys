#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
SetMouseDelay -1

#Include <DBT>

something := {x: "x", y: "y"}

somethingelse := something ?? "nothing"
somethingelse := something.HasProp("y") ? something.y : "nothingy"

stdo somethingelse