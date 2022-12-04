#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

if !gdip_token:=Gdip_Startup(){
    MsgBox "Gdi+ failed to start"
    ExitApp
}
OnExit (*)=> Gdip_Shutdown(gdip_token)

if A_ScriptName="assignments_run_test.ahk"
    RunTestsFromInputBox

RunTestsFromInputBox() {
    /**@var {InputBox Object} user_input ->
     *      Return {Value: String, Result: String}
     *  **Value** `contains number of test iterations to run` */
    user_input := InputBox( "1 test takes approximately 5 seconds and "  ;
                          . "runs 250 times.`n`n"                        ;
                          . "Enter desired number of test iterations. "  ;
                          . "between 500 and 50000 as an integer."       ;
                          , "AHK Assignments Speed Test"                 ;
                          , "w275 h150 T10"                              )
    if IsNumber(user_val:=user_input.Value) {
        user_val*=250
        if (user_val <= 50000)||(user_val > 0) {
            if ((user_val > 500)
                    && (MsgBox("That'll take about " 5*user_val/250 " seconds."
                             , "You sure?", 0x1) ~= "(Timeout)|(Cancel)"))
                ExitApp
            tProg := NewTestsProgressBar(300, 50,,15, 4,, 0xAA66795A)
            Loop user_val {
                RunEvalCont()
                RunEvalSame()
                RunEvalSep()
                if !(Mod(A_Index, user_val/250))
                    tProg.Update.Call(A_Index/user_val)
            }
            stats := GetStats()
            MsgBox "cont:`navg: " stats.cont.avg 
                   . "`ntests: " stats.cont.count 
                   . "`n`n"
                 . "same:`navg: " stats.same.avg 
                   . "`ntests: " stats.same.count
                   . "`n`n"
                 . "sep:`navg: " stats.sep.avg
                   . "`ntests: " stats.sep.count
            tProg.Destroy()
            ExitApp
        } else MsgBox "Number passed is not within the accpeted range."
    } else MsgBox "Value passed is not a number."
}

F8::ExitApp

/**
 * ### `Create and return Object to control progress bar gui`
 *      Return { Destroy: Func
 *             , Update: Func(progress) }
 *      
 *      Destroy |> "Destroy Gui object; release 0x201 OnMessage Callback"
 *      Update  |> "Redraw progress bar with Gdi+ using progress value"
 * 
 * @param {Integer} screenMargin `Pixels between progress bar and screen edge`
 * @param {Integer} borderRadius
 * @param {Integer} edgeThickness
 * @param {ARGB Hex} pbFore `Progress bar foreground color as hexadecimal`
 * @param {ARGB Hex} pbBack `Progress bar background color as hexadecimal`
 * @return {Object ( Func, ... )}
**/
NewTestsProgressBar( pbWidth:=200, pbHeight:=25
                   , screenMargin:=10, borderRadius:=8, edgeThickness:= 2
                   , pbFore:=0xFF7B9B67, pbBack:=0xFF66795A ) {
    pbGui := Gui("+AlwaysOnTop -Caption +E0x80000 +ToolWindow +OwnDialogs")
    pbSize := {
        w: pbWidth
      , h: pbHeight
    }
    pbInnerSize := {
        w: pbSize.w - edgeThickness*2
      , h: pbSize.h - edgeThickness*2
    }
    progBar := { 
                fore: pbFore
      ,         back: pbBack
      ,       margin: screenMargin
      ,         edge: edgeThickness
      ,          gui: pbGui
      ,         size: pbSize
      ,    innerSize: pbInnerSize
      , bRadiusInner: Round(
                        ((pbInnerSize.h < pbInnerSize.w) 
                            ? pbInnerSize.h : pbInnerSize.w)
                        / ((pbSize.h < pbSize.w) 
                            ? pbSize.h : pbSize.w) 
                        * borderRadius
                      )
      , bRadiusOuter: borderRadius
    }
    pbGui.Show( "x" A_ScreenWidth-progBar.size.w-progBar.margin  " "
              . "y" A_ScreenHeight-progBar.size.h-progBar.margin " "
              . "w" progBar.size.w+2                             " "
              . "h" progBar.size.h+2                             " "
              . "NA"                                               )

    ; WM_LBUTTONDOWN |> 0x201 ... WM_NCLBUTTONDOWN |> 0xA1 ... HTCAPTION |> 2
    OnMessage 0x201, OnLButtonDown
    OnLButtonDown(wParam, lParam, msg, hwnd) {
        PostMessage 0xA1, 2,,, "ahk_id " hwnd
    }

    UpdateProgBar( _progBar, progress ) {
        progBM   := CreateDIBSection(_progBar.size.w+2, _progBar.size.h+2)
        progDC   := CreateCompatibleDC()
        progDCBM := SelectObject(progDC, progBM)
        progGfx  := Gdip_GraphicsFromHDC(progDC)
        Gdip_SetSmoothingMode(progGfx, 4)
        bgBrush  := Gdip_BrushCreateSolid(_progBar.back)
        fgBrush  := Gdip_BrushCreateSolid(_progBar.fore)
        Gdip_FillRoundedRectangle( progGfx, bgBrush, 1, 1           ;
                                 , _progBar.size.w, _progBar.size.h ;
                                 , _progBar.bRadiusOuter            )
        newInnerWidth := Round( 
            ( _progBar.innerSize.w - _progBar.bRadiusInner*2 ) * progress
            + _progBar.bRadiusInner*2
        )
        Gdip_FillRoundedRectangle( progGfx, fgBrush      ;
                                 , _progBar.edge+1       ;
                                 , _progBar.edge+1       ;
                                 , newInnerWidth         ;
                                 , _progBar.innerSize.h  ;
                                 , _progBar.bRadiusInner )
        Gdip_DeleteBrush(bgBrush)
        Gdip_DeleteBrush(fgBrush)
        UpdateLayeredWindow(_progBar.Gui.Hwnd, progDC)
        SelectObject(progDC, progDCBM)
        DeleteObject(progBM)
        DeleteDC(progDC)
    }

    UpdateProgBar(progBar, 0)

    Destroy(_pbGui, _onLButtonDown, *) {
        _pbGui.Destroy()
        OnMessage 0x201, _onLButtonDown, 0
    }

    Return { Destroy: Destroy.Bind(pbGui, OnLButtonDown)
           , Update: UpdateProgBar.Bind(progBar)         }
}

#Include .\assignments_evaluate.ahk
#Include ..\..\..\Lib\GdipLib\Gdip_Custom.ahk
