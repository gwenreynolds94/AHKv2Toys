#Requires AutoHotkey v2.0-rc
#Warn All, StdOut
#SingleInstance Force

#Include *i <DEBUG\DBT>
#Include *i <GdipLib\Gdip_Custom>

#Include *i ..\..\Lib\DEBUG\DBT.ahk
#Include *i ..\..\Lib\GdipLib\Gdip_Custom.ahk

if !_ptoken := Gdip_Startup()
{
    MsgBox "GdiPlus failed to start"
    ExitApp()
}
OnExit(ExitFunc)

ExitFunc(exit_reason, exit_code) {
    global _ptoken
    Gdip_Shutdown(_ptoken)
}



Class ZoomView {

    _view_key := ""
    _hide_key := ""
    zoom := 2
    crop_width := 400
    crop_height := 300

    /** @prop {Gui} _g */
    gui := {}

    __New() {
        this.SetupGui()
    }

    SetupGui(*) {
        _gui := Gui("+E0x80000 -Caption +AlwaysOnTop +ToolWindow +OwnDialogs"
                  , "ZoomView"
                  , this)
        _gui.OnEvent("Escape", "Hide")
        _gui.OnEvent("Close" , "Hide")
        _gui.Show("NA")
        this.gui := _gui
    }

    Hide(*) {
    }

    NewView(*) {
        screen_bm := Gdip_BitmapFromScreen()
        MouseGetPos(&mpos_x, &mpos_y)
        crop_width := ((mpos_x + this.crop_width) <= A_ScreenWidth) ? this.crop_width :
                      (this.crop_width + (A_ScreenWidth - mpos_x - this.crop_width))
        crop_height := ((mpos_y + this.crop_height) <= A_ScreenHeight) ? this.crop_height :
                       (this.crop_height + (A_ScreenHeight - mpos_y - this.crop_height))

    }

    ViewKey {
        Get => this._view_key


        Set {
        }
    }

    HideKey {
        Get => this._view_key
        Set {
        }
    }

}



;
;
;
;
; /** ### `"+E0x80000"` :: Allows `UpdateLayeredWindow` to work */
; __g := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
; __g.OnEvent("close", gui_close)
; __g.OnEvent("escape", gui_close)
; __g.Show("NA")
;
; gui_close(*) {
;     ExitApp()
; }
;
; _hwnd := __g.Hwnd
;
; _scrbm := Gdip_BitmapFromScreen()
;
; if not _scrbm
; {
;     MsgBox("Could not load bitmap of window")
;     ExitApp
; }
;
; _width := Gdip_GetImageWidth(_scrbm), _height := Gdip_GetImageHeight(_scrbm)
; ;
; _hbm := CreateDIBSection(_width // 2, _height // 2)
; ;
; _hdc := CreateCompatibleDC()
; ;
; _obm := SelectObject(_hdc, _hbm)
;
; _gfx := Gdip_GraphicsFromHDC(_hdc)
;
; ; Gdip_GraphicsFromHWND(_hwnd)
;
; Gdip_SetInterpolationMode(_gfx, 7)
;
; Gdip_DrawImage(_gfx, _scrbm, 0, 0, _width // 2, _height // 2, 0, 0, _width, _height)
;
; UpdateLayeredWindow(_hwnd, _hdc, 0, 0, _width // 2, _height // 2)
;
; SelectObject(_hdc, _obm)
;
; DeleteObject(_hbm)
;
; DeleteDC(_hdc)
;
; Gdip_DeleteGraphics(_gfx)
;
; Gdip_DisposeImage(_scrbm)
