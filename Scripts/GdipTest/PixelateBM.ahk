#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk
#Include Gdip_Custom.ahk

if !ptoken := Gdip_Startup() {
    MsgBox "GdiPlus failed to start"
    ExitApp
}
OnExit RunOnExit

width := A_ScreenWidth-50, height := A_ScreenHeight-50
tGui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
tGui.Show("NA")

hwnd := WinExist()


if FileExist("..\iTunesWidget\resources\currentTrack.jpg") ~= "A|N"
    upBitmap := Gdip_CreateBitmapFromFile("..\iTunesWidget\resources\currentTrack.jpg")
if !upBitmap {
    MsgBox "Could not load image"
    ExitApp
}

bmWidth := Gdip_GetImageWidth(upBitmap)
bmHeight := Gdip_GetImageHeight(upBitmap)

upBitmapOut := Gdip_CreateBitmap(bmWidth, bmHeight)

uhbm := CreateDIBSection(bmWidth, bmHeight)
uhdc := CreateCompatibleDC()
uobm := SelectObject(uhdc, uhbm)

uG := Gdip_GraphicsFromHDC(uhdc)

OnMessage(0x201, WM_LBUTTONDOWN)

UpdateLayeredWindow(hwnd, uhdc, (A_ScreenWidth-bmWidth)//2, (A_ScreenHeight-bmHeight)//2, bmWidth, bmHeight)

SetTimer Update, 50

v := 0, dir := 0
Update() {
    global
    if (v <= 1)
        v := 1, dir := !dir
    else if (v >= 30)
        v := 30, dir := !dir

    Gdip_PixelateBitmap(upBitmap, &upBitmapOut, dir ? ++v : --v)
    Gdip_DrawImage(uG, upBitmapOut, 0, 0, bmWidth, bmHeight, 0, 0, bmWidth, bmHeight)

    UpdateLayeredWindow(hwnd, uhdc)
}

WM_LBUTTONDOWN(wparam, lparam, msg, _hwnd) {
    PostMessage 0xA1, 2
}

; hbm := CreateDIBSection(width, height)
; hdc := CreateCompatibleDC()
; obm := SelectObject(hdc, hbm)
; G   := Gdip_GraphicsFromHDC(hdc)
; Gdip_SetSmoothingMode(G, 4)
; pBrush := Gdip_BrushCreateSolid(0xFFFF0000)
; Gdip_FillEllipse(G, pBrush, 100, 50, 200, 300)
; Gdip_DeleteBrush(pBrush)
; UpdateLayeredWindow(hwnd, hdc, 0, 0, width, height)
; SelectObject(hdc, obm)
; DeleteObject(hbm)
; DeleteDC(hdc)
; Gdip_DeleteGraphics(G)


RunOnExit(*) {
    global
    Gdip_DisposeImage(upBitmapOut)
    Gdip_DisposeImage(upBitmap)
    SelectObject(uhdc, uobm)
    DeleteObject(uhbm)
    DeleteDC(uhdc)
    Gdip_DeleteGraphics(uG)
    Gdip_Shutdown(pToken)
}

F8::ExitApp