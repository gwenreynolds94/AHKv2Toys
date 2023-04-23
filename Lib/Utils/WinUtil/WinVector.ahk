#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

if A_LineFile = A_ScriptFullPath {
    MsgBox "A_LineFile = A_ScriptFullPath"
}

;     /**
;      * @typedef {Object} RawCoords
;      * @property {Number} RawCoords.x
;      * @property {Number} RawCoords.y
;      * @property {Number} RawCoords.w
;      * @property {Number} RawCoords.h
;      */

;     /**
;      * @class
;      * @property {RawCoords} defaults
;      * @property {Number} x
;      * @property {Number} y
;      * @property {Number} w
;      * @property {Number} h
;      */

; /**
;  * @class
;  * @typedef {Object} WinVector
;  * @property {Object} WinVector.Coordinates
;  * @property {RawCoords} WinVector.Coordinates.defaults
;  * @property {Number} WinVector.Coordinates.x
;  * @property {Number} WinVector.Coordinates.y
;  * @property {Number} WinVector.Coordinates.w
;  * @property {Number} WinVector.Coordinates.h
;  */


Class WinVector {


    Static  Unit := { w: 30, h: 20 }

    /**
     * TODO - Easy access for own static methods
     *
     * I would like to come up with a less manual solution for accessing a class's
     * own static methods. Eventually at least
     */

    Static _MgnWinRect => WinVector.DLLUtil.GetWindowMarginsRect
    Static _VisWinRect => WinVector.DLLUtil.GetWindowVisibleRect
    Static _MsPosDll => winvector.DLLUtil.DllMouseGetPos

    ; Static ActiveCoord {
    ;     Get {
    ;         WinGetPos &_x, &_y, &_w, &_h, "ahk_id " WinExist("A")
    ;         Return WinVector.Coord(_x, _y, _w, _h)
    ;     }
    ; }

    Static ActiveCoord => (
        WinGetPos(&_x, &_y, &_w, &_h),
        WinVector.Coord(_x, _y, _w, _h)
    )

    Static MonitorWithWindow[_wHwnd?] => (WinGetPos(&_wX,,&_wW,,"ahk_id" (_wHwnd ?? WinExist("A"))), (_wX + _wW > A_ScreenWidth)) ? 2 : 1

;     Static ScrWidth[_monitor := 1] => (_monitor = 1) ? (A_ScreenWidth) : (MonitorGetWorkArea(_monitor, &_wX, , &_wR), (_wR - _wX))
;
;     Static ScrHeight[_monitor := 1] => (_monitor = 1) ? (A_ScreenHeight) : (MonitorGetWorkArea(_monitor, , &_wT , &_wB), (_wB - _wT))

    Static ScrWidth(_monitor := 1) {
        if (_monitor = 1)
            return (A_ScreenWidth)
        MonitorGetWorkArea(_monitor, &_wX, , &_wR)
        return (_wR - _wX)
    }

    Static ScrHeight(_monitor := 1) {
        if (_monitor = 1)
            return (A_ScreenHeight)
        MonitorGetWorkArea(_monitor, , &_wT, , &_wB)
        return (_wB - _wT)
    }

    Class Coordinates {

        Class Vectors {
            Static xmin := { x: (-1), y: 0    },
                   xadd := { x: 1   , y: 0    },
                   ymin := { x: 0   , y: (-1) },
                   yadd := { x: 0   , y: 1    },
                   wmin := { w: (-1), h: 0    },
                   wadd := { w: 1   , h: 0    },
                   hmin := { w: 0   , h: (-1) },
                   hadd := { w: 0   , h: 1    }
        }

        defaults := {
            x:0,
            y:0,
            w:0,
            h:0
        }
        x:=0, y:=0, w:=0, h:=0

        __New(x:=0,y:=0,w:=0,h:=0) {
            this.defaults.x := this.x := x
            this.defaults.y := this.y := y
            this.defaults.w := this.w := w
            this.defaults.h := this.h := h
        }

        Reset(x:="_", y:="_", w:="_", h:="_") {
            this.x := IsNumber(x) ? x : this.defaults.x
            this.y := IsNumber(y) ? y : this.defaults.y
            this.w := IsNumber(w) ? w : this.defaults.w
            this.h := IsNumber(h) ? h : this.defaults.h
            return this
        }

        Flat[append_args*] => [this.x, this.y, this.w, this.h, append_args*]

        /**
         * @param {wVector.Coordinates} coords1
         * @param {wVector.Coordinates} coords2
         * @param {"left"|"right"|"raw"|"new"} store_results
         * @returns {wVector.Coordinates}
         */
        Static Mul(&coords1, &coords2, store_results:=False) {
            /** @var {wVector.Coordinates} new_coords */
            new_coords := (store_results ~= "left")  ? coords1 :
                          (store_results ~= "right") ? coords2 :
                          (store_results ~= "new")   ? WinVector.Coordinates() :
                                                      { x: 0, y: 0, w: 0, h: 0 }
            for _i, _v in (['x','y','w','h'])
                new_coords.%_v% := coords1.%_v% * coords2.%_v%
            return new_coords
        }

        /**
         * @param {wVector.Coordinates} coords
         * @param {True|False|"raw"|"new"}
         * @returns {wVector.Coordinates}
         */
        Mul(&coords, store_results:=True) {
            return WinVector.Coordinates.Mul(
                    &this,
                    &coords,
                    (Type(store_results) = "string") ?
                                       store_results :
                                       store_results ?
                                        "left" : "new"
                )
        }

        /**
         * @param {wVector.Coordinates} coords1
         * @param {wVector.Coordinates} coords2
         * @param {"left"|"right"|"raw"|"new"} store_results
         * @returns {wVector.Coordinates}
         */
        Static Add(&coords1, &coords2, store_results:=False) {
            new_coords := (store_results ~= "left")  ? coords1 :
                          (store_results ~= "right") ? coords2 :
                          (store_results ~= "new")   ? WinVector.Coordinates() :
                                                      { x: 0, y: 0, w: 0, h: 0 }
            for _i, _v in (['x','y','w','h'])
                new_coords.%_v% := coords1.%_v% + coords2.%_v%
            return new_coords
        }

        /**
         * @param {wVector.Coordinates} coords
         * @param {True|False|"raw"|"new"}
         * @returns {wVector.Coordinates}
         */
        Add(&coords, store_results:=True) {
            return WinVector.Coordinates.Add(
                    &this, &coords, (Type(store_results) = "string") ? store_results :
                                                    store_results ? "left" : "new"
                )
        }
    }

    Class Directions {
               /** @prop {WinVector.Coord} Left */
        Static Left := 0
               /** @prop {WinVector.Coord} Right */
             , Right := 0
               /** @prop {WinVector.Coord} Up */
             , Up := 0
               /** @prop {WinVector.Coord} Down */
             , Down := 0

        Static __New() {
            this.Left  := WinVector.Coord((-1), 0, 0, 0)
            this.Right := WinVector.Coord(1, 0, 0, 0)
            this.Up    := WinVector.Coord(0, (-1), 0, 0)
            this.Down  := WinVector.Coord(0, 1, 0, 0)
        }
    }

    Class Coord {

        Class Min extends WinVector.Coord {
            ; ...
        }
        Class Max extends WinVector.Coord {
            ; ...
        }

        x   := 0,
        y   := 0,
        w   := 0,
        h   := 0,
        min := {x:0,y:0,w:0,h:0},
        max := {x:0,y:0,w:0,h:0}

        __New(x:=0, y?, w?, h?, _min?, _max?) {
            if String((y ?? 'f') (w ?? 'f') (h ?? 'f')) ~= 'f'
                y := w := h := x
            this.x := x
            this.y := y
            this.w := w
            this.h := h
            this.min := _min ?? {x:(-666666), y:(-666666), w:(-666666), h:(-666666)}
            this.max := _max ?? {x:666666, y:666666, w:666666, h:666666}
        }

        Static Left  => WinVector.Coord((-1), 0, 0, 0)
        Static Right => WinVector.Coord(1, 0, 0, 0)
        Static Up    => WinVector.Coord(0, (-1), 0, 0)
        Static Down  => WinVector.Coord(0, 1, 0, 0)
        Static Thin  => WinVector.Coord(0, 0, (-1), 0)
        Static Wide  => WinVector.Coord(0, 0, 1, 0)
        Static Short => WinVector.Coord(0, 0, 0, (-1))
        Static Tall  => WinVector.Coord(0, 0, 0, 1)

        /** @param {WinVector.Coord|Object} _xywh_target */
        Static Contain(&_xywh_target, _xywh_min?, _xywh_max?) {
            if not (IsSet(_xywh_min) and IsSet(_xywh_max))
                if _xywh_target is WinVector.Coord
                    _xywh_min := _xywh_target.min,
                    _xywh_max := _xywh_target.max
                else return _xywh_target
            _min := _xywh_min, _max := _xywh_max

        }

        Static Add(&_xywh_target, _xywh_mod) {
            _t := _xywh_target
            _m := _xywh_mod
            if IsNumber(_m)
                _m := { x:_m, y:_m, w:_m, h:_m }
            _t.x += _m.x, _t.y += _m.y
            _t.w += _m.w, _t.h += _m.h
            return _t
        }

        Static Sub(&_xywh_target, _xywh_mod) {
            _t := _xywh_target
            _m := _xywh_mod
            if IsNumber(_m)
                _m := { x:_m, y:_m, w:_m, h:_m }
            _t.x -= _m.x, _t.y -= _m.y
            _t.w -= _m.w, _t.h -= _m.h
            return _t
        }

        Static Mul(&_xywh_target, _xywh_mod) {
            _t := _xywh_target
            _m := _xywh_mod
            if IsNumber(_m)
                _m := { x:_m, y:_m, w:_m, h:_m }
            _t.x *= _m.x, _t.y *= _m.y
            _t.w *= _m.w, _t.h *= _m.h
            return _t
        }

        Static Div(&_xywh_target, _xywh_mod) {
            _t := _xywh_target
            _m := _xywh_mod
            if IsNumber(_m)
                _m := { x:_m, y:_m, w:_m, h:_m }
            _t.x /= _m.x, _t.y /= _m.y
            _t.w /= _m.w, _t.h /= _m.h
            return _t
        }

        Add(xywh) {
            return WinVector.Coord.Add(&this, xywh)
        }

        Sub(xywh) {
            return WinVector.Coord.Sub(&this, xywh)
        }

        Div(xywh) {
            return WinVector.Coord.Div(&this, xywh)
        }

        Mul(xywh) {
            return WinVector.Coord.Mul(&this, xywh)
        }

    }

    class DLLUtil {

        Static GetWindowMarginsRect(&win, wHwnd) {
            win := {}
            newWinRect := Buffer(16)
            DllCall("GetWindowRect", "Ptr", wHwnd, "Ptr", newWinRect.Ptr)|
            win.x := NumGet(newWinRect,  0, "Int")
            win.y := NumGet(newWinRect,  4, "Int")
            win.w := NumGet(newWinRect,  8, "Int")
            win.h := NumGet(newWinRect, 12, "Int")
        }

        Static GetWindowVisibleRect(&frame, wHwnd) {
            DWMWA_EXTENDED_FRAME_BOUNDS := 9
            newFrameRect := Buffer(16)
            rectSize := 16
            frame := {}
            DllCall("Dwmapi.dll\DwmGetWindowAttribute"
                  , "Ptr" , wHwnd
                  , "Uint", DWMWA_EXTENDED_FRAME_BOUNDS
                  , "Ptr" , newFrameRect.Ptr
                  , "Uint", rectSize)
            frame.x := NumGet(newFrameRect,  0, "Int")
            frame.y := NumGet(newFrameRect,  4, "Int")
            frame.w := NumGet(newFrameRect,  8, "Int")
            frame.h := NumGet(newFrameRect, 12, "Int")
        }

        Static SuperficialCoordsFromReal(&outCoords, wHwnd) {
            WinGetPos(&wX, &wY, &wW, &wH, "ahk_id " wHwnd)
            WinVector._MgnWinRect( &win , wHwnd )
            WinVector._VisWinRect( &frame, wHwnd )
            offSetLeft   := frame.x - win.x
            offSetRight  := win.w - frame.w
            offSetBottom := win.h - frame.h
            outCoords    := {}
            outCoords.y  := wY
            outCoords.x  := wX + offSetLeft
            outCoords.h  := wH - offSetBottom
            outCoords.w  := wW - (offSetRight * 2)
            return outCoords
        }

        Static RealCoordsFromSuperficial(&outCoords, wHwnd, wX, wY, wW, wH) {
            WinVector._MgnWinRect( &win , wHwnd )
            WinVector._VisWinRect( &frame, wHwnd )
            offSetLeft   := frame.x - win.x
            offSetRight  := win.w - frame.w
            offSetBottom := win.h - frame.h
            outCoords    := {}
            outCoords.y  := wY
            outCoords.x  := wX - offSetLeft
            outCoords.h  := wH + offSetBottom
            outCoords.w  := wW + (offSetRight * 2)
            return outCoords
        }

        /*e
         *      ReturnObj := {
         *          x: 666,
         *          y: 666
         *      }
         */
        Static DllMouseGetPos() {
            cPOINT := Buffer(8)
            DllCall "GetCursorPos", "Ptr", cPOINT
            return {
                x: NumGet(cPOINT, 0, "Int"),
                y: NumGet(cPOINT, 4, "Int")
            }
        }


        /**
         * @param {Integer} [_mX]
         * @param {Integer} [_mY]
         */
        Static DllMouseSetPos(_mX?, _mY?) {
            if !(IsSet(_mX) and IsSet(_mY))
                _ogPos := WinVector._MsPosDll()
            DllCall("SetCursorPos", "Int", _mX ?? _ogPos.x, "Int", _mY ?? _ogPos.y)
        }
        /**
         * @param {HWND} _wHwnd
         * @return {Object}
         * h.bf.h.bf.h.bf.
         *      ReturnObj := {
         *          x: 666,
         *          y: 666,
         *          w: 666,
         *          h: 666
         *      }
         */
        Static DllWinGetRect(_wHwnd) {
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
         *      ; -<_wRECT>-  takes precedence over -<_w[XYWH]>-
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
        Static DllWinSetRect(_wHwnd, _wRECT?, _wX?, _wY?, _wW?, _wH?) {
            Static SWP_NOZORDER := 0x0004
                ,  SWP_NOMOVE   := 0x0002
                ,  SWP_NOSIZE   := 0x0001
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

    }

    Class Grid {

    }
}





