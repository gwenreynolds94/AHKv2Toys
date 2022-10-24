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

gWidth := 500, gHeight := 300
tGui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
tGui.Show("NA")
SetTimer (*)=> WinSetTransparent(100, tGui), -2000

gBitmap := CreateDIBSection(gWidth, gHeight)
devCtx := CreateCompatibleDC()
dcBitmap := SelectObject(devCtx, gBitmap)
gfx := Gdip_GraphicsFromHDC(devCtx)
Gdip_SetSmoothingMode gfx, 4

gBrush := Gdip_BrushCreateSolid(0x77000000)
Gdip_FillRoundedRectangle(gfx, gBrush, 50, 50, 400, 200, 25)
Gdip_DeleteBrush gBrush

UpdateLayeredWindow tGui.Hwnd, devCtx, (A_ScreenWidth-gWidth)//2, (A_ScreenHeight-gHeight)//2, gWidth, gHeight

WM_LBUTTONDOWN := 0x201
OnMessage(WM_LBUTTONDOWN, OnLButtonDown)

SelectObject devCtx, dcBitmap
DeleteObject gBitmap
DeleteDC devCtx


OnLButtonDown(wparam, lparam, msg, hwnd) {
    WM_NCLBUTTONDOWN := 0xA1, HTCAPTION := 2
    PostMessage WM_NCLBUTTONDOWN, HTCAPTION
}

RunOnExit(*) {
    Gdip_Shutdown gtoken
}

F8::ExitApp