
#Include BuiltinsExtend.ahk

Class __PC {
    static name := 'unknown'
        , monitors := Map()
        , default_browser := 'msedge.exe'
        , fallback_browsers := []
        , default_fallback_browsers := [
            'Maxthon.exe',
            'waterfox.exe',
            'firefox.exe',
            'waterfox.exe'
            'chrome.exe',
            'msedge.exe'
        ]
        , browser_presets := Map(
            'B2B2M4P', {
                name: 'primary',
                browser: 'waterfox.exe'
            },
            'HQ7DNU', {
                name: 'primary',
                browser: 'msedge.exe'
            },
            'JJTV8BS', {
                name: 'secondary',
                browser: 'waterfox.exe'
            },
            'HJ4S4Q2', {
                name: 'laptop',
                browser: 'Maxthon.exe'
            },
            'unknown', {
                name: 'unknown',
                browser: 'msedge.exe'
            }
        )

    static __New() {
        for _computer_name, _preset in this.browser_presets
            if A_ComputerName ~= _computer_name
                this.name := _preset.name,
                this.default_browser := _preset.browser
        this.fallback_browsers := this.default_fallback_browsers.Filter((_browser)=>
                                                 !(_browser = this.default_browser))
    }

    static EnvPathHasFile(_file) {
        for _path in StrSplit(EnvGet('PATH'), ';')
            if FileExist(_try_path:=(RegExReplace(_path, '\\$') '\' _file))
                return _try_path
        return false
    }

    static RefreshMonitors(_force:=False) {
        loop (mcnt := MonitorGetCount()) {
            if !!this.monitors.Has(A_Index) and !_force
                continue
            ; wa := MonitorGetWorkArea(A_Index, &_l, &_t, &_r, &_b)
            this.monitors[A_Index] := __PC.__Monitor(A_Index)
        }
    }

    ; static IsPointOnMonitor(_point_x, _point_y, _N) {
    ;     this.RefreshMonitors()
    ;     if !!this.monitors[_N].HasPoint[_point_x, _point_y]
    ;         return true
    ;     return false
    ; }

    static MonitorWithPoint[_x,_y] {
        get {
            this.RefreshMonitors()
            for _N, _mon in this.monitors
                if !!_mon.HasPoint[_x, _y]
                    return _N
            return False
        }
    }

    static MonitorWithMouse {
        get {
            this.RefreshMonitors()
            if (mcnt := MonitorGetCount()) = 1
                return 1
            MouseGetPos(&_x, &_y)
            for _N, _mon in this.monitors
                if !!_mon.HasPoint[_x, _y]
                    return _N
            return False
        }
    }

    static MonitorWithWindow[_hwnd] {
        get {
            if not WinExist(_hwnd)
                return false
            this.RefreshMonitors()
            if (mcnt := MonitorGetCount()) = 1
                return 1
            WinGetPos(&_x, &_y, &_w, &_h, _hwnd)
            cx := _x + (_w // 2)
            cy := _y + (_h // 2)
            if !!this.monitors[1].HasFocus[true]
                return 1
            if (this.monitors.Count > 1) and !!this.monitors[2].HasFocus[true]
                return 2
            if (this.monitors.Count > 2) and !!this.monitors[3].HasFocus[true]
                return 3
            if (this.monitors.Count > 3)
                Loop (this.monitors.Count - 3)
                    if !!this.monitors[A_Index].HasFocus[false]
                        return this.monitors[A_Index]._N
            return False
        }
    }

    static MonitorWithFocus => __PC.MonitorWithWindow[WinExist('A')]

    Class __Monitor {
        _N := 0,
        l := left   := 0,
        r := right  := 0,
        t := top    := 0,
        b := bottom := 0,
        w := width  := 0,
        h := height := 0


        __New(_N) {
            this.UpdateWorkingArea(_N)
        }

        /**
         * @prop {number} HasPoint `boolean`
         * @param {number} _px
         * @param {number} _py
         */
        HasPoint[_px, _py] {
            get {
                if (_px <  this.l) or
                   (_py <  this.t) or
                   (_px >= this.r) or
                   (_py >= this.b)
                    return false
                return True
            }
        }

        /**
         * @prop {number} HasMouse `boolean`
         */
        HasMouse {
            get {
                MouseGetPos(&_mx, &_my)
                if this.HasPoint(_mx, _my)
                    return true
                return false
            }
        }

        /**
         * @prop {number} HasFocus `boolean`
         * @param {number} _force run `WinGetPos` to update window position.
         *      otherwise it returns the last calculation made
         */
        HasFocus[_force:=true] {
            get {
                GetWindowPosition(_force_update) {
                    static x := 0, y := 0, w := 0, h := 0, first_pass := true
                    if !!_force_update or !!first_pass
                        WinGetPos(&_wx, &_wy, &_ww, &_wh, WinExist('A')),
                                  x := _wx, y := _wy, w := _ww, h := _wh
                    first_pass := false
                    return {x: x, y: y, w: w, h: h}
                }
                active_win_pos := GetWindowPosition(_force)
                cx := active_win_pos.x + (active_win_pos.w // 2)
                cy := active_win_pos.y + (active_win_pos.h // 2)
                if !!this.HasPoint[cx, cy]
                    return true
                return false
            }
        }

        UpdateWorkingArea(_N?) {
            this._N := _N ?? this._N
            wa := MonitorGetWorkArea(this._N, &_l, &_t, &_r, &_b)
            if not wa
                throw ValueError("Tried to create an instance of __Monitor " .
                                 "using an out-of-bounds monitor number"     )
            this.l := this.left   := _l,
            this.r := this.right  := _r,
            this.t := this.top    := _t,
            this.b := this.bottom := _b,
            this.w := this.width  := (_r - _l),
            this.h := this.height := (_b - _t)
            return this
        }
    }
}
