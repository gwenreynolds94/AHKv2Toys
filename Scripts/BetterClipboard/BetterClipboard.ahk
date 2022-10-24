#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>
#Include <Gdip_v2Ex>
#Include BCManageConf.ahk
#Include ..\Lib\SciConstants.ahk

SplitPath A_ScriptDir, &_, &parentDir
scint := DllCall("LoadLibrary", "Str", parentDir "\Lib\Scintilla.dll", "Ptr")
stdo scint

OnExit FreeScintilla
FreeScintilla(*) {
    DllCall("FreeLibrary", "Ptr", scint)
}

if A_ScriptName="BetterClipboard.ahk" {
    RunBC()
}
RunBC() {
    app:=BC_App()
}


Scendilla(msg, wparam:=0, lparam:=0, hwnd:="") {
    static init := False
         , DirectFunction := ""
         , DirectPointer  := ""
    if !init and hwnd {
        init := True
        DirectFunction := SendMessage(SCI_GETDIRECTFUNCTION, 0, 0,, "ahk_id " hwnd)
        DirectPointer  := SendMessage(SCI_GETDIRECTPOINTER, 0, 0,, "ahk_id " hwnd)
        Return
    } else if !init and !hwnd
        Return
    Return DllCall(DirectFunction
                , "UInt", DirectPointer
                , "Int", msg
                , "UInt", wparam
                , "UInt", lparam)
}

