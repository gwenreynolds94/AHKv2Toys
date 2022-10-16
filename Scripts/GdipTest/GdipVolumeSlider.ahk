#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>
#Include Gdip_Custom.ahk

if !gtoken:=Gdip_Startup() {
    MsgBox "GdiPlus failed to start"
    ExitApp
}
OnExit RunOnExit


t_gui := Gui("-DPIScale", "GDI+ ProgBar", EvtSink)
t_gui.OnEvent("Close", "Gui_Close")
t_gui.MarginX := t_gui.MarginY := 12

t_slider_base := t_gui.Add("Picture", "w256 h48 0xE")
t_slider_knob := t_gui.Add("Picture", "w24 h24 xp+12 yp+12 0xE")
t_slider_knob.OnEvent("Click", "t_slider_knob_Click")

t_gui.Show("AutoSize")

SetSliderBaseImage(t_slider_base,0xFFDDDDDD,0x00000000, 8,, 4)
SetSliderKnobImage(t_slider_knob)


SetSliderBaseImage(slider_base , fg:=0xFF000000  , bg:=0x00000000
                 , thickness:=8, side_padding:=12, border_radius:=2) {
    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;: Create Brushes ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:
    fg_brush := Gdip_BrushCreateSolid(fg)
    bg_brush := Gdip_BrushCreateSolid(bg)
    ;:;:;:;:;:;:;:;:;:;:;:;:;: Get slider dimensions ;:;:;:;:;:;:;:;:;:;:;:;:;:;
    slider_base.GetPos(&_x, &_y, &slider_width, &slider_height)
    ;:;:;:;:;:;:;:;:;:;:;:; Initialize bitmap & graphics ;:;:;:;:;:;:;:;:;:;:;:;
    sb_bitmap := Gdip_CreateBitmap(slider_width, slider_height)
    sb_graphics := Gdip_GraphicsFromImage(sb_bitmap)
    Gdip_SetSmoothingMode sb_graphics, 4
    ;:;:;:;:;:;:;:;:;:;:; Paint background and foreground ;:;:;:;:;:;:;:;:;:;:;:
    Gdip_FillRectangle(sb_graphics, bg_brush, 0, 0, slider_width, slider_height)
    Gdip_FillRoundedRectangle(sb_graphics                   ; graphics handle
                            , fg_brush                      ; brush
                            , side_padding                  ; x position
                            , slider_height/2 - thickness/2 ; y position
                            , slider_width - side_padding*2 ; width
                            , thickness                     ; height
                            , border_radius)                ; border radius
    ;:;:;:;:;:;:;:;:;: Create HBITMAP and set as slider image ;:;:;:;:;:;:;:;:;:
    sb_HBITMAP := Gdip_CreateHBITMAPFromBitmap(sb_bitmap)
    SetImage(slider_base.Hwnd, sb_HBITMAP)
    ;:;:;:;:;:;:;:; Delete brushes, graphics, image, and bitmaps :;:;:;:;:;:;:;:
    Gdip_DeleteBrush fg_brush
    Gdip_DeleteBrush bg_brush
    Gdip_DeleteGraphics sb_graphics
    Gdip_DisposeImage sb_bitmap
    DeleteObject sb_HBITMAP
}

SetSliderKnobImage(slider_knob, fg:=0xFFBFCFEF) {
    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Create brush ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
    fg_brush := Gdip_BrushCreateSolid(fg)
    ;:;:;:;:;:;:;:;:;:;:;:;:;:; Get knob dimensions ;:;:;:;:;:;:;:;:;:;:;:;:;:;:
    slider_knob.GetPos(&_x, &_y, &knob_width, &knob_height)
    ;:;:;:;:;:;:;:;:;:;:;: Initialize bitmap and graphics ;:;:;:;:;:;:;:;:;:;:;:
    knob_bitmap := Gdip_CreateBitmap(knob_width, knob_height)
    knob_graphics := Gdip_GraphicsFromImage(knob_bitmap)
    Gdip_SetSmoothingMode knob_graphics, 4
    ;:;:;:;:;:;:;:;:;:;:;:;:;:;:; Paint foreground ;:;:;:;:;:;:;:;:;:;:;:;:;:;:;
    Gdip_FillEllipse knob_graphics, fg_brush, 0, 0, knob_width, knob_height
    ;:;:;:;:;:;:;:;:;:; Create HBITMAP and set as knob image ;:;:;:;:;:;:;:;:;:;
    Gdip_SaveBitmapToFile(knob_bitmap, A_ScriptDir "\tbm.png")
    knob_HBITMAP := Gdip_CreateHBITMAPFromBitmap(knob_bitmap)
    SetImage(slider_knob.Hwnd, knob_HBITMAP)
    ;:;:;:;:;:;:;:;: Delete brush, graphics, image, and bitmaps ;:;:;:;:;:;:;:;:
    Gdip_DeleteBrush fg_brush
    Gdip_DeleteGraphics knob_graphics
    Gdip_DisposeImage knob_bitmap
    DeleteObject knob_HBITMAP
}


Class EvtSink {
    static Gui_Close(*) {
        ExitApp
    }
    static t_slider_knob_Click(gCtrl, gInfo) {
        MouseGetPos &mouse_starting_x
        ControlGetPos &ctrl_starting_x, &_y, &_w, &_h, gCtrl
    
        UpdateKnobPos() {
            if !GetKeyState("LButton")
                SetTimer , 0
            else {
                MouseGetPos &mouse_current_x
                ControlMove (mouse_current_x-mouse_starting_x)+ctrl_starting_x,,,, gCtrl
            }
        }
    
        SetTimer UpdateKnobPos, 10
    }
}

RunOnExit(*) {

}
