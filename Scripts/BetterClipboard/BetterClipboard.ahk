#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>
#Include <Gdip_v2Ex>
#Include BCManageConf.ahk


if A_ScriptName="BetterClipboard.ahk" {
    RunBC()
}
RunBC() {
    app:=BC_App()
}

Class BC_App {
    gdip          := {}
    gui           := {}
    isGuiActive   := False
    guiSize       := { w: 675, h: 450 }
    sizeOpts      := "w" this.guiSize.w " "
                   . "h" this.guiSize.h
    opacity       := "225"
    fadeSteps     := 10
    interruptFade := False
    border        := 4
    editOpts      := "x" this.border " y" this.border    " "
                   . "w" this.guiSize.w - this.border*2 " "
                   . "h" this.guiSize.h - this.border*2 " BackgroundDDEEFF"
    __New() {
        this.gui := Gui("-Caption +AlwaysOnTop")
        this.gui.BackColor := 0x7FB089
        this.bgPic := this.gui.Add("Picture", "0xE x0 y0 " this.sizeOpts)
        this.edit  := this.gui.Add("Edit", this.editOpts)
        
        this.gui.Show("x" A_ScreenWidth " " this.sizeOpts)
        WinSetTransparent this.opacity, this.gui
        this.indexGui := BC_App.IndexOverlay(this.gui, 110+this.border, 36+this.border)
        this.Hide()

        Hotkey "F8", (*)=> ExitApp()
        HotIfWinactive("ahk_id " this.gui.Hwnd)
        Hotkey "PgDn", ObjBindMethod(this, "PreviousClip")
        Hotkey "PgUp", ObjBindMethod(this, "NextClip")
        HotIf
    }
    PreviousClip(ThisHotkey, *) {
        stdo ThisHotkey
    }
    NextClip(ThisHotkey, *) {
        stdo ThisHotkey
    }
    Show(stepDuration:=10) {
        this.gui.Show("Center")
        Hotkey "<#c", ObjBindMethod(this, "On_LWinC_Down", "Hide")
        stepSize := this.opacity/this.fadeSteps
        currStep := 0
        this.interruptFade := False
        SetTimer Step, stepDuration
        Step(*) {
            currStep += 1
            currOp := currStep*stepSize
            if !this.interruptFade {
                if currOp >= this.opacity
                    currOp:=this.opacity, this.indexGui.Show(24), SetTimer(,0)
            WinSetTransparent Integer(currOp), this.gui
            } else SetTimer(,0)
        }
    }
    Hide() {
        this.interruptFade := True
        this.indexGui.Hide()
        WinSetTransparent 0, this.gui
        this.gui.Hide()
        Hotkey "<#c", ObjBindMethod(this, "On_LWinC_Down", "Show")
    }
    On_LWinC_Down(_funcName, *) {
        Hotkey("*c", (*)=>""), Hotkey("LWin", (*)=>"")
        shortPress:=KeyWait("c", "T0.75")
        if !shortPress and _funcName="Show"
            SendMessage(
                0x0301,,, (ctrl:=ControlGetFocus("A")) ? ctrl : WinExist("A"))
        else if !shortPress and _funcName="Hide"
            A_Clipboard := this.edit.Value
        this.%_funcName%()
        While (GetKeyState("c") or GetKeyState("LWin")) {
            Sleep(10)
        } Hotkey("*c", "Off"), Hotkey("LWin", "Off")
    }

    Class IndexOverlay {
        conf          := {}
        curIndex      := 0
        maxIndex      := 0
        gdipToken     := 0x0
        parentGui     := {}
        width         := 0
        height        := 0
        opacity       := "FF"
        fontColor     := "FFFFFF"
        fontName      := "Courier Prime"
        fadeStepsEnum := ["00", "11", "22", "33", "44", "55", "66", "77"
                        , "88", "99", "AA", "BB", "CC", "DD", "EE", "FF"]
        firstDisplay  := True
        interruptFade := False
        __New(_pGui, _w, _h, _op:="DD") {
            this.conf := BC_Config
            this.curIndex := BC_Config.CurIndex
            this.maxIndex := BC_Config.MaxIndex
            WS_EX_STATICEDGE:="E0x00020000" ; little baby window edge
            WS_EX_NOACTIVATE:="E0x08000000" ; prevents window getting focus
            this.width := _w, this.height := _h
            this.parentGui := _pGui, this.opacity:=_op
            this.fontColor := this.parentGui.BackColor
            this.gui := Gui("+" WS_EX_NOACTIVATE " +E0x80000 "
                          . "-Caption +Owner" _pGui.Hwnd)
            this.gui.Show("x" 0 " y" (-5)-_h " w" _w " h" _h " NA")

            GdipShutdownFunc(_token, *) {
                if (_token) {
                    Gdip_Shutdown _token
                    stdo "Shutting down Gdi+..."
                }
            }
            if this.gdipToken:=Gdip_Startup() {
                this.PaintGui(this.opacity)
                OnExit GdipShutdownFunc.Bind(this.gdipToken)
            }

            this.PaintGui("00")
            this.gui.Hide()
            this.Bound_Hide := ObjBindMethod(this, "Hide")
        }

        PaintGui(_opacity) {
            _hbm := CreateDIBSection(_w:=this.width, _h:=this.height)
            _hdc := CreateCompatibleDC()
            _obm := SelectObject(_hdc, _hbm)
            _gfx := Gdip_GraphicsFromHDC(_hdc)
            _fontName := (Gdip_FontFamilyCreate(this.fontName)) ? this.fontName : "Arial"
            _fontColor := _opacity . this.fontColor
            _fontOpts := "x5p y5p w90p h90p vCenter c" _fontColor " r4 s30"
            Gdip_TextToGraphics(_gfx, this.curIndex, _fontOpts, _fontName, _w, _h)
            newPos := this.NewIndexPos()
            _retVal := UpdateLayeredWindow(this.gui.Hwnd, _hdc, newPos.x, newPos.y, _w, _h)
            SelectObject(_hdc, _obm)
            DeleteObject(_hbm)
            DeleteDC(_hdc)
            Gdip_DeleteGraphics(_gfx)
            Return _retVal
        }
        Show(stepDuration:=15) {
            if this.firstDisplay
                this.MatchParentGuiPos(True)
            else this.gui.Show("NA")
            currStep := 0
            this.interruptFade := False
            SetTimer Step, stepDuration
            Step(*) {
                if !this.interruptFade {
                    currStep := currStep + 1
                    currOp := this.fadeStepsEnum[currStep]
                    if Integer("0x" currOp) >= Integer("0x" this.opacity)
                        currOp := this.opacity, SetTimer(,0)
                            , SetTimer(this.Bound_Hide, -2000)
                    this.PaintGui(currOp)
                } else SetTimer(,0)
            }
        }
        Hide() {
            SetTimer(this.Bound_Hide, 0)
            this.interruptFade := True
            this.PaintGui("00")
            this.gui.Hide()
        }
        NewIndexPos() {
            this.parentGui.GetPos(&px, &py, &pw, &ph)
            Return { x: px+pw-this.width, y: py+ph-this.height }
        }
        MatchParentGuiPos(_show:=False, _hide:=False) {
            uFlags := (SWP_NOACTIVATE:=0x0010)|(SWP_NOSIZE:=0x0001)
            uFlags := (_show) ? (uFlags|(SWP_SHOWWINDOW:=0x0040))
                    : (_hide) ? (uFlags|(SWP_HIDEWINDOW:=0x0080)) : uFlags
            newPos := this.NewIndexPos()
            DllCall("SetWindowPos", "Ptr", this.gui.Hwnd
                                  , "Ptr", -1
                                  , "Int", newPos.x, "Int", newPos.y
                                  , "Int", 0, "Int", 0
                                  , "UInt", uFlags)
        }
    }
}