#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <Utils\WinUtil\WinVector>





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
    )

    __New() {
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
            _filtered := []
            for _i, _hwnd in _list {
                _class := WinGetClass("ahk_id " _hwnd)
                if not this._excluded_classes.Has(_class)
                    _filtered.Push _hwnd
            }
            return _filtered
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
            if WinExist("ahk_id " live_hwnd)
                WinClose(live_hwnd), deaths++
        if IsSet(_callback) {
            _callback(_class, deaths)
        }
        else {
            TrayTip("[ " _class " ]", "Deaths: " deaths)
            SetTimer(HideTrayTip, -4000)
        }
    }

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

    Class Sizer {

        Static wvC := WinVector.Coordinates,
               wvD := WinVector.DLLUtil,
               ext := {},
               toggletimeout := 1250,
               ScreenGap := { x: 8, y: 8 },
               WindowOffset := { x: 0, y: 0 }

        Static __New() {
            if A_ComputerName = "DESKTOP-HJ4S4Q2"
                this.ScreenGap := { x: 10, y: 26 },
                this.WindowOffset := { x: 0, y: (-10) }
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
