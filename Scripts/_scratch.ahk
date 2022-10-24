#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>


On_LWinC_Down(ThisHotkey) {
    Hotkey("*c", (*)=>""), Hotkey("LWin", (*)=>"")
    shortPress:=KeyWait("c", "T0.75")
    if shortPress
        stdo "<T>"
    else stdo "<T--- >"
    While (GetKeyState("c") or GetKeyState("LWin")) {
        Sleep 25
    } Hotkey("*c", "Off"), Hotkey("LWin", "Off")
}
Hotkey "<#c", On_LWinC_Down

FuncOne(*) {

}
FuncTwo(*) {

}
Class ClassOne {
    __New(_argOne) {
        this.instanceVarOne := _argOne
    }
    CFuncOne(_,*) {
        Return this.instanceVarOne
    }
}
NewFunc:=ObjBindMethod(ClassOne("WONN"), "CFuncOne")
stdo NewFunc.Name

F8::ExitApp