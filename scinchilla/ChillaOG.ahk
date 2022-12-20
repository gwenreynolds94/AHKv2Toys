#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include ..\Lib\
#Include SciLib\SciConstants.ahk
#Include SciLib\OGSciLoad.ahk

#Include DEBUG\DBT.ahk

SCI_DLL_PATH := "..\Lib\SciLib\Scintilla.dll"
SciPtr := SciLoad(SCI_DLL_PATH)

if (SciPtr)
   OnExit (*)=> SciFree(SciPtr)
else MsgBox("Failed to load the necessary .dll"), ExitApp()

Class ScinChilla {
    WS := { OVERLAPPED: "0x00000000",            POPUP: "0x80000000",                ;
                 CHILD: "0x40000000",         MINIMIZE: "0x20000000",                ;
               VISIBLE: "0x10000000",         DISABLED: "0x08000000",                ;
              MAXIMIZE: "0x01000000",          CAPTION: "0x00C00000",                ;
                BORDER: "0x00800000",         DLGFRAME: "0x00400000",                ;
               VSCROLL: "0x00200000",          HSCROLL: "0x00100000",                ;
               SYSMENU: "0x00080000",       THICKFRAME: "0x00040000",                ;
                 GROUP: "0x00020000",          TABSTOP: "0x00010000",                ;
           MINIMIZEBOX: "0x00020000",      MAXIMIZEBOX: "0x00010000",                ;
                 TILED: "0x00000000",           ICONIC: "0x20000000",                ;
               SIZEBOX: "0x00040000",     CLIPSIBLINGS: "0x04000000",                ;
          CLIPCHILDREN: "0x02000000",                                                ;
                    Ex: { ACCEPTFILES: "0x00000010",      APPWINDOW: "0x00040000", ; ;
                           CLIENTEDGE: "0x00000200",     COMPOSITED: "0x02000000", ; ;
                          CONTEXTHELP: "0x00000400",  CONTROLPARENT: "0x00010000", ; ;
                        DLGMODALFRAME: "0x00000001",        LAYERED: "0x00080000", ; ;
                            LAYOUTRTL: "0x00400000",           LEFT: "0x00000000", ; ;
                        LEFTSCROLLBAR: "0x00004000",     LTRREADING: "0x00000000", ; ;
                             MDICHILD: "0x00000040",     NOACTIVATE: "0x08000000", ; ;
                      NOINHERITLAYOUT: "0x00100000", NOPARENTNOTIFY: "0x00000004", ; ;
                  NOREDIRECTIONBITMAP: "0x00200000",          RIGHT: "0x00001000", ; ;
                       RIGHTSCROLLBAR: "0x00000000",     RTLREADING: "0x00002000", ; ;
                           STATICEDGE: "0x00020000",     TOOLWINDOW: "0x00000080", ; ;
                              TOPMOST: "0x00000008",    TRANSPARENT: "0x00000020", ; ;
                           WINDOWEDGE: "0x00000100"                                } }
    isDragging := False
    AltDrag := {
        status: False
       , mouse: { x: -1, y: -1 }
       ,   win: { x: -1, y: -1 }
    }
    __New() {
        this.Scink := ScinChilla.Scink()
        this.gui := Gui("-Caption",, this.Scink)
        _Style := _SciBase.Default.Options.Style | this.WS.SIZEBOX
        _ExStyle := _SciBase.Default.Options.ExStyle | this.WS.Ex.ACCEPTFILES | this.WS.Ex.DLGMODALFRAME | this.WS.Ex.STATICEDGE
        this.sci := this.gui.SciAdd({ x: 0  , y: 0
                                    , w: 550, h: 450
                                    , Visible:True
                                    ,   Style:_Style
                                    , ExStyle:_ExStyle })
        this.gui.Show("w" this.sci.Options.w+this.sci.Options.x*2 " h" this.sci.Options.h+this.sci.Options.y*2)
        this.gui.OnEvent("Close", "Gui_OnClose")
        OnMessage(0x1666, ObjBindMethod(this, "OnUserDragSizing"))
    }

    OnUserDragSizing(wparam, lparam, msg, hwnd) {
        if (!wparam) {
            WinGetPos(,,&_w,&_h,this.gui)
        }
    }

    Class Scink {
        Gui_OnClose(guiObj, *)=> (guiObj.Destroy(), ExitApp())
    }
}

Chilla := ScinChilla()


F8::ExitApp