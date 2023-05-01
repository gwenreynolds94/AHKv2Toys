#Requires AutoHotkey v2.0
#Warn All, StdOut
#SingleInstance Force

#Include <DEBUG\DBT>
Persistent

Class HookObjectCreate {
    Static  hook := 0x00000,
            wTitles := Map( "ahk_exe Code.exe"            , "Full",
                            "ahk_class MozillaWindowClass", "Half",
                            "ahk_exe WindowsTerminal.exe" , "Half"  )

    Static __New()
    {
        this.RegisterWinHook()
        this.InitHotkeys()
        OnExit ObjBindMethod(this, "UnRegisterWinHook")
    }

    Static InitHotkeys() {
        Hotkey "#F8", ObjBindMethod(this, "RegisterWinHook")
        Hotkey "#F9", ObjBindMethod(this, "UnRegisterWinHook")
    }

    Static RegisterWinHook(*)
    {
        if (this.hook) {
            this.hook := DllCall("User32\UnhookWinEvent", "Ptr",this.hook)
        } else {
            this.hook := DllCall("User32\SetWinEventHook"
                , "Int", 0x8000   ;  EVENT_OBJECT_CREATE
                , "Int", 0x8000
                , "Ptr", 0
                , "Ptr", CallbackCreate(RegisterWinHook_CB, "F")
                , "Int", 0
                , "Int", 0
                , "Int", 0)
        }
        RegisterWinHook_CB(hWinEventHook, Event, hWnd)
        {
            Critical "Off"
            wClass := (bwClass:=WinExist("ahk_id" hWnd)) ? WinGetClass() : 0
            wTitle := (bwTitle:=WinExist("ahk_id" hWnd)) ? WinGetTitle() : 0
            if (!!wClass or !!wTitle)
                this.OnObjectCreate(hWnd, wClass, wTitle)
        }
        return !!this.hook
    }
    Static UnRegisterWinHook(*)
    {
        this.hook := (this.hook) ? DllCall("User32\UnhookWinEvent", "Ptr", this.hook) : this.hook
    }

    Static OnObjectCreate(hWnd, wClass, wTitle)
    {
        if !(isWin := DllCall("IsWindow", "Ptr", hWnd))
            return
        ToolTip isWin ? "==========================" : "0"
        SetTimer (*)=>Tooltip(), 2000
        SetTimer TrySizingWindow, 1000
        attempts := 0
        TrySizingWindow() {
            for _wT, _wF in this.wTitles {
                if (WinExist(_wT)=hWnd) {
                    SetTimer(,0)
                    if _wF="Half"
                        HookObjectCreate.WinSizePos.SizeWindowHalf(hWnd)
                    else if _wF="Full"
                        HookObjectCreate.WinSizePos.SizeWindow(hWnd)
                }
            }
            if ++attempts>=5
                SetTimer(,0)
        }
    }

    Class WinSizePos {

        Static SizeWindow(wHwnd:=0, wScrGap:=8, *)
        {
            wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
            wTitle  := "ahk_id " wHwnd
            wWidth  := A_ScreenWidth  - wScrGap*2
            wHeight := A_ScreenHeight - wScrGap*2
            this.RealCoordsFromSuperficial(&wRect:=0, wHwnd, wScrGap, wScrGap, wWidth, wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

        Static SizeWindowHalf(wHwnd:=0, wScrGap:=8, side:=0, *)
        {
            wHwnd   := (!wHwnd) ? WinExist("A") : (wHwnd)
            wWidth  := (A_ScreenWidth-wScrGap*2)//2
            wHeight :=  A_ScreenHeight-wScrGap*2
            wLX     := wScrGap
            wRX     := wScrGap+wWidth
            wTitle  := "ahk_id " wHwnd

            if (side=1) or (side="left")
                wX := wLX
            else if (side=2) or (side="right")
                wX := wRX
            else {
                this.SuperficialCoordsFromReal(&visRect:=0, wHwnd)
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
            this.RealCoordsFromSuperficial(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
            WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
        }

        Static GetWindowMarginsRect(&win, wHwnd)
        {
            win := {}
            newWinRect := Buffer(16)
            DllCall("GetWindowRect", "Ptr", wHwnd, "Ptr", newWinRect.Ptr)
            win.x := NumGet(newWinRect,  0, "Int")
            win.y := NumGet(newWinRect,  4, "Int")
            win.w := NumGet(newWinRect,  8, "Int")
            win.h := NumGet(newWinRect, 12, "Int")
        }

        Static GetWindowVisibleRect(&frame, wHwnd)
        {
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

        Static SuperficialCoordsFromReal(&outCoords, wHwnd)
        {
            WinGetPos &wX, &wY, &wW, &wH, "ahk_id " wHwnd
            this.GetWindowMarginsRect( &win , wHwnd)
            this.GetWindowVisibleRect(&frame, wHwnd)

            offSetLeft   := frame.x - win.x
            offSetRight  := win.w - frame.w
            offSetBottom := win.h - frame.h

            outCoords    := {}
            outCoords.y  := wY
            outCoords.x  := wX + offSetLeft
            outCoords.h  := wH - offSetBottom
            outCoords.w  := wW - (offSetRight * 2)
        }

        Static RealCoordsFromSuperficial(&outCoords, wHwnd, wX, wY, wW, wH)
        {
            this.GetWindowMarginsRect( &win , wHwnd)
            this.GetWindowVisibleRect(&frame, wHwnd)

            offSetLeft   := frame.x - win.x
            offSetRight  := win.w - frame.w
            offSetBottom := win.h - frame.h

            outCoords    := {}
            outCoords.y  := wY
            outCoords.x  := wX - offSetLeft
            outCoords.h  := wH + offSetBottom
            outCoords.w  := wW + (offSetRight * 2)
        }
    }
}