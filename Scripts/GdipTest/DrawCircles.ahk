#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\DBT.ahk
#Include Gdip_Custom.ahk

if !gToken := Gdip_Startup() {
    MsgBox "GdiPlus failed to start"
    ExitApp
}
OnExit RunOnExit

Minotaurs := MDMF_Enum()
stdo Minotaurs.Count


MonitorPrimary := GetPrimaryMonitor()
Monitor  := GetMonitorInfo(MonitorPrimary)
WALeft   := Monitor.WALeft
WATop    := Monitor.WATop
WARight  := Monitor.WARight
WABottom := Monitor.WABottom
WAWidth  := Monitor.WARight - Monitor.WALeft
WAHeight := Monitor.WABottom - Monitor.WATop

gGui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
gGui.Show "NA"
gHwnd := WinExist()

bmHndl := CreateDIBSection(WAWidth, WAHeight)
dcHndl := CreateCompatibleDC()
bmObj  := SelectObject(dcHndl, bmHndl)
gfx    := Gdip_GraphicsFromHDC(dcHndl)

Gdip_SetSmoothingMode gfx, 4

SetTimer DrawCircle, 200


DrawCircle() {
    global
    RandBG    := Random(0.0, 0xFFFFFFFF)
    RandFG    := Random(0.0, 0xFFFFFFFF)
    RandBrush := Random(0, 53)
    RandEllipseWidth  := Random(1, 200)
    RandEllipseHeight := Random(1, 175)
    RandEllipseXPos   := Random(WALeft, WAWidth-RandEllipseWidth)
    RandEllipseYPos   := Random(WATop, WAHeight-RandEllipseHeight)
    
    gBrush := Gdip_BrushCreateHatch(RandBG, RandFG, RandBrush)
    Gdip_FillEllipse gfx, gBrush, RandEllipseXPos, RandEllipseYPos, RandEllipseWidth, RandEllipseHeight
    UpdateLayeredWindow gHwnd, dcHndl, WALeft, WATop, WAWidth, WAHeight
    Gdip_DeleteBrush gBrush
}

RunOnExit(*) {
    global
    SelectObject dcHndl, bmObj
    DeleteObject bmHndl
    DeleteDC dcHndl
    Gdip_DeleteGraphics gfx
    Gdip_Shutdown gToken
}
