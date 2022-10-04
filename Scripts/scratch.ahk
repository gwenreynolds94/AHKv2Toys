#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force
DetectHiddenWindows 1

somemap := Map("asd", 1, "dsfg", 2, "wer", 3)
FileAppend Format("{:s}{:s}{:s}", somemap*), "*"