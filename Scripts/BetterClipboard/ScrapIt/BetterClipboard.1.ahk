#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include *i <DBT>
#Include *i <Gdip_v2Ex>

#Include *i ..\..\Lib\
#Include *i DEBUG\DBT.ahk
#Include *i Gdip_v2Ex.ahk


if A_ScriptName="BetterClipboard.1.ahk" {
    RunBC()
    Hotkey "F8", (*)=>ExitApp()
}
RunBC() {
    app:=BC_App()
}

Class BC_App {
    /** @prop {Gui} gui */
    gui := {}

    /** @prop {BC_App.Gdip} gdip */
    gdip := {}

    /** @prop {Object} gui_size */
    gui_size  := { w: 675, h: 450 }

    /** @prop {String} size_opts */
    size_opts := "w" this.gui_size.w " "
               . "h" this.gui_size.h

    opacity := "200"
    border := 5
    borderRadius := 8
    edit_opts := "x" this.border " y" this.border    " "
               . "w" this.gui_size.w - this.border*2 " "
               . "h" this.gui_size.h - this.border*2 " BackgroundDDEEFF 0x100"
    indexPic_pos  := { x: 50,  y: 50 }
    indexPic_size := { w: 200, h: 75 }
    indexPic_opts := "x" this.indexPic_pos.x  " y" this.indexPic_pos.y  " "
                   . "w" this.indexPic_size.w " h" this.indexPic_size.h " "
                   . "0xE BackgroundTrans"
    __New() {
        this.gui := Gui("-Caption +AlwaysOnTop")
        ; this.gui.BackColor := "ADAFAE"
        ; WinSetTransColor this.gui.BackColor, this.gui
        this.gui.BackColor := "7FB089"
        WinSetTransparent this.opacity, this.gui
        this.gui.OnEvent("Close", ObjBindMethod(this, "On_Gui_Close"))

        this.bgPic := this.gui.Add("Picture", "0xE x0 y0 " this.size_opts)
        this.edit  := this.gui.Add("Edit", this.edit_opts)
        this.indexPic := this.gui.Add("Picture", this.indexPic_opts)
        DllCall("SetParent", "Ptr", this.indexPic.Hwnd, "Ptr", this.edit.Hwnd)
        ; DllCall("SetClassLongPtrW", "Ptr", this.indexPic.Hwnd
        ;                           , "Int", -26, "Ptr", 0x0080|0x4000, "UPtr")
        ; uFlags := (SWP_NOACTIVATE:=0x0010)|(SWP_NOSIZE:=0x0001)|(SWP_NOMOVE := 0x0002)
        ; stdo DllCall("SetWindowPos", "Ptr", this.indexPic.Hwnd
        ;                       , "Int", -1
        ;                       , "UInt", 0, "UInt", 0
        ;                       , "UInt", 0, "UInt", 0
        ;                       , "UInt", uFlags)
        ; stdo DllCall("SetWindowPos", "Ptr", this.edit.Hwnd
        ;                       , "Int", -2
        ;                       , "UInt", 0, "UInt", 0
        ;                       , "UInt", 0, "UInt", 0
        ;                       , "UInt", uFlags)
; 
        this.gdip := BC_App.Gdip()
        this.gui.Show(this.size_opts)
        Sleep 250
        this.gui.Hide()
        Sleep 250
        uFlags := (SWP_NOSIZE:=0x0001)|(SWP_NOMOVE := 0x0002)|(SWP_SHOWWINDOW:=0x0040)
        DllCall("SetWindowPos", "Ptr", this.gui.Hwnd
                              , "Int", 0
                              , "Int", this.border, "Int", this.border
                              , "Int", this.gui_size.w, "Int", this.gui_size.h
                              , "UInt", uFlags, "Int")
        ; this.PaintBackground()
        this.PaintIndex
        ; for ctrl in this.gui
        ;     ctrl.Redraw
        ; SetTimer ObjBindMethod(this, "RedrawCtrls"), 1000
    }
    ; RedrawCtrls() {
    ;     for ctrl in this.gui
    ;         ctrl.Redraw
    ; }
    __Delete() {
        
    }
    On_Gui_Close(gObj){
        ExitApp
    }

    /** @param {Integer} Options
     *      Specify **0** for toggle, **1** to show, and **-1** to hide */
    Toggle(Options:=0) {

    }

    PaintBackground() {
        gdip := this.gdip
        bgCanvas := gdip.CreateCanvas(this.gui_size.w, this.gui_size.h)
        bgCanvas.Smoothing := 6
        gdip.CreateBrushPalette()
        bgCanvas.FillBGRect(gdip.ahkgreen_light)
        bgCanvas.FillRect(gdip.gray_light, this.border, this.border
                                   , this.gui_size.w - this.border*2
                                   , this.gui_size.h - this.border*2)
        ; bgCanvas.FillBGRoundedRect(gdip.ahkgreen_light, this.borderRadius)
        ; bgCanvas.FillRoundedRect(gdip.gray_light
        ;                        , this.border, this.border
        ;                        , this.gui_size.w - this.border*2
        ;                        , this.gui_size.h - this.border*2
        ;                        , this.borderRadius-2)
        bgCanvas.SetImage this.bgPic.Hwnd
        gdip.BurnBrushes()
        bgCanvas.Dispose()
    }

    PaintIndex() {
        gd:=this.gdip
        idxWidth := this.indexPic_size.w, idxHeight := this.indexPic_size.h
        idxCvs := gd.CreateCanvas(idxWidth, idxHeight)
        gd.CreateBrushPalette
        idxCvs.FillBGRoundedRect(gd.black_trans50)
        idxCvs.SetImage this.indexPic.Hwnd
        gd.BurnBrushes
        idxCvs.Dispose
    }

    ; A class whose purpose is to store gdip components and share them among
    ;       methods of a class as well as provide management of Gdip library
    ;       and custom Gdip utilites
    Class Gdip {
        gdip_token := 0x0
        brush_palette := Map()
        default_brush_palette := Map(
                       "black", 0xFF000000
          ,    "black_trans50", 0xAA000000
          ,            "white", 0xFFFFFFFF
          ,    "white_trans50", 0xAAFFFFFF
          ,       "gray_light", 0xFFCCCCCC
          ,             "gray", 0xFFAAAAAA
          ,        "gray_dark", 0xFF555555
          ,   "ahkgreen_light", 0xFF7FB089
          ,         "ahkgreen", 0xFF4BB560
          ,    "ahkgreen_dark", 0xFF49614E
          , "ahkgreen_trans50", 0xAA4BB560
        )
        __New() {
            if !this.gdip_token:=Gdip_Startup()
                MsgBox "Gdip failed to start"
            else OnExit (*)=> ObjBindMethod(this, "__Delete").Call()
        }
        __Delete() {
            if this.brush_palette.Count
                this.BurnBrushes()
            if this.gdip_token
                Gdip_Shutdown(this.gdip_token)
        }

        CreateBrushPalette(_Name_Value_Pairs*) {
            this.brush_palette := Map(), palette_set := False
            if !_Name_Value_Pairs.Length
                this.brush_palette := this.default_brush_palette, palette_set := True
            else if (_Name_Value_Pairs[1] is Map)
                this.brush_palette := _Name_Value_Pairs[1], palette_set := True
            if palette_set
                for _name, _color in this.brush_palette
                    this.%_name% := Gdip_BrushCreateSolid(_color)
            else if !Mod(_Name_Value_Pairs, 2)
                for _index, _value in _Name_Value_Pairs
                    if Mod(_index, 2)
                        this.%_value% := Gdip_BrushCreateSolid(
                            this.brush_palette[%_value%] :=
                                _Name_Value_Pairs[_index+1]   )
            Return this.brush_palette
        }

        BurnBrushes() {
            for _name, _color in this.brush_palette
                this.%_name% := ""
            this.brush_palette := Map()
        }

        Brush[_color] => Gdip_BrushCreateSolid(_color)

        /**
         * @param {Integer} _width
         * @param {Integer} _height
         * @return {BC_App.Gdip.Canvas}
         */
        CreateCanvas(_width, _height) {
            Return BC_App.Gdip.Canvas(this, _width, _height)
        }

        DisposeCanvas(_canvas) {
            _canvas.Dispose()
            _canvas:={}
        }

        Class Canvas {
            gdip:={}, pBitmap:=0x0, hBitmap:=0x0, gfx:=0x0
            width:=0, height:=0 , _smoothing:=6, margin:=0, bgBRadius:=15 
            __New(_gdip, _width, _height) {
                this.gdip := _gdip
                this.pBitmap := Gdip_CreateBitmap(this.width:=_width, this.height:=_height)
                this.gfx := Gdip_GraphicsFromImage(this.pBitmap)
                this.Smoothing := this._smoothing
            }
            __Delete() {
                this.Dispose()
            }

            Dispose(){
                Gdip_DeleteGraphics(this.gfx)
                Gdip_DisposeImage(this.pBitmap)
                DeleteObject(this.hBitmap)
            }

            FillRect(_pBrush, _x, _y, _w, _h) {
                Gdip_FillRectangle(this.gfx, _pBrush, _x, _y, _w, _h)
            }

            FillRoundedRect(_pBrush, _x, _y, _w, _h, _r) {
                Gdip_FillRoundedRectangle2(this.gfx, _pBrush, _x, _y, _w-1, _h-1, _r)
            }

            FillBGRect(_pBrush) {
                Gdip_FillRectangle this.gfx   , _pBrush
                                 , this.margin, this.margin
                                 , this.width  - this.margin*2
                                 , this.height - this.margin*2
            }

            FillBGRoundedRect(_pBrush, _bgBRadius:="") {
                _bgBRadius := (_bgBRadius) ? _bgBRadius : this.bgBRadius
                Gdip_FillRoundedRectangle2 this.gfx, _pBrush
                                         , this.margin, this.margin
                                         , this.width - this.margin*2 - 1
                                         , this.height - this.margin*2 - 1
                                         , _bgBRadius
            }

            SetImage(_hWnd) {
                this.hBitmap := Gdip_CreateHBITMAPFromBitmap(this.pBitmap)
                SetImage(_hWnd, this.hBitmap)
            }

            /**
             * @prop {Integer} Smoothing
             * 
             *      0  Default     
             *      1  HighSpeed   
             *      2  HighQuality 
             *      3  None        
             *      4  AntiAlias   
             *      5  AntiAlias8x4
             *      6  AntiAlias8x8
             */
            Smoothing {
                Get => this._smoothing
                Set => Gdip_SetSmoothingMode(this.gfx, this._smoothing:=Value)
            }
        }
    }
}