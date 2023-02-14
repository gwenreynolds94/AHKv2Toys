SizeWindow(wHwnd:=0, wScrGap:=8, *) {
    if !wHwnd
        wHwnd := WinExist("A")
    wTitle  := "ahk_id " wHwnd
    wWidth  := A_ScreenWidth - wScrGap*2
    wHeight := A_ScreenHeight - wScrGap*2
    ; ConvertTrueWinCoords(&wRect:=0, wHwnd, wScrGap, wScrGap, wWidth, wHeight)
    RealCoordsFromSuperficial(&wRect:=0, wHwnd, wScrGap, wScrGap, wWidth, wHeight)
    WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
}

SizeWindowHalf(wHwnd:=0, wScrGap:=8, side:=0, *) {
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
        ; ConvertTrueWinCoords(&visRect:=0, wHwnd)
        SuperficialCoordsFromReal(&visRect:=0, wHwnd)
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
    ; ConvertTrueWinCoords(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
    RealCoordsFromSuperficial(&wRect:=0, wHwnd, wX, wY, wWidth, wHeight)
    WinMove(wRect.x, wRect.y, wRect.w, wRect.h, wTitle)
}

GetWindowMarginsRect(&win, wHwnd) {
    win := {}
    newWinRect := Buffer(16)
    DllCall("GetWindowRect", "Ptr", wHwnd, "Ptr", newWinRect.Ptr)
    win.x := NumGet(newWinRect,  0, "Int")
    win.y := NumGet(newWinRect,  4, "Int")
    win.w := NumGet(newWinRect,  8, "Int")
    win.h := NumGet(newWinRect, 12, "Int")
}

GetWindowVisibleRect(&frame, wHwnd) {
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

SuperficialCoordsFromReal(&outCoords, wHwnd) {
    WinGetPos &wX, &wY, &wW, &wH, "ahk_id " wHwnd
    GetWindowMarginsRect( &win , wHwnd)
    GetWindowVisibleRect(&frame, wHwnd)
    offSetLeft   := frame.x - win.x
    offSetRight  := win.w - frame.w
    offSetBottom := win.h - frame.h
    outCoords    := {}
    outCoords.y  := wY
    outCoords.x  := wX + offSetLeft
    outCoords.h  := wH - offSetBottom
    outCoords.w  := wW - (offSetRight * 2)
}

RealCoordsFromSuperficial(&outCoords, wHwnd, wX, wY, wW, wH) {
    GetWindowMarginsRect( &win , wHwnd)
    GetWindowVisibleRect(&frame, wHwnd)
    offSetLeft   := frame.x - win.x
    offSetRight  := win.w - frame.w
    offSetBottom := win.h - frame.h
    outCoords    := {}
    outCoords.y  := wY
    outCoords.x  := wX - offSetLeft
    outCoords.h  := wH + offSetBottom
    outCoords.w  := wW + (offSetRight * 2)
}
