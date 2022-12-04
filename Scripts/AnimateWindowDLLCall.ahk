#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DEBUG\DBT.ahk

/**
 * @var {Integer WinAPI Constant} AW_ACTIVATE
 * |AW_ACTIVATE|
 * -----
 *      := 0x00020000
 * -----
 *      |> Activates the window. 
 *      |> Do not use this value with AW_HIDE.
 */
AW_ACTIVATE := 0x00020000
/**
 * @var {Integer WinAPI Constant} AW_BLEND
 * |AW_BLEND|
 * -----
 *      := 0x00080000
 * -----
 *      |> Uses a fade effect. 
 *      |> This flag can be used only if hwnd is a top-level window.
 */
AW_BLEND := 0x00080000
/**
 * @var {Integer WinAPI Constant} AW_CENTER
 * |AW_CENTER|
 * -----
 *      := 0x00000010
 * -----
 *      |> Makes the window appear to collapse inward if AW_HIDE is used 
 *      |> or expand outward if the AW_HIDE is not used. The various direction 
 *      |> flags have no effect.
 */
AW_CENTER := 0x00000010
/**
 * @var {Integer WinAPI Constant} AW_HIDE
 * |AW_HIDE|
 * -----
 *      := 0x00010000
 * -----
 *      |> Hides the window. By default, the window is shown.
 */
AW_HIDE := 0x00010000
/**
 * @var {Integer WinAPI Constant} AW_HOR_POSITIVE
 * |AW_HOR_POSITIVE|
 * -----
 *      := 0x00000001
 * -----
 *      |> Animates the window from left to right. 
 *      |> This flag can be used with roll or slide animation. 
 *      |> It is ignored when used with AW_CENTER or AW_BLEND.
 */
AW_HOR_POSITIVE := 0x00000001
/**
 * @var {Integer WinAPI Constant} AW_HOR_NEGATIVE
 * |AW_HOR_NEGATIVE|
 * -----
 *      := 0x00000002
 * -----
 *      |> Animates the window from right to left. 
 *      |> This flag can be used with roll or slide animation. 
 *      |> It is ignored when used with AW_CENTER or AW_BLEND.
 */
AW_HOR_NEGATIVE := 0x00000002
/**
 * @var {Integer WinAPI Constant} AW_SLIDE
 * |AW_SLIDE|
 * -----
 *      := 0x00040000
 * -----
 *      |> Uses slide animation. By default, roll animation is used. 
 *      |> This flag is ignored when used with AW_CENTER.
 */
AW_SLIDE := 0x00040000
/**
 * @var {Integer WinAPI Constant} AW_VER_POSITIVE
 * |AW_VER_POSITIVE|
 * -----
 *      := 0x00000004
 * -----
 *      |> Animates the window from top to bottom. 
 *      |> This flag can be used with roll or slide animation. 
 *      |> It is ignored when used with AW_CENTER or AW_BLEND.
 */
AW_VER_POSITIVE := 0x00000004
/** @var {Integer WinAPI Constant} AW_VER_NEGATIVE
 * |AW_VER_NEGATIVE|
 * -----  
 *     ::::=0x00000008
 * -----
 *       ::==< Animates the window from bottom to top.             >==::
 *       ::==< This flag can be used with roll or slide animation. >==::
 *       ::==< It is ignored when used with AW_CENTER or AW_BLEND. >==::
 */
AW_VER_NEGATIVE := 0x00000008

CS_DROPSHADOW:=0x0080

FADEOUT:=AW_HIDE|AW_SLIDE|AW_VER_NEGATIVE
FADEIN:=AW_ACTIVATE|AW_BLEND
CS_DROPSHADOW := 0x00020000
DLGFRAME := "0x400000"
WS_THICKFRAME := "0x40000"

tgui := Gui("+Resize -Caption -0x40000")
tedit := tgui.Add("Edit", "x5 y5 w700 h200")
tgui.Show("x10 y10 w" (A_ScreenWidth-40) " h400")
stdo DllCall("GetParent", "Ptr", tedit.Hwnd)
stdo tedit.Hwnd, tgui.Hwnd
; tgui.BackColor := "BBDDFF"
; gtoken:=Gdip_Startup()
; bgBrush := Gdip_BrushCreateSolid(0xFFFF0000)
classStyle := DllCall("SetClassLongPtrW", "Ptr", tedit.Hwnd, "Int", -26, "UPtr")
stdo classStyleSansShadow := classStyle & ~CS_DROPSHADOW
stdo DllCall("SetClassLongPtrW", "Ptr", tedit.Hwnd, "Int", -26, "Ptr", classStyleSansShadow, "UPtr")
; stdo DllCall("SetClassLongPtrW", "Ptr", tedit.Hwnd, "Int", -26, "Ptr", CS_DROPSHADOW, "UPtr")
; stdo DllCall("SetClassLongPtrW", "Ptr", tgui.Hwnd, "Int", -10, "Int", bgBrush, "UPtr")
stdo DllCall("RedrawWindow", "Ptr", tgui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x00000400|0x00000001|0x00000100|0x00000080)
; Gdip_Shutdown(gtoken)
SetTimer (*)=>DllCall("AnimateWindow", "Ptr", tedit.Hwnd, "Int", 500
                     ,"UInt", AW_HIDE|AW_CENTER, "Int"), -1000
SetTimer (*)=>DllCall("AnimateWindow", "Ptr", tgui.Hwnd, "Int", 500
                     ,"UInt", FADEOUT, "Int")&&ExitApp(), -1500


F8::ExitApp
; #Include <GdipLib\Gdip_v2Ex>