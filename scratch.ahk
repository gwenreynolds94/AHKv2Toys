#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include Lib\
#Include DEBUG\DBT.ahk

Tooltip.On := {
    Call: (_this, _daddy, _msg := "", _dur := False) => (
        Tooltip(_msg),
        (!!_dur and IsInteger(_dur)) ? (SetTimer((*) => Tooltip(), _dur), True) : False
            )
}
Tooltip.Off := {
    Call: (_this, _daddy, _delay := 1000) => (SetTimer((*) => Tooltip(), _delay))
}

F8:: ExitApp