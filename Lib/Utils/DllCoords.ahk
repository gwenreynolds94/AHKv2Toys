
/**
 * @return {Object} 
 * 
 *      ReturnObj := {
 *          x: 666,
 *          y: 666
 *      }
 */
DllMouseGetPos() {
    cPOINT := Buffer(8)
    DllCall "GetCursorPos", "Ptr", cPOINT
    Return {
        x: NumGet(cPOINT, 0, "Int"),
        y: NumGet(cPOINT, 4, "Int")
    }
}
/**
 * @param {Integer} [_mX]
 * @param {Integer} [_mY]
 */
DllMouseSetPos(_mX?, _mY?) {
    if !(IsSet(_mX) and IsSet(_mY))
        _ogPos := DllMouseGetPos()
    DllCall("SetCursorPos", "Int", _mX ?? _ogPos.x, "Int", _mY ?? _ogPos.y)
}
/**
 * @param {HWND} _wHwnd
 * @return {Object}
 * 
 *      ReturnObj := {
 *          x: 666,
 *          y: 666,
 *          w: 666,
 *          h: 666
 *      }
 */
DllWinGetRect(_wHwnd) {
    wRECT := Buffer(16)
    DllCall "GetWindowRect", "Ptr", _wHwnd, "Ptr", wRECT
    Return {
        x: (_x:=NumGet(wRECT,  0, "Int")),
        y: (_y:=NumGet(wRECT,  4, "Int")),
        w: NumGet(wRECT,  8, "Int")-_x,
        h: NumGet(wRECT, 12, "Int")-_y
    }
}
/**
 * Parameter formats 
 * 
 *      ; -<_wRECT>-  takes precedence over -<_wN>-
 *      ; -<X>- is ignored if -<Y>- is not defined, and vice versa
 *      ; -<W>- is ignored if -<H>- is not defined, and vice versa
 *      _wHwnd := 0x666666   ; HWND    
 *      _wRECT := { x: 666,  ; client X  [Optional] 
 *                  y: 666,  ; client Y  [Optional] 
 *                  w: 666,  ; Width     [Optional]
 *                  h: 666 } ; Height    [Optional]
 *      _wX := 666  ; client X  [Optional]
 *      _wY := 666  ; client Y  [Optional]
 *      _wW := 666  ; Width     [Optional]
 *      _wH := 666  ; Height    [Optional]
 * 
 * @param {HWND} _wHwnd
 * @param {Object} [_wRECT]
 * @param {Integer} [_wX]
 * @param {Integer} [_wY]
 * @param {Integer} [_wW]
 * @param {Integer} [_wH]
 */
DllWinSetRect(_wHwnd, _wRECT?, _wX?, _wY?, _wW?, _wH?) {
    Static SWP_NOZORDER     := 0x0004
        ,  SWP_NOMOVE       := 0x0002
        ,  SWP_NOSIZE       := 0x0001
    _flags := SWP_NOZORDER
    if (IsSet(_wRECT)) {
        _x := !!(_hasX:=_wRECT.HasOwnProp("x")) ? _wRECT.x : 0
        _y := !!(_hasY:=_wRECT.HasOwnProp("y")) ? _wRECT.y : 0
        _w := !!(_hasW:=_wRECT.HasOwnProp("w")) ? _wRECT.w : 0
        _h := !!(_hasH:=_wRECT.HasOwnProp("h")) ? _wRECT.h : 0
        if !(_hasX and _hasY)
            _flags |= SWP_NOMOVE
        if !(_hasW and _hasH)
            _flags |= SWP_NOSIZE
    } else {
        _x := _wX ?? 0
        _y := _wY ?? 0
        _w := _wW ?? 0
        _h := _wH ?? 0
        if !(IsSet(_wX) and IsSet(_wY))
            _flags |= SWP_NOMOVE
        if !(IsSet(_wW) and IsSet(_wH))
            _flags |= SWP_NOSIZE
    }
    DllCall "SetWindowPos"
        ; target hwnd
            , "Ptr", _wHwnd
        ; preceeding hwnd
            , "Int", HWND_TOP:=0
        ; client x & y
            , "Int",_x, "Int",_y
        ; client w & h
            , "Int",_w, "Int",_h
        ; flags (Ignore w, h, and preceeding hwnd)
            , "UInt", _flags
}
