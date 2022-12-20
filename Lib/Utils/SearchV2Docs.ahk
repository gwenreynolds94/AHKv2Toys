; ### `Search the AutoHotkey V2 docs using the text stored in your clipboard`
SearchV2DocsFromClipboard(*)
{
    hNewWin := 0x0, foundA := 0, foundB := 0, cX:=0, cY:=0
    startingHelpWins := WinGetList("AutoHotkey v2 Help")
    startWinsStr := "|666666666666666|"
    Loop startingHelpWins.Length {
        startWinsStr .= startingHelpWins[A_Index] "|"
    }
    Run "C:\Windows\hh.exe "
      . "`"C:\Program Files\AutoHotkey\v2.0-rc.2\AutoHotkey.chm`""
    SetTimer(WatchForWindow, 250)
    ; WATCH FOR NEW WINDOW
    WatchForWindow(*) {
        checkWins := WinGetList("AutoHotkey v2 Help")
        if (checkWins.Length>startingHelpWins.Length)
            for _chIndex, chWin in checkWins
                if !InStr(startWinsStr, "|" chWin "|")
                    hNewWin:=chWin
                        , WinActivate("ahk_id " hNewWin)
                        , SetTimer(,0)
                        , WinGetClientPos(&cX, &cY,,, "ahk_id " hNewWin)
                        , SetTimer(WaitForWinLoad, 10)
        ; WAIT FOR HAMBURGER CONTROL TO BE VISIBLE
        WaitForWinLoad(*) {
            hmRect := { x1: 1 , y1: 1, x2: 50, y2: 40 }
            hmRectB := { x1: 260, y1: 1, x2: 310, y2: 40 }
            if foundA:=ImageSearch(&resX:=0,&resY:=0
                    ,hmRect.x1,hmRect.y1
                    , hmRect.x2,hmRect.y2
                    ,A_ScriptDir "\Resources\SearchV2Docs\hamburgerBtn.png")
                SetTimer(,0), SearchFoundWindow()
            else if foundB:=ImageSearch(&resXB:=0,&resYB:=0
                    ,hmRectB.x1,hmRectB.y1
                    , hmRectB.x2,hmRectB.y2
                    ,A_ScriptDir "\Resources\SearchV2Docs\hamburgerBtn.png")
                SetTimer(,0), SearchFoundWindow()    
            ; SEND MOUSE/KEYBOARD EVENTS
            SearchFoundWindow(*) {
                OGCur := Buffer(8,0)
                DllCall("GetCursorPos", "Ptr", OGCur)
                DllCall("SetCursorPos", "Int", hmRect.x1+cX+10
                                      , "Int", hmRect.y1+cY+50)
                Click "Left"
                DllCall("SetCursorPos", "Int", NumGet(OGCur, 0, "Int")
                                      , "Int", NumGet(OGCur, 4, "Int"))
                SetKeyDelay 35, 10
                SendEvent "{LAlt Down}s{LAlt Up}{Ctrl Down}a{Ctrl Up}"
                        . "{BackSpace}{Ctrl Down}v{Ctrl Up}{Enter}"
                SetKeyDelay 10, -1
            }
        }
    }
}
