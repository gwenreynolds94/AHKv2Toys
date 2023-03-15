#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include <Utils\WinUtil\WinVector>


    /** @alias HWND @type {Integer} */


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
     * @return {HWND}
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
     * @param {HWND[]} _list
     * @return {HWND[]}
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

    Class Sizer {

        Static wvC := WinVector.Coordinates,
               wvD := WinVector.DLLUtil,
               ext := {}

        Static __New() {
        }

        Static RlCoords => WinVector.DLLUtil.RealCoordsFromSuperficial
        Static SprCoords => WinVector.DLLUtil.SuperficialCoordsFromReal

        Static SizeWindow(wHwnd:=0, wScrGap:=8, *) {
            if !wHwnd
                wHwnd := WinExist("A")
            wTitle  := "ahk_id " wHwnd
            wWidth  := A_ScreenWidth - wScrGap*2
            wHeight := A_ScreenHeight - wScrGap*2
            this.RlCoords(&wRect:=0, wHwnd, wScrGap, wScrGap, wWidth, wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

        Static SizeWindowHalf(wHwnd:=0, wScrGap:=8, side:=0, *) {
            wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
            wWidth  := (A_ScreenWidth-wScrGap*2)//2
            wHeight :=  A_ScreenHeight-wScrGap*2
            wLX := wScrGap, wRX := wScrGap+wWidth
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
            wY := wScrGap
            this.RlCoords(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

    }

}
