#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

#Include <DBT>
#Include <Gdip_v2Ex>

/**
 * TODO: Create a main application class to run on creation of instance
 * TODO: Create Gui using Gdip, a  0xE enabled picture control, and SetImage
 */

if A_ScriptName="BetterClipboard.ahk" {
    app:=BC_App()
}


Class BC_App {
    gui := {}
    gdip := {}
    __New() {
        this.gui := Gui("-Caption +AlwaysOnTop")
        this.gui.OnEvent("Close", ObjBindMethod(this, "On_Gui_Close"))
        this.bgPic := this.gui.Add("Picture", "0xE")
        this.gdip := BC_App.Gdip()
    }
    On_Gui_Close(gObj){
        ExitApp
    }
    __Delete() {
        
    }
    /**
     * @param {Integer} Options
     *      Specify **0** for toggle, **1** to show, and **-1** to hide
     */
    Toggle(Options:=0) {

    }
    PaintBackground() {

    }
    ; A class whose purpose is to store gdip components and share them among
    ;       methods of a class as well as provide management of Gdip library
    ;       and custom Gdip utilites
    Class Gdip {
        gdip_token := 0x0
        brush_palette := Map()
        default_brush_palette := Map(
                       black, 0xFF000000
          ,    black_trans50, 0xAA000000
          ,            white, 0xFFFFFFFF
          ,    white_trans50, 0xAAFFFFFF
          ,       gray_light, 0xFFCCCCCC
          ,             gray, 0xFFAAAAAA
          ,        gray_dark, 0xFF555555
          ,   ahkgreen_light, 0xFF7FB089
          ,         ahkgreen, 0xFF4BB560
          ,    ahkgreen_dark, 0xFF49614E
          , ahkgreen_trans50, 0xAA4BB560
        )
        __New() {
            if !this.gdip_token:=Gdip_Startup()
                MsgBox "Gdip failed to start"
            else OnExit ObjBindMethod(this, (*)=>__Delete())
        }
        __Delete() {
            if this.gdip_token
                Gdip_Shutdown this.gdip_token
        }
        CreateBrushPalette(_Name_Value_Pairs*) {
            paramisdef := (_Name_Value_Pairs[1]="Default")
            paramismap := (_Name_Value_Pairs[1]="Map")
            ((paramisbad:=(Mod(paramLen:=_Name_Value_Pairs.Length, 2)
                           &&!(paramisdef||paramismap)))
                ? MsgBox.Bind(A_ThisFunc ": Incorrect parameters")
                : ((*)=>a:="").Bind()).Call()
            this.brush_palette := (paramisdef) ?this.default_brush_palette
                                     :(paramismap) ?_Name_Value_Pairs[2] 
                                        :(paramisbad) ?Map() :this.brush_palette
            if !paramisbad
                if !paramisdef and !paramismap and (paramLen>1)
                    for _i, _value in _Name_Value_Pairs
                        if Mod(_i, 2)
                            this.%_value% := Gdip_BrushCreateSolid(
                                this.brush_palette.%_value% :=
                                    _Name_Value_Pairs[_i+1]       )
            Return this.brush_palette
        }
        BurnBrushes() {
            for _name, _color in this.brush_palette
                this.%name% := ""
            this.brush_palette := Map()
        }
    }
}