#Requires AutoHotkey v2.0-beta
#Warn All, StdOut
#SingleInstance Force

if (A_ScriptName="Gdip_Nega.ahk") {

}


Class GdipSolidBrushPalette {
    paletteMap := "", brushNames := ""
    __New(NameColorPairs*) {
        if (NameColorPairs.Length < 2) or IsNumber(NameColorPairs[1])
            Return
        if Mod(NameColorPairs.Length, 2)
            NameColorPairs.Pop()
        this.paletteMap := Map(NameColorPairs*)
    }
    __Delete() {
        this.BurnEmAll()
    }
    NewBrush(bName, bColor) {
        if this.%bName%:=Gdip_BrushCreateSolid(bColor)
            this.brushNames.Push(bName)
    }
    CreateAll() {
        for bName, bColor in this.paletteMap
            this.NewBrush(bName, bColor)
    }
    BurnEmAll() {
        for _index, bName in this.brushNames
            Gdip_DeleteBrush(this.%bName%), this.%bName% := ""
    }
}


#Include <DBT>
#Include <Gdip_v2Ex>