#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\GdipHelpers\Gdip_Nega.ahk 


if (A_ScriptName="Gdip_Paths.ahk") {
    Hotkey "F8", (*)=> ExitApp()
    pathapp := PathsGui(550, 280)
}


Class PathsGui {
    gdip:={}
    width:=0, height:=0

    __New(width, height) {

        this.width := width, this.height := height

        this.gui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +OwnDialogs")
        this.gui.Show("NA")

        this.PrepareGDI()
        this.PaintBackground()
        this.CreatePath()
        this.DrawPath()
        this.FinishUp()
    }
    PrepareGDI() {
        gd:=this.gdip
        gd.token := Gdip_Startup()
        OnExit (*)=> (gd.token) ? Gdip_Shutdown(gd.token) : 0
        gd.hbm := CreateDIBSection(this.width, this.height)
        gd.hdc := CreateCompatibleDC()
        gd.obm := SelectObject(gd.hdc, gd.hbm)
        gd.gfx := Gdip_GraphicsFromHDC(gd.hdc)
        Gdip_SetSmoothingMode(gd.gfx, 4)
    }
    PaintBackground() {
        pbr := Gdip_CreateLineBrushFromRect(0, 0, this.width, this.height, 0xff995555, 0xff050555)
        Gdip_FillRectangle(this.gdip.gfx, pbr, 0, 0, this.width, this.height)
        Gdip_DeleteBrush(pbr)
        pbr := Gdip_BrushCreateHatch(0xFF000000, 0x00000000, 8)
        Gdip_FillRectangle(this.gdip.gfx, pbr, 0, 0, this.width, this.height)
        Gdip_DeleteBrush(pbr)
    }
    CreatePath() {
        gd:=this.gdip
        gd.pPath := Gdip_CreatePath()
        Gdip_StartPathFigure(gd.pPath)
        Gdip_AddPathLine(gd.pPath, 110,95, 220,95)
        Gdip_AddPathBezier(gd.pPath, 220,95, 228,112, 233,120, 262,120)
        Gdip_AddPathLines(gd.pPath, "262,120|265,95|269,110|280,110|284,95|287,120")
        Gdip_AddPathBezier(gd.pPath, 287,120, 305,120, 320,120, 330,95)
        Gdip_AddPathLine(gd.pPath, 330,95, 439,95)
        Gdip_AddPathBeziers(gd.pPath, "439,95|406,108|381,126|389,159|322,157|287,170|275,"
                                   "206|262,170|227,157|160,159|168,126|144,109|110,95")
        Gdip_ClosePathFigure(gd.pPath)
    }
    DrawPath() {
        gd:=this.gdip

        pPen := Gdip_CreatePen(0x22ffffff, 14)
        Gdip_DrawPath(gd.gfx, pPen, gd.pPath)
        Gdip_DeletePen(pPen)

        pBrush := Gdip_CreateLineBrushFromRect(0, 95, this.width, (this.height-190)/2, 0xff110000, 0xff664040)
        Gdip_FillPath(gd.gfx, pBrush, gd.pPath) 
        Gdip_DeleteBrush(pBrush)

        pBrush := Gdip_BrushCreateHatch(0xff000000, 0x00000000, 21)
        Gdip_FillPath(gd.gfx, pBrush, gd.pPath)
        Gdip_DeleteBrush(pBrush)

        pPen := Gdip_CreatePen(0xffa5a5a5, 5)
        Gdip_DrawPath(gd.gfx, pPen, gd.pPath)
        Gdip_DeletePen(pPen)

        pPen := Gdip_CreatePen(0xff000000, 1)
        Gdip_DrawPath(gd.gfx, pPen, gd.pPath)
        Gdip_DeletePen(pPen)

        Gdip_DeletePath(gd.pPath)
    }
    FinishUp() {
        UpdateLayeredWindow(  this.gui.Hwnd
                            , this.gdip.hdc
                            , (A_ScreenWidth-this.width)//2
                            , (A_ScreenHeight-this.height)//2
                            , this.width
                            , this.height                      )
        SelectObject(this.gdip.hdc, this.gdip.obm)
        DeleteObject(this.gdip.hbm)
        DeleteDC(this.gdip.hdc)
        Gdip_DeleteGraphics(this.gdip.gfx)
        Gdip_Shutdown(this.gdip.token)
    }
}
