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


tGui := Gui("-DPIScale", "GDI+ ProgBar", EvtSink)
tGui.OnEvent("Close", "Gui_Close")
tSlider := tGui.Add("Slider", "x10 y10 w400 Range0-100 vPercentage Tooltip", 50)
tSlider.OnEvent("Change", "Slider_Change")
tPicObj := tGui.Add("Picture", "x10 y+30 w400 h50 0xE vProgressBar")

tGui.Show("AutoSize")

Gdip_SetProgress(&gVar
               , _percent
               , _fg
               , _bg:=0x00000000
               , _txt:=""
               , _optStr:="x0p y15p s60p Center cff000000 r4 Bold"
               , _font:="Fira Code") {
    gVar.GetPos(&_x, &_y, &posW, &posH)
    _hwnd := gVar.Hwnd
    gBrushFront := Gdip_BrushCreateSolid(_fg)
    gBrushBack  := Gdip_BrushCreateSolid(_bg)
    gBM := Gdip_CreateBitmap(posW, posH)
    gfx := Gdip_GraphicsFromImage(gBM)
    Gdip_SetSmoothingMode gfx, 4
    
    Gdip_FillRectangle gfx, gBrushBack, 0, 0, posW, posH
    Gdip_FillRoundedRectangle gfx, gBrushFront, 4, 4, (posW-8)*(_percent/100), posH-8, (_percent >= 3) ? 3 : _percent
    Gdip_TextToGraphics gfx, (_txt != "") ? _txt : Round(_percent) "`%", _optStr, _font, posW, posH

    gHBitmap := Gdip_CreateHBITMAPFromBitmap(gBM)
    SetImage(_hwnd, gHBitmap)

    Gdip_DeleteBrush gBrushFront
    Gdip_DeleteBrush gBrushBack
    Gdip_DeleteGraphics gfx
    Gdip_DisposeImage gBM
    DeleteObject gHBitmap
}

Class EvtSink {
    static Gui_Close(*) {
        ExitApp
    }
    static Slider_Change(gCtrl, gInfo) {
        progBar := gCtrl.Gui["ProgressBar"]
        Gdip_SetProgress &progBar, gCtrl.Value, 0xFF0993EA, 0xFFBDE5FF, gCtrl.Value "`%"
    }
}

RunOnExit(*) {

}
