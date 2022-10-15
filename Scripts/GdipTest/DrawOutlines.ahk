#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk
#Include Gdip_Custom.ahk


if !gtoken:=Gdip_Startup() {
    MsgBox "GdiPlus failed to start"
    ExitApp
}
OnExit RunOnExit

daWidth := 600, daHeight := 500

tGui := Gui("-Caption +E0x80000 +LastFound +OwnDialogs +Owner")
tGui.Show("w" daWidth " h" daHeight)

gdiBitmap := CreateDIBSection(daWidth, daHeight)
dCtx := CreateCompatibleDC()
dcBitmap := SelectObject(dCtx, gdiBitmap)
gfx := Gdip_GraphicsFromHDC(dCtx)
Gdip_SetSmoothingMode gfx, 4


gPen := Gdip_CreatePen(0xFFFF0000, 3)
Gdip_DrawEllipse(gfx, gPen, 100, 50, 100, 300)
Gdip_DeletePen gPen

gPen := Gdip_CreatePen(0x660000FF, 10)
Gdip_DrawRectangle(gfx, gPen, 250, 80, 300, 200)
Gdip_DeletePen gPen

UpdateLayeredWindow tGui.Hwnd, dCtx, 0, 0, daWidth, daHeight

SelectObject dCtx, dcBitmap
DeleteObject gdiBitmap
DeleteDC dCtx
Gdip_DeleteGraphics gfx


RunOnExit(*) {
    Gdip_Shutdown gtoken
}
