
Class VolChangeGui {
    ; @prop {Gui} gui
    Static gui := {}
        ; @prop {Gui.Control} prog
        , prog := {}
        ; @prop {Object} size
        , size := { w: 25, h: A_ScreenHeight }
        ; @prop {Object} pos
        , pos := { x: 62, y: 0 }
        ; @prop {Boolean} init
        , init := False
        ; @prop {Boolean} hidden
        , hidden := True
        ; @prop {BoundFunc} BFHide
        , BFHide := {}
    Static __New() {
        this.gui := Gui("-Caption +Owner +AlwaysOnTop",
                        "AHKVolumeChangeGui")
        this.gui.MarginX := this.gui.MarginY := 0
        this.prog := this.gui.Add("Progress", "Smooth Vertical Range0-100 C0C2B27 BackgroundAAAAAA " .
                                            "w" this.size.w " h" this.size.h)
        this.BFHide := ObjBindMethod(this, "Hide")
    }
    Static Show() {
        this.prog.Value := Round(SoundGetVolume())
        this.UpdateMuteStatus()
        if (this.hidden) {
            _showParam := (this.init) ? "NA" : ("NA x" ((this.init:=True)*this.pos.x) " y" this.pos.y)
            this.gui.Show(_showParam)
            WinSetTransColor("AAAAAA 225", this.gui)
            this.hidden := False
        }
        SetTimer(this.BFHide, -1000)
    }
    Static Hide(*) {
        this.gui.Hide()
        this.hidden := True
        SetTimer(,0)
    }
    Static UpdateMuteStatus(*) {
        if !!SoundGetMute()
            this.prog.Opt("C2C3B37")
        else this.prog.Opt("C0C2B27")
    }
}