Class ScEdit {
    static WRAPMODES := Map("none", SC_WRAP_NONE
                          , "char", SC_WRAP_CHAR
                          , "whitespace", SC_WRAP_WHITESPACE
                          , "word", SC_WRAP_WORD)
         , ctrl := {}
    ctrl := {}
    gui  := {}
    __New(guiParent, options:="") {
        this.gui := guiParent
        this.ctrl := this.gui.Add("Custom", "ClassScintilla " options)
        Scendilla 0, 0, 0, this.ctrl.Hwnd
        this.Style := ScEdit.Style()

    }

    WordWrap {
        Get {
            mode := Scendilla(SCI_GETWRAPMODE)
            for modeName, modeInt in ScEdit.WRAPMODES
                if mode = modeInt
                    Return modeName
        }
        Set {
            if ScEdit.WRAPMODES.Has(StrLower(Value))
                Scendilla SCI_SETWRAPMODE, ScEdit.WRAPMODES[StrLower(Value)]
        }
    }

    /** @prop {Boolean} MultipleSelection */
    MultipleSelection {
        Get => Scendilla(SCI_GETMULTIPLESELECTION)
        Set => Scendilla(SCI_SETMULTIPLESELECTION, Value)
    }

    /** @prop {String} Text */
    Text {
        Get {
            nLen := Scendilla(SCI_GETLENGTH)
            buf := Buffer(nLen+1)
            Scendilla SCI_GETTEXT, nLen, buf.Ptr
            Return StrGet(buf,,"UTF-8")
        }
    }

    Class Style {
        __New() {
            this.Selection := ScEdit.Style.Selection()
            this.Caret := ScEdit.Style.Caret()
        }

        Background {
            Get => Scendilla(SCI_STYLEGETBACK)
            Set {
                Scendilla SCI_STYLESETBACK, STYLE_DEFAULT, Value
                Scendilla SCI_STYLECLEARALL
            }
        }

        Class Caret {
            __New() {
                this.Line := ScEdit.Style.Caret.Line()
            }
            Class Line {
                Background {
                    Get => Scendilla(SCI_GETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK)
                    Set => Scendilla(SCI_SETELEMENTCOLOUR, SC_ELEMENT_CARET_LINE_BACK, Value)
                }
            }
        }
        
        Class Selection {
            Background {
                Get => Scendilla(SCI_GETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK)
                Set => Scendilla(SCI_SETELEMENTCOLOUR, SC_ELEMENT_SELECTION_BACK, Value)
            }
        }
    }
    Ctrl[Name:="", Params*] {
        Get { 
            if !Name
                Return ScEdit.ctrl 
            Return ScEdit.ctrl.%Name%
        }
        Set {
            if !Name
                Return ScEdit.ctrl := Value
            Return ScEdit.ctrl.%Name% := Value
        }
    }
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
                   . "h" this.guiSize.h - this.border*2 
    editBG        := 0xFFEEDD

    __New() {
        this.gui := Gui("-Caption +AlwaysOnTop")
        this.gui.BackColor := 0x7FB089
        this.bgPic := this.gui.Add("Picture", "0xE x0 y0 " this.sizeOpts)
        ; this.edit  := this.gui.Add("Edit", this.editOpts)
        this.edit := ScEdit(this.gui, "w300 h300 " this.editOpts)
        this.edit.Style.Background := this.editBG
        this.edit.WordWrap := "word"
        this.edit.MultipleSelection := True
        
        this.gui.Show("x" A_ScreenWidth " " this.sizeOpts)
        WinSetTransparent this.opacity, this.gui
        this.indexGui := BC_App.IndexOverlay(this.gui, 110+this.border, 36+this.border)
        this.Hide()

        Hotkey "F8", (*)=> ExitApp()
        Hotkey "F9", ObjBindMethod(this, "GetEditValue")
        HotIfWinactive("ahk_id " this.gui.Hwnd)
        Hotkey "PgDn", ObjBindMethod(this.indexGui, "NavigateClips")
        Hotkey "PgUp", ObjBindMethod(this.indexGui, "NavigateClips")
        HotIf
    }

    GetEditValue(*) {
        stdo "something"
    }

    Show(stepDuration:=10) {
        this.gui.Show("Center")
        this.indexGui.tmpIndex := this.indexGui.curIndex
        Hotkey "<#c", ObjBindMethod(this, "On_LWinC_Down", "Hide")
        stepSize := this.opacity/this.fadeSteps
        currStep := 0
        this.interruptFade := False
        SetTimer Step, stepDuration
        Step(*) {
            currStep += 1
            currOp := currStep*stepSize
            if !this.interruptFade {
                if (currOp >= this.opacity) {
                    currOp:=this.opacity, this.indexGui.Show(24), SetTimer(,0)
                }
                WinSetTransparent Integer(currOp), this.gui
            } else SetTimer(,0)
        }
    }

    Hide() {
        this.interruptFade := True
        this.indexGui.Hide(0)
        WinSetTransparent 0, this.gui
        this.gui.Hide()
        Hotkey "<#c", ObjBindMethod(this, "On_LWinC_Down", "Show")
    }

    On_LWinC_Down(_funcName, *) {
        Hotkey("*c", (*)=>""), Hotkey("LWin", (*)=>"")
        shortPress:=KeyWait("c", "T0.75")
        if !shortPress and (_funcName="Show") {
            SendMessage(0x0301,,, (ctrl:=ControlGetFocus("A")) 
                                       ? ctrl : WinExist("A"))
        } else if !shortPress and (_funcName="Hide") {
            A_Clipboard := this.edit.Text
            stdo this.edit.Text
        }
        this.%_funcName%()
        While (GetKeyState("c") or GetKeyState("LWin")) {
            Sleep(10)
        } Hotkey("*c", "Off"), Hotkey("LWin", "Off")
    }


    Class IndexOverlay {

        conf          := {}
        curIndex      := 0
        tmpIndex      := 0
        maxIndex      := 0
        gdipToken     := 0x0
        parentGui     := {}
        width         := 0
        height        := 0
        opacity       := "00"
        recentOpacity := "00"
        currStep      := 1
        fontColor     := "FFFFFF"
        fontName      := "Courier Prime"
        fadeStepsEnum := ["00", "11", "22", "33", "44", "55", "66", "77"
                        , "88", "99", "AA", "BB", "CC", "DD", "EE", "FF"]
        showDuration  := 1000
        firstDisplay  := True
        interruptShow := False
        interruptHide := False

        __New(_pGui, _w, _h, _op:="DD") {
            this.conf := BC_Config
            this.tmpIndex := this.curIndex := BC_Config.CurIndex
            this.maxIndex := BC_Config.MaxIndex
            WS_EX_STATICEDGE:="E0x00020000" ; little baby window edge
            WS_EX_NOACTIVATE:="E0x08000000" ; prevents window getting focus
            this.width := _w, this.height := _h
            this.parentGui := _pGui, this.recentOpacity:=this.opacity:=_op
            this.fontColor := this.parentGui.BackColor
            this.gui := Gui("+" WS_EX_NOACTIVATE " +E0x80000 "
                          . "-Caption +Owner" _pGui.Hwnd)
            this.gui.Show("x" 0 " y" (-5)-_h " w" _w " h" _h " NA")

            GdipShutdownFunc(_token, *) {
                if (_token) {
                    Gdip_Shutdown(_token)
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


        Show(stepDuration:=20) {
            Static currStep := 1
            if this.firstDisplay
                this.MatchParentGuiPos(True)
            else this.gui.Show("NA")
            this.interruptShow := False
            fadeProgress := Integer("0x" this.recentOpacity)
            minProgress  := Integer(Number("0x" this.opacity)*0.75)
            if (fadeProgress >= minProgress) {
                this.interruptShow:=True
                SetTimer(this.Bound_Hide, 0-this.showDuration)
                this.PaintGui(this.opacity)
            } else SetTimer(Step, stepDuration)
            currStep := 1
            Step(*) {
                if !this.interruptShow {
                    currOp := this.fadeStepsEnum[currStep]
                    if Integer("0x" currOp) >= Integer("0x" this.opacity) {
                        currOp := this.opacity
                        SetTimer(,0)
                        SetTimer(this.Bound_Hide, 0-this.showDuration)
                    }
                    this.PaintGui(currOp)
                    currStep := currStep + 1
                } else SetTimer(,0)
            }
        }

        Hide(stepDuration:=20) {
            Static currStep := 1
            SetTimer(this.Bound_Hide, 0)
            this.interruptHide := False
            this.interruptShow := True
            currStep := 1
            if (stepDuration <= 0) {
                this.PaintGui(this.fadeStepsEnum[1])
                SetTimer(this.Bound_Hide,0)
                this.gui.Hide()
            }
            SetTimer(Step, stepDuration)
            Step(*) {
                if !this.interruptHide {
                    currOp := this.fadeStepsEnum[this.fadeStepsEnum.Length-currStep]
                    if Integer("0x" currOp) <= Integer("0x" this.fadeStepsEnum[1]) {
                        currOp := this.fadeStepsEnum[1], this.PaintGui(currOp)
                        SetTimer(,0), this.gui.Hide()
                    } else this.PaintGui(currOp), currStep := currStep + 1
                } else SetTimer(,0)
            }
        }

        NavigateClips(ThisHotkey, *) {
            if (ThisHotkey="PgDn") and ((this.tmpIndex--) < 1)
                this.tmpIndex := this.maxIndex
            else if (ThisHotkey="PgUp") and ((this.tmpIndex++) > this.maxIndex)
                this.tmpIndex := 1
            this.interruptHide := True
            this.Show(10)
        }

        PaintGui(_opacity) {
            this.recentOpacity:=_opacity
            _hbm := CreateDIBSection(_w:=this.width, _h:=this.height)
            _hdc := CreateCompatibleDC()
            _obm := SelectObject(_hdc, _hbm)
            _gfx := Gdip_GraphicsFromHDC(_hdc)
            _fontName  := (Gdip_FontFamilyCreate(this.fontName)) ? this.fontName : "Arial"
            _fontColor := _opacity . this.fontColor
            _fontOpts  := "x5p y5p w90p h90p vCenter c" _fontColor " r4 s30"
            Gdip_TextToGraphics(_gfx, this.tmpIndex, _fontOpts, _fontName, _w, _h)
            newPos  := this.NewIndexPos()
            _retVal := UpdateLayeredWindow(this.gui.Hwnd, _hdc, newPos.x, newPos.y, _w, _h)
            SelectObject(_hdc, _obm)
            DeleteObject(_hbm)
            DeleteDC(_hdc)
            Gdip_DeleteGraphics(_gfx)
            Return _retVal
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