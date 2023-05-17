#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include WinVector.ahk
#Include ..\DetectComputer.ahk
#Include ..\BuiltinsExtend.ahk




; Class WinUtil extends WinVector {
Class WinUtil {
    Static _excluded_classes := Map(
        "ApplicationManager_ImmersiveShellWindow" , "ahk_class " ,
                       "Internet Explorer_Hidden" , "ahk_class " ,
                       "Internet_Explorer_Hidden" , "ahk_class " ,
                            "EdgeUiInputWndClass" , "ahk_class " ,
                                  "AutoHotkeyGUI" , "ahk_class " ,
                                  "Shell_TrayWnd" , "ahk_class " ,
                                    "SunAwtFrame" , "ahk_class " ,
                                        "WorkerW" , "ahk_class " ,
                                        "Progman" , "ahk_class "
    ),
    _active_window_tracking := "unset"

    Static __New() {
        
    }

    /**
     * @param {Integer} look_behind
     * @return {Integer}
     */
    Static PrevWindow[look_behind:=1] {
        Get {
            look_at := look_behind + 1
            clean_list := WinUtil.FilteredWinList[WinGetList()]
            return ((look_behind + 1) > clean_list.Length) ?
                clean_list[clean_list.Length] : clean_list[(look_behind + 1)]
        }
    }

    /**
     * @param {Array} _list
     * ```AutoHotkey2
     *      _list == { Integer[] }
     *
     * ```
     * @return {Array}
     *      retval == { Integer() }
     */
    Static FilteredWinList[_list:=""] {
        Get {
            if _list = "all"
                _list := WinGetList()
            _filtered := []
            for _i, _hwnd in _list {
                _class := WinGetClass("ahk_id " _hwnd)
                if not this._excluded_classes.Has(_class)
                    _filtered.Push _hwnd
            }
            return _filtered
        }
    }

    Static ActiveWindowTracking {
        Get {
            Static SPITrack := 0,
                   SPIOnTop := 0,
                   SPIDelay := 0
            if this._active_window_tracking == "unset" {
                SPITrack := DllCall("User32.dll\SystemParametersInfo",
                                    "UInt", 0x1000, "UInt", 0, 
                                    "UIntP", SPITrack, "UInt", False)
                SPIOnTop := DllCall("User32.dll\SystemParametersInfo",
                                    "UInt", 0x100C, "UInt", 0, 
                                    "UIntP", SPIOnTop, "UInt", False)
                SPIDelay := DllCall("User32.dll\SystemParametersInfo",
                                    "UInt", 0x2002, "UInt", 0, 
                                    "UIntP", SPIDelay, "UInt", False)
                this._active_window_tracking := !!(SPITrack+SPIOnTop+SPIDelay)
            }
            return this._active_window_tracking
        }
        Set {
            if !!Value {
                Track := True
                OnTop := True
                Delay := 1000
            } else {
                Track := False
                OnTop := False
                Delay := 0
            }
            DllCall("User32.dll\SystemParametersInfo",
                    "UInt", 0x1001, "UInt", 0, 
                    "Ptr", Track, "UInt", False)
            DllCall("User32.dll\SystemParametersInfo",
                    "UInt", 0x100D, "UInt", 0, 
                    "Ptr", OnTop, "UInt", False)
            DllCall("User32.dll\SystemParametersInfo",
                    "UInt", 0x2003, "UInt", 0, 
                    "Ptr", Delay, "UInt", False)
            this._active_window_tracking := Value
        }
    }

    Static WinCloseClass(_class?, _callback?, *) {
        HideTrayTip(*) {
            TrayTip()
            if SubStr(A_OSVersion, 1, 3) = "10." {
                A_IconHidden := True
                SetTimer((*)=>(A_IconHidden := False), (-200))
            }
        }
        _class := IsSet(_class) ? _class : WinGetClass("ahk_id " WinExist("A"))
        living_windows := WinGetList("ahk_class" _class)
        deaths := 0
        for live_hwnd in living_windows
            if WinExist(live_hwnd)
                WinClose(), deaths++
        if IsSet(_callback) {
            _callback(_class, deaths)
        }
        else {
            TrayTip("[ " _class " ]", "Deaths: " deaths)
            SetTimer(HideTrayTip, -3000)
        }
    }

    /**
     * @param {String|Number} _re_proc_name regex used to match process names;
     *
     * **DO NOT** include "`i)`"
     */
    Static WinCloseProcesses(_re_proc_name) {
        pre_title_match := A_TitleMatchMode
        A_TitleMatchMode := 'RegEx'
        windows := WinGetList("ahk_exe i)" _re_proc_name)
        deaths := 0
        for _hwnd in windows
            if WinExist(_hwnd)
                WinKill(), deaths++
        A_TitleMatchMode := pre_title_match
        TrayTip '[ ' _re_proc_name ' ]', 'Deaths: ' deaths
        SetTimer((*)=>TrayTip(), -3000)
    }

    static WinWaitNewActive(_win_title?, _timeout?) {
        static win_list_og := [], win_title_og := ''
        if IsSet(_win_title)
            win_list_og := WinGetList(win_title_og := _win_title)
        WinWaitActive win_title_og,, _timeout ?? unset
        win_list_new := WinGetList(win_title_og)
        for _hwnd in win_list_new
            if not win_list_og.IndexOf(_hwnd)
                return _hwnd
        return WinUtil.WinWaitNewActive()
    }

    ; static RunWinWait() {}

    Static WinUnderCursor[_title_type:="hwnd"] => (
        MouseGetPos(,, &_hwnd),
        (_title_type="hwnd")        ? (_hwnd)                            :
        (_title_type="class")       ? WinGetClass("ahk_id " _hwnd)       :
        (_title_type="title")       ? WinGetTitle("ahk_id " _hwnd)       :
        (_title_type="process")     ? WinGetProcessName("ahk_id " _hwnd) :
        (_title_type="processpath") ? WinGetProcessName("ahk_id " _hwnd) :
        _hwnd
    )

    Class Region {
        Class Default {
            Static  title_height := 26,
                    border := 1
        }
        Static DisableDWM(_hwnd?) {
            DllCall("dwmapi\DwmSetWindowAttribute",
                    "ptr", _hwnd ?? WinExist("A"),
                    "uint", DWMWA_NCRENDERING_POLICY := 2,
                    "int*", DWMNCRP_DISABLED := 1,
                    "uint", 4)
        }
        Static EnableDWM(_hwnd?) {
            DllCall("dwmapi\DwmSetWindowAttribute",
                    "ptr", _hwnd ?? WinExist("A"),
                    "uint", DWMWA_NCRENDERING_POLICY := 2,
                    "int*", DWMNCRP_DISABLED := 2,
                    "uint", 4)
        }
        Static RemoveTitleBar(_hwnd?, _title_height?, _border?) {
            _hwnd := _hwnd ?? WinExist("A")
            _title_height := _title_height ?? WinUtil.Region.Default.title_height
            _border := _border ?? WinUtil.Region.Default.border
            wTitle := "ahk_id " _hwnd
            WinGetPos(,,&_wW, &_wH, wTitle)
            _x := _border
            _y := _border + _title_height
            _w := _wW - _border*2
            _h := _wH - _border*2 - _title_height
            _region := _x "-" _y " W" _w " H" _h
            WinSetRegion(_region, wTitle)
        }
        Static RemoveWindowCaption(_hwnd?) {
            wTitle := "ahk_id " (_hwnd ?? WinExist("A"))
            WinSetStyle "-0xC00000", wTitle
        }
        Static RestoreWindowCaption(_hwnd?) {
            wTitle := "ahk_id " (_hwnd ?? WinExist("A"))
            WinSetStyle "+0xC00000", wTitle
        }
        Static RestoreRegion(_hwnd?) {
            wTitle := "ahk_id " (_hwnd ?? WinExist("A"))
            WinSetRegion(, wTitle)
        }
    }

    Class Cycler {
        static screengap := {x: 8, y: 8}

        static Fill(_hwnd?) {
            static last_win := 0, last_tick := 0
            new_tick := A_TickCount
            _hwnd := _hwnd ?? WinExist('A')
            if not WinExist(_hwnd)
                return TrayTip.Quik('[ WinUtil.Cycler.Fill( ' _hwnd ' ) ]',
                                    'Could not find a valid window', 3333 )
            _mon := Max(__PC.MonitorWithWindow[_hwnd], 1)
            if (last_win = _hwnd) and ((new_tick - last_tick) < 1000)
                if ++_mon > __PC.monitors.Count
                    _mon := 1
            wX := __PC.monitors[_mon].left + this.screengap.x
            wY := __PC.monitors[_mon].top + this.screengap.y
            wWidth := WinVector.ScrWidth(_mon) - this.screengap.x*2
            wHeight := WinVector.ScrHeight(_mon) - this.screengap.y*2
            WinVector.DLLUtil.RealCoordsFromSuperficial(
                &real_coords := 0, _hwnd,
                wX, wY,
                wWidth, wHeight
            )
            WinMove real_coords.x, real_coords.y, real_coords.w, real_coords.h, _hwnd
            last_win := _hwnd, last_tick := new_tick
        }

        static HalfFill(_hwnd?) {
            static last_win := 0, last_tick := 0
            new_tick := A_TickCount
            _hwnd := _hwnd ?? WinExist('A')
            if not WinExist(_hwnd)
                return TrayTip.Quik('[ WinUtil.Cycler.Fill( ' _hwnd ' ) ]',
                    'Could not find a valid window', 3333)
            /** @var {__PC.__Monitor} _mon */
            _mon := __PC.monitors[Max(__PC.MonitorWithWindow[_hwnd], 1)]
            wWidth := (_mon.width - this.screengap.x * 2) / 2
            wHeight := (_mon.height - this.screengap.y * 2)
            WinVector.DLLUtil.SuperficialCoordsFromReal(&scoords:=0, _hwnd)
            lhs := _mon.left + this.screengap.x
            rhs := lhs + wWidth
            if scoords.w = wWidth and scoords.h = wHeight {
                if scoords.x = lhs
                    wX := rhs
                else {
                    new_mon_n := _mon._N + 1
                    if new_mon_n > __PC.monitors.Count
                        new_mon_n := 1
                    _mon := __PC.monitors[new_mon_n]
                    wWidth := (_mon.width - this.screengap.x * 2) / 2
                    wHeight := (_mon.height - this.screengap.y * 2)
                    wX := _mon.left + this.screengap.x
                }
            } else if (scoords.x + (scoords.w / 2)) < (_mon.left + (_mon.width / 2))
                wX := lhs
            else wX := rhs
            wY := _mon.top + this.screengap.y
            WinVector.DLLUtil.RealCoordsFromSuperficial(
                &real_coords := 0, _hwnd,
                wX, wY, wWidth, wHeight
            )
            WinMove real_coords.x, real_coords.y, real_coords.w, real_coords.h, _hwnd
            last_win := _hwnd, last_tick := new_tick
        }
    }

    Class Sizer {

        Static wvC := WinVector.Coord, ; hit da bricks
               wvD := WinVector.DLLUtil, ; hit da bricks
               ext := {},
               toggletimeout := 1250,
               ScreenGap := { x: 8, y: 8 },
               WindowOffset := { x: 0, y: 0 },
               presets := Map(
                    "primary", {
                        screen_gap    : { x: 8, y: 8 },
                        window_offset : { x: 0, y: 0 }
                    },
                    "secondary", {
                        ; screen_gap    : { x: 10, y: 26 },
                        ; window_offset : { x: 0, y: (-10) }
                        screen_gap    : { x: 8, y: 8 },
                        window_offset : { x: 0, y: 0 }
                    },
                    "laptop", {
                        screen_gap    : { x: 8, y: 8 },
                        window_offset : { x: 0, y: 0 }
                    },
                    "unknown", {
                        screen_gap    : { x: 8, y: 8 },
                        window_offset : { x: 0, y: 0 }
                    }
               )

        Static __New() {
            use_preset := this.presets[__PC.name]
            this.ScreenGap := use_preset.screen_gap
            this.WindowOffset := use_preset.window_offset
        }

        Static RlCoords => WinVector.DLLUtil.RealCoordsFromSuperficial
        Static SprCoords => WinVector.DLLUtil.SuperficialCoordsFromReal

        Static WinFull(wHwnd?, screengap?, windowoffset?, *) {
            Static lastwin := 0, lasttick := 0
            screengap := IsSet(screengap) ? screengap : this.ScreenGap
            windowoffset := IsSet(windowoffset) ? windowoffset : this.WindowOffset
            wHwnd := wHwnd ?? WinExist("A")
            wTitle := "ahk_id " wHwnd
            tMon := WinVector.MonitorWithWindow[wHwnd]
            if (lastwin = wHwnd) and (A_TickCount - lasttick < this.toggletimeout)
                tMon := !(tMon - 1) + 1
            wWidth := WinVector.ScrWidth(tMon) - screengap.x*2
            wHeight := WinVector.ScrHeight(tMon) - screengap.y*2
            this.RlCoords(&wRect:=0, wHwnd,
                        screengap.x + windowoffset.x + ((tMon > 1 ) ? A_ScreenWidth : 0),
                        screengap.y + windowoffset.y,
                        wWidth,
                        wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
            lastwin := wHwnd
            lasttick := A_TickCount
        }

        Static WinHalf(wHwnd:=0, screengap?, windowoffset?, side:=0, *) {
            screengap := IsSet(screengap) ? screengap : this.ScreenGap
            windowoffset := IsSet(windowoffset) ? windowoffset : this.WindowOffset
            wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
            wWidth  := (A_ScreenWidth-screengap.x*2)//2
            wHeight :=  A_ScreenHeight-screengap.y*2
            wLX     := screengap.x + windowoffset.x
            wRX     := wLX + wWidth
            wY      := screengap.y + windowoffset.y
            wTitle  := "ahk_id " wHwnd
            if (side=1) or (side="left")
                wX := wLX
            else if (side=2) or (side="right")
                wX := wRX
            else {
                this.SprCoords(&visRect:=0, wHwnd)
                if (visRect.x=wLX) and (visRect.w=wWidth)
                    wX := wRX
                else if (visRect.x=wRX) and (visRect.w=wWidth)
                    wX := wLX
                else {
                    if (visRect.x>(A_ScreenWidth/2))
                        wX := wRX
                    else if ((visRect.x+visRect.w)<=(A_ScreenWidth/2))
                        wX := wLX
                    else if ((((A_ScreenWidth/2)-visRect.x)/visRect.w)>0.5)
                        wX := wLX
                    else wX := wRX
                }
            }
            this.RlCoords(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

    }

}
