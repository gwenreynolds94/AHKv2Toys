FormatSingleLineComment(sep:=":", padWidth:=1) {
    SetKeyDelay 25, 5
    saveClip := A_Clipboard
    SendEvent "{End}{Shift Down}{Home}{Shift Up}{Ctrl Down}c{Ctrl up}"
    homeOnce := A_Clipboard
    SendEvent "{Shift Down}{Home}{Shift Up}{Ctrl Down}c{Ctrl Up}"
    homeTwice := A_Clipboard
    if StrLen(homeOnce) > StrLen(homeTwice) {
        SendEvent "{Shift Down}{Home}{Shift Up}"
        clip := homeOnce
    } else clip := homeTwice
    clip := StrReplace(clip, "`r`n", "")
    clip := StrReplace(clip, "`t", "`s`s`s`s")
    trimClip := LTrim(clip)
    leading := StrReplace(clip, trimClip, "")
    fillSpace := 80-StrLen(clip)
    lFill := (fillSpace-Mod(fillSpace,2)) / 2
    rFill := lFill+Mod(fillSpace,2)
    fString := leading
    Loop lFill-padWidth {
        if Mod(A_Index,2)
            fString .= ";"
        else
            fString .= sep
    }
    Loop padWidth {
        fString .= " "
    }
    fString .= trimClip
    Loop padWidth {
        fString .= " "
    }
    Loop rFill-padWidth {
        if Mod(A_Index,2)
            fString .= ";"
        else
            fString .= sep
    }
    A_Clipboard := fString
    Send "{Ctrl Down}v{Ctrl Up}"
    Sleep 25
    A_Clipboard := saveClip
}
