#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

HwndFromPoint( &_x:=0, &_y:=0, _simple:=True, _debug:=False ) {
    _POINT := Buffer(8)

    if (_x=0) or (_y=0)
        DllCall("GetCursorPos", "Ptr", _POINT)
        , _x := NumGet(_POINT, 0, "Int"), _y := NumGet(_POINT, 4, "Int")
    else NumPut("Int", _x, "Int", _y, _POINT, 0)

    _pt := NumGet(_POINT, 0, "Int64")
    if !WinGetTitle("ahk_id " (_wHwnd:=DllCall("WindowFromPoint","Int64",_pt)))
        _wHwnd := DllCall("GetAncestor", "UInt", _wHwnd, "UInt", 2)

    if _simple && !_debug
        Return _wHwnd

    _tipDur := (IsNumber(_debug)&&(_debug!=0)) ? Abs(_debug)*-1 : -1000

    if !_simple {
        _out       := {}
        _out.Title := WinGetTitle(_idStr:=("ahk_id " _wHwnd))
        _out.PName := WinGetProcessName(_idStr)
        _out.Class := WinGetClass(_idStr)
        _out.Text  :=  WinGetText(_idStr)
        _out.PID   :=   WinGetPID(_idStr)
        if _debug
            ToolTip("hwnd:`n  " _wHwnd
               . "`ntitle:`n  " _out.Title
               . "`nclass:`n  " _out.Class
               .  "`ntext:`n  " _out.Text
               . "`nPName:`n  " _out.PName
               .   "`nPID:`n  " _out.PID), SetTimer((*)=>ToolTip(), _tipDur)
        Return _out
    }

    if _debug
        ToolTip(_wHwnd), SetTimer((*)=>ToolTip(), _tipDur)
    Return _wHwnd
}

if (A_ScriptName="_scratch.ahk") {
    ~LCtrl & Space::ToolTip(HwndFromPoint()), SetTimer((*)=>ToolTip(), -1000)
    HotIf (*)=> GetKeyState("LCtrl")
    ~LShift & Space::ExitApp
    HotIf
}

#Include ..\Lib\DEBUG\DBT.ahk