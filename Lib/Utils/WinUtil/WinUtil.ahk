#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include <Utils\WinUtil\WinVector>





; Class WinUtil extends WinVector {
Class WinUtil {
    Static _excluded_classes := Map(
        "ApplicationManager_ImmersiveShellWindow", "ahk_class ",
        "Internet Explorer_Hidden",                "ahk_class ",
        "EdgeUiInputWndClass",                     "ahk_class ",
        "Shell_TrayWnd",                           "ahk_class ",
        "WorkerW",                                 "ahk_class ",
        "Progman",                                 "ahk_class "
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
     * @param {Integer[]} _list
     * @return {Integer[]}
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

    Class Sizer {

        Static wvC := WinVector.Coordinates,
               wvD := WinVector.DLLUtil,
               ext := {},
               ScreenGap := { x: 8, y: 8 },
               WindowOffset := { x: 0, y: 0 }

        Static __New() {
        }

        Static RlCoords => WinVector.DLLUtil.RealCoordsFromSuperficial
        Static SprCoords => WinVector.DLLUtil.SuperficialCoordsFromReal

        Static WinFull(wHwnd:=0, screengap?, windowoffset?, *) {
            screengap := IsSet(screengap) ? screengap : this.ScreenGap
            windowoffset := IsSet(windowoffset) ? windowoffset : this.WindowOffset
            if !wHwnd
                wHwnd := WinExist("A")
            wTitle  := "ahk_id " wHwnd
            wWidth  := A_ScreenWidth - screengap.x*2
            wHeight := A_ScreenHeight - screengap.y*2
            this.RlCoords(&wRect:=0, wHwnd, 
                        screengap.x + windowoffset.x, 
                        screengap.y + windowoffset.y, 
                        wWidth, 
                        wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

        Static WinHalf(wHwnd:=0, screengap?, windowoffset?, side:=0, *) {
            screengap := IsSet(screengap) ? screengap : this.ScreenGap
            windowoffset := IsSet(windowoffset) ? windowoffset : this.WindowOffset
            wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
            wWidth  := (A_ScreenWidth-screengap.x*2)//2
            wHeight :=  A_ScreenHeight-screengap.y*2
            wLX := screengap.x + windowoffset.x
            wRX := wLX + wWidth
            wY := screengap.y + windowoffset.y
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
